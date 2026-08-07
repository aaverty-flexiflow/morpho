import 'habit_frequency.dart';

/// Pure utility for streak and completion-rate calculations.
///
/// All methods are static and side-effect-free, making them trivially unit-testable
/// without any dependency injection or mocking.
abstract final class StreakCalculator {
  /// Returns the current streak for [frequency]-based habits.
  ///
  /// For daily habits this delegates to [current]. For weekly/N-per-week
  /// habits it counts the number of consecutive ISO-week periods where the
  /// required quota ([HabitFrequency.timesPerPeriod]) was met.
  ///
  /// The current (possibly incomplete) period is NOT counted unless its goal
  /// is already met — the streak reflects fully completed periods.
  static int currentForFrequency(
    List<DateTime> completionDates,
    HabitFrequency frequency, {
    DateTime? now,
    bool gracePeriod = false,
  }) {
    if (frequency.isDaily) {
      return current(completionDates, now: now, gracePeriod: gracePeriod);
    }

    if (completionDates.isEmpty) return 0;

    final today = _dateOnly(now ?? DateTime.now());
    int streak = 0;
    bool graceUsed = false;

    // Scan backwards one period at a time (max 2 years to avoid infinite loops).
    for (int periodsBack = 0; periodsBack <= 104; periodsBack++) {
      final count = _completionsInPeriodBack(
        completionDates, frequency, today, periodsBack,
      );

      if (count >= frequency.timesPerPeriod) {
        streak++;
      } else if (periodsBack == 0) {
        // Current period not yet complete — don't break the streak, just skip.
        continue;
      } else if (gracePeriod && !graceUsed) {
        // Allow one missed period across the entire streak.
        graceUsed = true;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Returns the number of check-ins in the current period (today for daily,
  /// this ISO-week for weekly/N-per-week habits).
  static int completionsInCurrentPeriod(
    List<DateTime> completionDates,
    HabitFrequency frequency, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    if (frequency.isDaily) {
      return completionDates.any((d) => isSameDay(d, today)) ? 1 : 0;
    }
    return _completionsInPeriodBack(completionDates, frequency, today, 0);
  }

  // ── Daily streak (unchanged) ───────────────────────────────────────────────

  /// Returns the number of consecutive days (including today) the habit has
  /// been completed, counting backwards from the most recent entry.
  ///
  /// A single gap of exactly one day is forgiven when [gracePeriod] is true,
  /// which lets users miss yesterday without breaking a long streak.
  static int current(
    List<DateTime> completionDates, {
    DateTime? now,
    bool gracePeriod = false,
  }) {
    if (completionDates.isEmpty) return 0;

    final today = _dateOnly(now ?? DateTime.now());
    final uniqueDays = _uniqueDays(completionDates)..sort((a, b) => b.compareTo(a));

    // The streak must anchor on today or yesterday — regardless of grace period.
    // If today is not yet done, the streak still represents the ongoing run
    // through yesterday (gracePeriod then buys an extra skipped day inside the loop).
    final anchor = uniqueDays.first;
    final daysSinceAnchor = today.difference(anchor).inDays;

    if (daysSinceAnchor > 1) return 0;

    int streak = 1;
    for (int i = 0; i < uniqueDays.length - 1; i++) {
      final gap = uniqueDays[i].difference(uniqueDays[i + 1]).inDays;
      if (gap == 1) {
        streak++;
      } else if (gracePeriod && gap == 2 && streak > 0) {
        // Allow one skipped day across the entire streak.
        gracePeriod = false; // consume the grace
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  /// Returns the longest uninterrupted streak ever recorded (in days).
  static int longest(List<DateTime> completionDates) {
    if (completionDates.isEmpty) return 0;

    final days = _uniqueDays(completionDates)..sort();
    int best = 1;
    int run = 1;

    for (int i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays == 1) {
        run++;
        if (run > best) best = run;
      } else {
        run = 1;
      }
    }

    return best;
  }

  /// Whether [date] falls on the same calendar day as [reference].
  static bool isSameDay(DateTime date, DateTime reference) =>
      _dateOnly(date) == _dateOnly(reference);

  /// Fraction of days in the last [windowDays] where the habit was completed.
  ///
  /// Returns 0.0 when the window is empty. Values are clamped to [0.0, 1.0].
  static double completionRate(
    List<DateTime> completionDates, {
    DateTime? now,
    int windowDays = 30,
  }) {
    if (windowDays <= 0) return 0.0;

    final today = _dateOnly(now ?? DateTime.now());
    final windowStart = today.subtract(Duration(days: windowDays - 1));
    final completedInWindow = _uniqueDays(completionDates)
        .where((d) => !d.isBefore(windowStart) && !d.isAfter(today))
        .length;

    return (completedInWindow / windowDays).clamp(0.0, 1.0);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Count unique check-in days within the period that is [periodsBack]
  /// periods before the current period containing [today].
  ///
  /// For weekly frequencies, a period always starts on Monday (ISO week).
  static int _completionsInPeriodBack(
    List<DateTime> dates,
    HabitFrequency frequency,
    DateTime today,
    int periodsBack,
  ) {
    final start = _periodStart(today, frequency.periodDays, periodsBack);
    final end = start.add(Duration(days: frequency.periodDays - 1));

    return dates
        .where((d) {
          final day = _dateOnly(d);
          return !day.isBefore(start) && !day.isAfter(end);
        })
        .map(_dateOnly)
        .toSet()
        .length;
  }

  /// Returns the first day (Monday for weekly periods) of the period that is
  /// [periodsBack] periods before the period containing [today].
  static DateTime _periodStart(DateTime today, int periodDays, int periodsBack) {
    // Align to Monday of the current week so weekly periods are always
    // Mon–Sun regardless of what day [today] is.
    final daysSinceMonday = today.weekday - 1; // 0 for Mon, 6 for Sun
    final currentPeriodMonday = today.subtract(Duration(days: daysSinceMonday));
    return currentPeriodMonday.subtract(Duration(days: periodsBack * periodDays));
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static List<DateTime> _uniqueDays(List<DateTime> dates) =>
      dates.map(_dateOnly).toSet().toList();
}
