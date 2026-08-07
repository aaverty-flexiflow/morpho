import 'package:morpho/i18n/strings.g.dart';

/// How often a habit must be performed within a rolling period.
///
/// Stored as the enum index in the SQLite habits table (`frequency_index`).
/// Adding new values appends to the end — never reorder existing entries.
enum HabitFrequency {
  daily(timesPerPeriod: 1, periodDays: 1),
  twiceWeek(timesPerPeriod: 2, periodDays: 7),
  thriceWeek(timesPerPeriod: 3, periodDays: 7),
  fourWeek(timesPerPeriod: 4, periodDays: 7),
  fiveWeek(timesPerPeriod: 5, periodDays: 7),
  sixWeek(timesPerPeriod: 6, periodDays: 7),
  weekly(timesPerPeriod: 1, periodDays: 7);

  const HabitFrequency({
    required this.timesPerPeriod,
    required this.periodDays,
  });

  /// How many check-ins are required within a single [periodDays]-long window.
  final int timesPerPeriod;

  /// Length of the repeating window in calendar days (1 = daily, 7 = weekly).
  final int periodDays;

  bool get isDaily => this == HabitFrequency.daily;

  /// Human-readable label shown in the frequency picker.
  String get label {
    switch (this) {
      case daily:
        return t.frequency.daily;
      case twiceWeek:
        return t.frequency.twiceWeek;
      case thriceWeek:
        return t.frequency.thriceWeek;
      case fourWeek:
        return t.frequency.fourWeek;
      case fiveWeek:
        return t.frequency.fiveWeek;
      case sixWeek:
        return t.frequency.sixWeek;
      case weekly:
        return t.frequency.weekly;
    }
  }

  /// Abbreviated label for compact display (e.g. inside a habit card badge).
  String get shortLabel {
    switch (this) {
      case daily:
        return t.frequency.dailyShort;
      case twiceWeek:
        return t.frequency.twiceWeekShort;
      case thriceWeek:
        return t.frequency.thriceWeekShort;
      case fourWeek:
        return t.frequency.fourWeekShort;
      case fiveWeek:
        return t.frequency.fiveWeekShort;
      case sixWeek:
        return t.frequency.sixWeekShort;
      case weekly:
        return t.frequency.weeklyShort;
    }
  }

  /// Unit suffix for the streak counter: days for daily, weeks otherwise.
  String get streakUnit => isDaily ? t.frequency.streakUnitDay : t.frequency.streakUnitWeek;
}
