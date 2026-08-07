import 'package:flutter/material.dart';

import '../../features/habits/domain/plant_stage.dart';
import '../../features/habits/domain/plant_type.dart';
import '../painters/plant_painter.dart';

/// Animated plant widget — drives the idle sway and growth transition.
///
/// Uses a [RepaintBoundary] so the animated canvas doesn't trigger repaints
/// on sibling widgets (critical in the garden grid with many plants).
class PlantView extends StatefulWidget {
  const PlantView({
    super.key,
    required this.type,
    required this.stage,
    required this.currentStreak,
    required this.potColor,
    this.isCompletedToday = false,
    this.size = 120,
  });

  final PlantType type;
  final PlantStage stage;
  final int currentStreak;
  final Color potColor;
  final bool isCompletedToday;

  /// Logical size of the square canvas. Pass smaller values in compact grids.
  final double size;

  @override
  State<PlantView> createState() => _PlantViewState();
}

class _PlantViewState extends State<PlantView> with TickerProviderStateMixin {
  late AnimationController _idleCtrl;
  late AnimationController _growthCtrl;
  late Animation<double> _idleAnim;
  late Animation<double> _growthAnim;
  late double _growthTarget;

  @override
  void initState() {
    super.initState();

    _growthTarget = _computeTarget();

    // Gentle 4 s sway loop
    _idleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _idleAnim = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _idleCtrl, curve: Curves.easeInOut),
    );

    // Growth bounce when streak crosses a stage boundary
    _growthCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _growthAnim = Tween<double>(begin: _growthTarget * 0.85, end: _growthTarget).animate(
      CurvedAnimation(parent: _growthCtrl, curve: Curves.elasticOut),
    );

    _growthCtrl.forward();
  }

  @override
  void didUpdateWidget(PlantView old) {
    super.didUpdateWidget(old);

    final newTarget = _computeTarget();
    if (newTarget != _growthTarget) {
      _growthAnim = Tween<double>(begin: _growthTarget, end: newTarget).animate(
        CurvedAnimation(parent: _growthCtrl, curve: Curves.elasticOut),
      );
      _growthTarget = newTarget;
      _growthCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _idleCtrl.dispose();
    _growthCtrl.dispose();
    super.dispose();
  }

  double _computeTarget() =>
      widget.stage.totalProgress(widget.currentStreak);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ExcludeSemantics: the CustomPaint has no accessible content; excluding it
    // also prevents a Flutter semantics assertion when many RepaintBoundary
    // widgets are reparented simultaneously (e.g. clearing all entries).
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: Listenable.merge([_idleAnim, _growthAnim]),
          builder: (context, _) => CustomPaint(
            size: Size(widget.size, widget.size * 1.25),
            painter: PlantPainter(
              type: widget.type,
              stage: widget.stage,
              growthProgress: _growthAnim.value,
              idleOffset: _idleAnim.value,
              potColor: widget.potColor,
              isDark: isDark,
              isCompletedToday: widget.isCompletedToday,
            ),
          ),
        ),
      ),
    );
  }
}
