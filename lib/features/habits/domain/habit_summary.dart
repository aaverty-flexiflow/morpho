import 'habit.dart';
import 'plant_stage.dart';
import 'streak_calculator.dart';

/// Computed read model — a [Habit] enriched with its current stats.
///
/// Built by [HabitRepository.summariesStream] from raw DB data; never persisted.
/// Widgets consume this class instead of querying entries themselves.
class HabitSummary {
  const HabitSummary({
    required this.habit,
    required this.currentStreak,
    required this.longestStreak,
    required this.isCompletedToday,
    required this.isGoalMetForPeriod,
    required this.completionsThisPeriod,
    required this.completionRate30d,
    required this.completionDates,
  });

  final Habit habit;
  final int currentStreak;
  final int longestStreak;

  /// Whether the user already has a check-in for today (regardless of quota).
  /// Used to gate the check-in button — one check-in per calendar day.
  final bool isCompletedToday;

  /// Whether the required quota for the current period has been met.
  ///
  /// For daily habits this equals [isCompletedToday]. For N-per-week habits
  /// this is true once the user has N check-ins this ISO-week.
  final bool isGoalMetForPeriod;

  /// How many check-ins the user has accumulated in the current period.
  /// Useful for rendering "2/3 cette sem." progress indicators.
  final int completionsThisPeriod;

  /// Fraction of the last 30 days where this habit was completed.
  final double completionRate30d;

  /// Full history of completion dates (used by detail page heatmap).
  final List<DateTime> completionDates;

  PlantStage get stage => PlantStage.fromStreak(currentStreak);

  /// Required completions per period (shortcut to [Habit.frequency.timesPerPeriod]).
  int get requiredPerPeriod => habit.frequency.timesPerPeriod;

  /// Computes a [HabitSummary] from raw entry dates.
  factory HabitSummary.compute(
    Habit habit,
    List<DateTime> dates, {
    bool gracePeriod = false,
  }) {
    final frequency = habit.frequency;
    final now = DateTime.now();
    final completionsThisPeriod = StreakCalculator.completionsInCurrentPeriod(
      dates,
      frequency,
      now: now,
    );

    return HabitSummary(
      habit: habit,
      currentStreak: StreakCalculator.currentForFrequency(
        dates,
        frequency,
        now: now,
        gracePeriod: gracePeriod,
      ),
      longestStreak: StreakCalculator.longest(dates),
      isCompletedToday: dates.any((d) => StreakCalculator.isSameDay(d, now)),
      isGoalMetForPeriod: completionsThisPeriod >= frequency.timesPerPeriod,
      completionsThisPeriod: completionsThisPeriod,
      completionRate30d: StreakCalculator.completionRate(dates, now: now),
      completionDates: dates,
    );
  }
}
