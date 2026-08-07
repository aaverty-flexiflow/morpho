/// Growth stages that map a streak length to a visual complexity level.
///
/// Each stage boundary is a milestone the user can celebrate. The [totalProgress]
/// value (0.0–1.0) is used by [PlantPainter] to interpolate drawing complexity
/// within the stage — it never resets to 0 so the plant always appears to grow.
enum PlantStage {
  seed(minStreak: 0, maxStreak: 0),
  sprout(minStreak: 1, maxStreak: 6),
  young(minStreak: 7, maxStreak: 29),
  mature(minStreak: 30, maxStreak: 99),
  legendary(minStreak: 100, maxStreak: 999999);

  const PlantStage({required this.minStreak, required this.maxStreak});

  final int minStreak;
  final int maxStreak;

  /// Maps [streak] to the correct stage.
  static PlantStage fromStreak(int streak) {
    if (streak <= 0) return seed;
    if (streak < 7) return sprout;
    if (streak < 30) return young;
    if (streak < 100) return mature;
    return legendary;
  }

  /// A monotonically increasing value across all stages (0.0 to ~1.0).
  ///
  /// Used by the painter to smoothly interpolate detail as the streak grows,
  /// rather than jumping abruptly at stage boundaries.
  double totalProgress(int streak) {
    // Each stage occupies a proportional slice of the 0.0–1.0 range.
    const weights = [0.0, 0.10, 0.25, 0.35, 0.30]; // seed/sprout/young/mature/legendary

    double base = 0.0;
    for (int i = 0; i < index; i++) {
      base += weights[i];
    }

    final span = (maxStreak - minStreak).clamp(1, 999999);
    final progress = ((streak - minStreak) / span).clamp(0.0, 1.0);
    return (base + progress * weights[index]).clamp(0.0, 1.0);
  }

  /// Whether crossing into this stage should trigger a celebration overlay.
  bool get isMilestone => this == sprout || this == young || this == mature || this == legendary;
}
