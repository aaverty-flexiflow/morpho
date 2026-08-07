import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../features/habits/domain/habit.dart';
import '../../features/habits/domain/habit_entry.dart';
import '../../features/habits/domain/habit_summary.dart';
import '../widget/home_widget_service.dart';

/// SQLite-backed persistence layer for habits and their completion entries.
///
/// Exposes reactive [Stream]s so Riverpod providers stay live. Internally uses
/// [StreamController.broadcast] with a "fetch-then-notify" pattern — each write
/// re-queries the database and pushes the new snapshot to all listeners.
class HabitRepository {
  HabitRepository._(this._db);

  final Database _db;

  // Broadcast streams — any number of listeners, no replay on subscribe.
  // Widgets receive the initial snapshot via the async* generators in providers.
  final _habitsCtrl = StreamController<List<Habit>>.broadcast();
  final _entriesCtrl = StreamController<List<HabitEntry>>.broadcast();

  Stream<List<Habit>> get _rawHabitsStream => _habitsCtrl.stream;
  Stream<List<HabitEntry>> get _rawEntriesStream => _entriesCtrl.stream;

  // ── Init ──────────────────────────────────────────────────────────────────

  static Future<HabitRepository> open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'morpho.db');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: _initSchema,
      onUpgrade: _upgradeSchema,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    );

    final repo = HabitRepository._(db);
    // Process any check-ins tapped in the widget while the app was closed,
    // then push fresh state to the widget.
    await repo.syncPendingWidgetCheckIns();
    repo
        ._buildSummaries(gracePeriod: false)
        .then(HomeWidgetService.update)
        .ignore();
    return repo;
  }

  static Future<void> _initSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits (
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        name            TEXT    NOT NULL,
        emoji           TEXT    NOT NULL,
        color_value     INTEGER NOT NULL,
        plant_type      TEXT    NOT NULL,
        frequency_index INTEGER NOT NULL DEFAULT 0,
        reminder_time   TEXT,
        created_at      TEXT    NOT NULL,
        is_archived     INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE habit_entries (
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id     INTEGER NOT NULL,
        completed_at TEXT    NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Fast look-ups by habit and by date.
    await db.execute('CREATE INDEX idx_entries_habit ON habit_entries (habit_id)');
    await db.execute('CREATE INDEX idx_entries_date  ON habit_entries (completed_at)');
  }

  static Future<void> _upgradeSchema(Database db, int oldVersion, int newVersion) async {
    // v1 → v2: add frequency support; existing habits default to daily (index 0).
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE habits ADD COLUMN frequency_index INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  // ── Reactive streams (used by Riverpod providers) ─────────────────────────

  /// Emits a [HabitSummary] list whenever habits or entries change.
  ///
  /// The first event is emitted immediately upon subscription via [async*].
  Stream<List<HabitSummary>> summariesStream({bool gracePeriod = false}) async* {
    // Emit current state immediately so widgets don't flash a loading skeleton.
    yield await _buildSummaries(gracePeriod: gracePeriod);

    // Merge habit and entry change signals into one stream.
    await for (final _ in _mergedChangeStream()) {
      yield await _buildSummaries(gracePeriod: gracePeriod);
    }
  }

  /// Emits entries for a single habit, useful for the detail/heatmap view.
  Stream<List<HabitEntry>> entriesStream(int habitId) async* {
    yield await getEntriesForHabit(habitId);

    await for (final _ in _rawEntriesStream) {
      yield await getEntriesForHabit(habitId);
    }
  }

  // ── Habits CRUD ───────────────────────────────────────────────────────────

  Future<int> insertHabit(Habit habit) async {
    final id = await _db.insert(
      'habits',
      habit.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    await _notifyHabits();
    return id;
  }

  Future<void> updateHabit(Habit habit) async {
    assert(habit.id != null, 'Cannot update a habit without an id');
    await _db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
    await _notifyHabits();
  }

  Future<void> archiveHabit(int habitId) async {
    await _db.update(
      'habits',
      {'is_archived': 1},
      where: 'id = ?',
      whereArgs: [habitId],
    );
    await _notifyHabits();
  }

  Future<void> unarchiveHabit(int habitId) async {
    await _db.update(
      'habits',
      {'is_archived': 0},
      where: 'id = ?',
      whereArgs: [habitId],
    );
    await _notifyHabits();
  }

  Future<void> deleteHabit(int habitId) async {
    await _db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
    await _notifyHabits();
    await _notifyEntries();
  }

  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    final maps = await _db.query(
      'habits',
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'created_at ASC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  Future<List<Habit>> getArchivedHabits() async {
    final maps = await _db.query(
      'habits',
      where: 'is_archived = 1',
      orderBy: 'created_at ASC',
    );
    return maps.map(Habit.fromMap).toList();
  }

  /// Reactive stream of archived habits — re-emits whenever habits change.
  Stream<List<Habit>> archivedHabitsStream() async* {
    yield await getArchivedHabits();
    await for (final _ in _rawHabitsStream) {
      yield await getArchivedHabits();
    }
  }

  // ── Entries CRUD ──────────────────────────────────────────────────────────

  /// Adds a check-in for today.
  ///
  /// Returns false and does nothing when the habit is already completed today,
  /// preventing duplicate streaks from double-taps.
  Future<bool> checkIn(int habitId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final existing = await _db.query(
      'habit_entries',
      where: 'habit_id = ? AND completed_at BETWEEN ? AND ?',
      whereArgs: [
        habitId,
        todayStart.toIso8601String(),
        todayEnd.toIso8601String(),
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) return false;

    await _db.insert('habit_entries', {
      'habit_id': habitId,
      'completed_at': now.toIso8601String(),
    });

    await _notifyEntries();
    return true;
  }

  /// Removes today's check-in (undo gesture).
  Future<void> undoCheckIn(int habitId) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    await _db.delete(
      'habit_entries',
      where: 'habit_id = ? AND completed_at BETWEEN ? AND ?',
      whereArgs: [
        habitId,
        todayStart.toIso8601String(),
        todayEnd.toIso8601String(),
      ],
    );

    await _notifyEntries();
  }

  Future<List<HabitEntry>> getEntriesForHabit(int habitId) async {
    final maps = await _db.query(
      'habit_entries',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at ASC',
    );
    return maps.map(HabitEntry.fromMap).toList();
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<List<HabitSummary>> _buildSummaries({required bool gracePeriod}) async {
    final habits = await getAllHabits();
    final summaries = <HabitSummary>[];

    for (final habit in habits) {
      final entries = await getEntriesForHabit(habit.id!);
      final dates = entries.map((e) => e.completedAt).toList();
      summaries.add(HabitSummary.compute(habit, dates, gracePeriod: gracePeriod));
    }

    return summaries;
  }

  /// Emits a single value whenever habits or entries change.
  Stream<void> _mergedChangeStream() async* {
    final ctrl = StreamController<void>.broadcast();

    final s1 = _rawHabitsStream.listen((_) => ctrl.add(null));
    final s2 = _rawEntriesStream.listen((_) => ctrl.add(null));

    yield* ctrl.stream;

    await s1.cancel();
    await s2.cancel();
    await ctrl.close();
  }

  Future<void> _notifyHabits() async {
    if (_habitsCtrl.isClosed) return;
    _habitsCtrl.add(await getAllHabits());
    _buildSummaries(gracePeriod: false).then(HomeWidgetService.update).ignore();
  }

  Future<void> _notifyEntries() async {
    if (_entriesCtrl.isClosed) return;
    final maps = await _db.query('habit_entries');
    _entriesCtrl.add(maps.map(HabitEntry.fromMap).toList());
    _buildSummaries(gracePeriod: false).then(HomeWidgetService.update).ignore();
  }

  /// Processes check-ins queued by the iOS widget's CheckInIntent.
  /// Called at startup and every time the app comes to the foreground.
  Future<void> syncPendingWidgetCheckIns() async {
    final ids = await HomeWidgetService.takePendingCheckIns();
    for (final id in ids) {
      await checkIn(id);
    }
  }

  Future<void> close() async {
    await _habitsCtrl.close();
    await _entriesCtrl.close();
    await _db.close();
  }

  // ── Debug helpers (kDebugMode only) ───────────────────────────────────────

  Future<String> debugGetDbPath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'morpho.db');
  }

  /// Seeds check-ins for all active habits going back [days] calendar days.
  ///
  /// Daily habits receive one entry per day. Weekly habits receive
  /// [timesPerPeriod] entries per 7-day block, spread on consecutive days.
  Future<void> debugSeedDays(int days) async {
    final habits = await getAllHabits();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _db.transaction((txn) async {
      for (final habit in habits) {
        if (habit.frequency.isDaily) {
          for (var i = 0; i < days; i++) {
            final date = today.subtract(Duration(days: i));
            await _insertEntryIfAbsent(txn, habit.id!, date);
          }
        } else {
          // Align to ISO-week boundaries (Monday) so the streak calculator,
          // which also uses ISO weeks, sees timesPerPeriod entries per week.
          final daysSinceMonday = today.weekday - 1; // 0 = Mon, 6 = Sun
          final currentWeekMonday = today.subtract(Duration(days: daysSinceMonday));
          final periods = (days / 7).ceil() + 1;

          for (var week = 0; week < periods; week++) {
            final periodStart = currentWeekMonday.subtract(Duration(days: week * 7));
            for (var rep = 0; rep < habit.frequency.timesPerPeriod; rep++) {
              final date = periodStart.add(Duration(days: rep));
              final daysAgo = today.difference(date).inDays;
              if (daysAgo < 0 || daysAgo >= days) continue;
              await _insertEntryIfAbsent(txn, habit.id!, date);
            }
          }
        }
      }
    });

    await _notifyEntries();
  }

  /// Checks in all active habits for today (skips if already done).
  Future<void> debugSeedToday() async {
    final habits = await getAllHabits();
    for (final habit in habits) {
      await checkIn(habit.id!);
    }
  }

  /// Deletes every check-in entry (keeps habits intact).
  Future<void> debugClearAllEntries() async {
    await _db.delete('habit_entries');
    await _notifyEntries();
  }

  Future<void> _insertEntryIfAbsent(Transaction txn, int habitId, DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day).toIso8601String();
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String();

    final existing = await txn.query(
      'habit_entries',
      where: 'habit_id = ? AND completed_at BETWEEN ? AND ?',
      whereArgs: [habitId, dayStart, dayEnd],
      limit: 1,
    );

    if (existing.isEmpty) {
      await txn.insert('habit_entries', {
        'habit_id': habitId,
        'completed_at': DateTime(date.year, date.month, date.day, 12).toIso8601String(),
      });
    }
  }
}
