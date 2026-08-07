import 'package:flutter_test/flutter_test.dart';
import 'package:morpho/features/habits/domain/plant_stage.dart';

void main() {
  group('PlantStage.fromStreak', () {
    test('0 → seed', () => expect(PlantStage.fromStreak(0), PlantStage.seed));
    test('negative → seed', () => expect(PlantStage.fromStreak(-5), PlantStage.seed));
    test('1 → sprout', () => expect(PlantStage.fromStreak(1), PlantStage.sprout));
    test('6 → sprout', () => expect(PlantStage.fromStreak(6), PlantStage.sprout));
    test('7 → young', () => expect(PlantStage.fromStreak(7), PlantStage.young));
    test('29 → young', () => expect(PlantStage.fromStreak(29), PlantStage.young));
    test('30 → mature', () => expect(PlantStage.fromStreak(30), PlantStage.mature));
    test('99 → mature', () => expect(PlantStage.fromStreak(99), PlantStage.mature));
    test('100 → legendary', () => expect(PlantStage.fromStreak(100), PlantStage.legendary));
    test('1000 → legendary', () => expect(PlantStage.fromStreak(1000), PlantStage.legendary));
  });

  // ───────────────────────────────────────────────────────────────────────────

  group('PlantStage.isMilestone', () {
    test('seed is not a milestone', () => expect(PlantStage.seed.isMilestone, isFalse));
    test('sprout is a milestone', () => expect(PlantStage.sprout.isMilestone, isTrue));
    test('young is a milestone', () => expect(PlantStage.young.isMilestone, isTrue));
    test('mature is a milestone', () => expect(PlantStage.mature.isMilestone, isTrue));
    test('legendary is a milestone', () => expect(PlantStage.legendary.isMilestone, isTrue));
  });

  // ───────────────────────────────────────────────────────────────────────────

  group('PlantStage.totalProgress', () {
    test('seed at 0 → 0.0', () {
      expect(PlantStage.seed.totalProgress(0), closeTo(0.0, 0.001));
    });

    test('progress never exceeds 1.0', () {
      expect(PlantStage.legendary.totalProgress(99999), lessThanOrEqualTo(1.0));
    });

    test('progress is monotonically increasing across stage boundaries', () {
      final values = [0, 1, 6, 7, 29, 30, 99, 100, 200].map((streak) {
        return PlantStage.fromStreak(streak).totalProgress(streak);
      }).toList();

      for (int i = 1; i < values.length; i++) {
        expect(values[i], greaterThanOrEqualTo(values[i - 1]),
            reason: 'Progress should not decrease at index $i');
      }
    });

    test('mid-streak progress within a stage is between stage bounds', () {
      // At streak 15 (young stage, min=7 max=29), progress should be > seed+sprout weight.
      final p = PlantStage.young.totalProgress(15);
      expect(p, greaterThan(0.10)); // past seed (0%) + sprout (10%)
      expect(p, lessThan(0.35)); // not yet in mature territory
    });
  });
}
