import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../core/database/habit_repository.dart';
import '../../../features/habits/domain/habit.dart';
import '../../../features/habits/domain/habit_entry.dart';
import '../../../features/habits/domain/habit_summary.dart';


// ── Repository ────────────────────────────────────────────────────────────────

/// Overridden in [ProviderScope] at startup once the database is open.
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  throw UnimplementedError('habitRepositoryProvider must be overridden at startup');
});

// ── Settings dependency ───────────────────────────────────────────────────────

/// Whether the grace-period feature is enabled (set via settings page).
final gracePeriodEnabledProvider = StateProvider<bool>((ref) => false);

// ── Reactive read streams ─────────────────────────────────────────────────────

/// Live list of [HabitSummary] items — rebuilds whenever any habit or entry changes.
///
/// The initial emit happens synchronously from the DB before the first frame,
/// so widgets see real data immediately rather than a loading state.
final habitSummariesProvider = StreamProvider<List<HabitSummary>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  final gracePeriod = ref.watch(gracePeriodEnabledProvider);
  return repo.summariesStream(gracePeriod: gracePeriod);
});

/// Live list of archived [Habit] items.
final archivedHabitsProvider = StreamProvider<List<Habit>>((ref) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.archivedHabitsStream();
});

/// Entries for a specific habit — used by the detail / heatmap view.
final habitEntriesProvider =
    StreamProvider.autoDispose.family<List<HabitEntry>, int>((ref, habitId) {
  final repo = ref.watch(habitRepositoryProvider);
  return repo.entriesStream(habitId);
});

// ── Write actions (exposed as simple async methods on a Notifier) ─────────────

/// Provides write access to the repository (add, update, check-in, delete).
///
/// State is [AsyncValue<void>] — [AsyncLoading] during a write, [AsyncError]
/// on failure. Widgets should read this only when they need to trigger side
/// effects, not for displaying data.
class HabitsNotifier extends AsyncNotifier<void> {
  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<int> addHabit(Habit habit) async {
    state = const AsyncLoading();
    try {
      final id = await _repo.insertHabit(habit);
      state = const AsyncData(null);
      return id;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncLoading();
    try {
      await _repo.updateHabit(habit);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> archiveHabit(int habitId) async {
    await _repo.archiveHabit(habitId);
  }

  Future<void> unarchiveHabit(int habitId) async {
    await _repo.unarchiveHabit(habitId);
  }

  Future<void> deleteHabit(int habitId) async {
    await _repo.deleteHabit(habitId);
  }

  /// Returns [true] when this was a new check-in (not a duplicate).
  Future<bool> checkIn(int habitId) => _repo.checkIn(habitId);

  Future<void> undoCheckIn(int habitId) => _repo.undoCheckIn(habitId);
}

final habitsNotifierProvider =
    AsyncNotifierProvider<HabitsNotifier, void>(HabitsNotifier.new);
