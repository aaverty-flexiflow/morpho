import 'package:flutter_test/flutter_test.dart';
import 'package:morpho/features/habits/domain/streak_calculator.dart';

void main() {
  // Helper: build a list of DateTime values for [n] consecutive days ending today.
  List<DateTime> consecutiveDays(int n, {DateTime? endDate}) {
    final base = endDate ?? DateTime.now();
    return List.generate(n, (i) => base.subtract(Duration(days: i)));
  }

  // Helper: single date for a specific day relative to [now].
  DateTime daysAgo(int days, {DateTime? now}) =>
      (now ?? DateTime.now()).subtract(Duration(days: days));

  group('StreakCalculator.current', () {
    test('returns 0 for empty list', () {
      expect(StreakCalculator.current([]), 0);
    });

    test('returns 1 when only today is completed', () {
      final now = DateTime(2024, 6, 15);
      expect(StreakCalculator.current([now], now: now), 1);
    });

    test('returns 0 when only yesterday is completed (no grace)', () {
      final now = DateTime(2024, 6, 15);
      final yesterday = DateTime(2024, 6, 14);
      expect(StreakCalculator.current([yesterday], now: now), 0);
    });

    test('returns 1 when only yesterday is completed with grace period', () {
      final now = DateTime(2024, 6, 15);
      final yesterday = DateTime(2024, 6, 14);
      expect(
        StreakCalculator.current([yesterday], now: now, gracePeriod: true),
        1,
      );
    });

    test('counts a 5-day streak correctly', () {
      final now = DateTime(2024, 6, 15);
      final dates = consecutiveDays(5, endDate: now);
      expect(StreakCalculator.current(dates, now: now), 5);
    });

    test('streak breaks on a 2-day gap (no grace)', () {
      final now = DateTime(2024, 6, 15);
      final dates = [
        now, // day 0
        daysAgo(1, now: now), // day 1
        // day 2 missing
        daysAgo(3, now: now), // day 3
        daysAgo(4, now: now),
      ];
      expect(StreakCalculator.current(dates, now: now), 2);
    });

    test('grace period bridges exactly one skipped day', () {
      final now = DateTime(2024, 6, 15);
      final dates = [
        now,
        daysAgo(1, now: now),
        // day 2 skipped — grace absorbs this
        daysAgo(3, now: now),
        daysAgo(4, now: now),
      ];
      expect(StreakCalculator.current(dates, now: now, gracePeriod: true), 4);
    });

    test('grace period consumed: second gap breaks streak', () {
      final now = DateTime(2024, 6, 15);
      final dates = [
        now,
        daysAgo(1, now: now),
        // day 2 skipped — grace consumed here
        daysAgo(3, now: now),
        // day 4 skipped — no grace remaining, break before day-5
        daysAgo(5, now: now),
      ];
      // Grace bridges day-2: streak includes day-0, day-1, day-3 = 3 actual days.
      expect(StreakCalculator.current(dates, now: now, gracePeriod: true), 3);
    });

    test('duplicate entries on same day count as one', () {
      final now = DateTime(2024, 6, 15);
      // Multiple check-ins during the same calendar day.
      final dates = [
        DateTime(2024, 6, 15, 8, 0),
        DateTime(2024, 6, 15, 20, 0),
        DateTime(2024, 6, 14, 9, 0),
      ];
      expect(StreakCalculator.current(dates, now: now), 2);
    });

    test('returns 0 when last completion was 2 days ago (no grace)', () {
      final now = DateTime(2024, 6, 15);
      final dates = [
        daysAgo(2, now: now),
        daysAgo(3, now: now),
        daysAgo(4, now: now),
      ];
      expect(StreakCalculator.current(dates, now: now), 0);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────

  group('StreakCalculator.longest', () {
    test('returns 0 for empty list', () {
      expect(StreakCalculator.longest([]), 0);
    });

    test('returns 1 for a single entry', () {
      expect(StreakCalculator.longest([DateTime.now()]), 1);
    });

    test('finds the longest run when there are two separate streaks', () {
      final base = DateTime(2024, 6, 15);
      final dates = [
        // Streak of 2: days 0, 1
        base,
        base.subtract(const Duration(days: 1)),
        // Gap at day 2
        // Streak of 3: days 3, 4, 5
        base.subtract(const Duration(days: 3)),
        base.subtract(const Duration(days: 4)),
        base.subtract(const Duration(days: 5)),
      ];
      expect(StreakCalculator.longest(dates), 3);
    });

    test('handles a perfectly continuous history', () {
      final base = DateTime(2024, 6, 15);
      final dates = List.generate(30, (i) => base.subtract(Duration(days: i)));
      expect(StreakCalculator.longest(dates), 30);
    });
  });

  // ───────────────────────────────────────────────────────────────────────────

  group('StreakCalculator.isSameDay', () {
    test('same day at different times returns true', () {
      expect(
        StreakCalculator.isSameDay(
          DateTime(2024, 6, 15, 8, 0),
          DateTime(2024, 6, 15, 23, 59),
        ),
        isTrue,
      );
    });

    test('different days return false', () {
      expect(
        StreakCalculator.isSameDay(
          DateTime(2024, 6, 15),
          DateTime(2024, 6, 16),
        ),
        isFalse,
      );
    });
  });

  // ───────────────────────────────────────────────────────────────────────────

  group('StreakCalculator.completionRate', () {
    test('returns 0.0 for empty list', () {
      expect(StreakCalculator.completionRate([]), 0.0);
    });

    test('returns 0.0 for window of 0', () {
      expect(StreakCalculator.completionRate([], windowDays: 0), 0.0);
    });

    test('all 30 days completed → rate of 1.0', () {
      final now = DateTime(2024, 6, 15);
      final dates = List.generate(30, (i) => now.subtract(Duration(days: i)));
      expect(
        StreakCalculator.completionRate(dates, now: now, windowDays: 30),
        closeTo(1.0, 0.001),
      );
    });

    test('15 out of 30 days completed → rate of 0.5', () {
      final now = DateTime(2024, 6, 15);
      final dates = List.generate(15, (i) => now.subtract(Duration(days: i)));
      expect(
        StreakCalculator.completionRate(dates, now: now, windowDays: 30),
        closeTo(0.5, 0.001),
      );
    });

    test('completions outside the window are ignored', () {
      final now = DateTime(2024, 6, 15);
      // Only completions more than 30 days ago.
      final dates = List.generate(5, (i) => now.subtract(Duration(days: 31 + i)));
      expect(
        StreakCalculator.completionRate(dates, now: now, windowDays: 30),
        0.0,
      );
    });
  });
}
