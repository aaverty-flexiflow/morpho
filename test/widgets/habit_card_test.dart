import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morpho/features/habits/domain/habit.dart';
import 'package:morpho/features/habits/domain/habit_summary.dart';
import 'package:morpho/features/habits/domain/plant_type.dart';
import 'package:morpho/features/habits/presentation/widgets/habit_card.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

Habit _makeHabit({int id = 1, String name = 'Méditation'}) {
  return Habit(
    id: id,
    name: name,
    emoji: '🧘',
    colorValue: const Color(0xFF2D6A4F).toARGB32(),
    plantType: PlantType.fern,
    createdAt: DateTime(2024, 1, 1),
  );
}

HabitSummary _makeSummary({
  String name = 'Méditation',
  bool isCompletedToday = false,
  int currentStreak = 0,
}) {
  final habit = _makeHabit(name: name);
  final today = DateTime.now();
  final dates = isCompletedToday
      ? [today, ...List.generate(currentStreak - 1, (i) => today.subtract(Duration(days: i + 1)))]
      : List.generate(currentStreak, (i) => today.subtract(Duration(days: i + 1)));

  return HabitSummary.compute(habit, dates);
}

// ─── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  Future<void> pumpCard(
    WidgetTester tester,
    HabitSummary summary, {
    void Function(Offset)? onCheckIn,
    VoidCallback? onTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 280,
            child: HabitCard(
              summary: summary,
              onCheckIn: onCheckIn ?? (_) {},
              onTap: onTap ?? () {},
            ),
          ),
        ),
      ),
    );
    // Advance past entry animations without waiting for the infinite idle loop.
    await tester.pump(const Duration(milliseconds: 700));
  }

  group('HabitCard display', () {
    testWidgets('shows the habit name', (tester) async {
      final summary = _makeSummary(name: 'Sport');
      await pumpCard(tester, summary);
      expect(find.text('Sport'), findsOneWidget);
    });

    testWidgets('shows "Commencer" when streak is 0', (tester) async {
      final summary = _makeSummary(currentStreak: 0);
      await pumpCard(tester, summary);
      expect(find.text('Commencer'), findsOneWidget);
    });

    testWidgets('shows streak days when streak > 0', (tester) async {
      final summary = _makeSummary(currentStreak: 5, isCompletedToday: true);
      await pumpCard(tester, summary);
      // The badge shows e.g. "5 j"
      expect(find.textContaining('j'), findsWidgets);
    });

    testWidgets('check button changes icon when completed', (tester) async {
      final completedSummary = _makeSummary(isCompletedToday: true, currentStreak: 1);
      await pumpCard(tester, completedSummary);
      // When completed, the button shows a check icon (Icons.check_rounded).
      expect(find.byIcon(Icons.check_rounded), findsWidgets);
    });
  });

  group('HabitCard interactions', () {
    testWidgets('tapping the card triggers onTap', (tester) async {
      var tapped = false;
      final summary = _makeSummary();
      await pumpCard(tester, summary, onTap: () => tapped = true);

      await tester.tap(find.byType(HabitCard));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tapped, isTrue);
    });

    testWidgets('tapping check-in button triggers onCheckIn', (tester) async {
      Offset? receivedOffset;
      final summary = _makeSummary(currentStreak: 0, isCompletedToday: false);

      await pumpCard(tester, summary, onCheckIn: (offset) => receivedOffset = offset);

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump(const Duration(milliseconds: 100));
      expect(receivedOffset, isNotNull);
    });
  });
}
