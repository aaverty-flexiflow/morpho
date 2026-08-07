import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morpho/features/habits/domain/plant_stage.dart';
import 'package:morpho/features/habits/domain/plant_type.dart';
import 'package:morpho/shared/widgets/plant_view.dart';

void main() {
  // Renders a PlantView in isolation with basic theme scaffolding.
  Future<void> pumpPlant(
    WidgetTester tester, {
    required PlantType type,
    required PlantStage stage,
    int currentStreak = 0,
    Color potColor = const Color(0xFF2D6A4F),
    bool isCompletedToday = false,
    double size = 120,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PlantView(
              type: type,
              stage: stage,
              currentStreak: currentStreak,
              potColor: potColor,
              isCompletedToday: isCompletedToday,
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  group('PlantView rendering', () {
    for (final type in PlantType.values) {
      testWidgets('renders without error for $type at seed stage', (tester) async {
        await pumpPlant(tester, type: type, stage: PlantStage.seed);
        await tester.pump(); // allow animations to initialise
        expect(find.byType(PlantView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('renders without error for $type at legendary stage', (tester) async {
        await pumpPlant(
          tester,
          type: type,
          stage: PlantStage.legendary,
          currentStreak: 100,
          isCompletedToday: true,
        );
        await tester.pump();
        expect(find.byType(PlantView), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('honours the size parameter', (tester) async {
      const targetSize = 80.0;
      await pumpPlant(tester, type: PlantType.fern, stage: PlantStage.young, size: targetSize);
      await tester.pump();

      // PlantView renders a CustomPaint with size (targetSize, targetSize * 1.25).
      final box = tester.renderObject<RenderBox>(find.byType(PlantView));
      expect(box.size.width, closeTo(targetSize, 1.0));
      expect(box.size.height, closeTo(targetSize * 1.25, 1.0));
    });

    testWidgets('idle animation starts and does not throw', (tester) async {
      await pumpPlant(tester, type: PlantType.bamboo, stage: PlantStage.mature, currentStreak: 60);
      // Pump multiple frames to exercise the animation loop.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });
  });
}
