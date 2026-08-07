import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../features/habits/domain/plant_stage.dart';
import '../../features/habits/domain/plant_type.dart';

/// Draws a procedural plant in a ceramic pot, fully animated.
///
/// The painter has no internal state — all animation inputs come from outside
/// (driven by [AnimationController]s in [PlantView]) so Flutter's raster cache
/// can safely skip repaints when nothing changes.
///
/// Coordinate system: origin at top-left, y increases downward.
/// The canonical canvas is 160 × 200 logical pixels; the painter scales
/// proportionally to [size] so it looks sharp on every screen density.
class PlantPainter extends CustomPainter {
  const PlantPainter({
    required this.type,
    required this.stage,
    required this.growthProgress,
    required this.idleOffset,
    required this.potColor,
    required this.isDark,
    this.isCompletedToday = false,
  });

  final PlantType type;
  final PlantStage stage;

  /// Overall growth completeness within the current stage (0.0 → 1.0).
  final double growthProgress;

  /// Sine-wave sway value (−1.0 → 1.0) — makes the plant breathe gently.
  final double idleOffset;

  final Color potColor;
  final bool isDark;

  /// Adds a subtle golden tint to the plant when already done for the day.
  final bool isCompletedToday;

  // ── Constants (relative to canvas) ─────────────────────────────────────────

  static const _potHeightFrac = 0.28;
  static const _potWidthFrac = 0.52;
  static const _soilHeightFrac = 0.04;

  // ── Entry point ──────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    _drawPot(canvas, size);

    if (stage == PlantStage.seed) {
      _drawSeedBump(canvas, size);
      return;
    }

    // Each plant renderer receives a normalised "sway" value that gets
    // smaller near the base and larger near the tip.
    switch (type) {
      case PlantType.fern:
        _drawFern(canvas, size);
      case PlantType.cactus:
        _drawCactus(canvas, size);
      case PlantType.orchid:
        _drawOrchid(canvas, size);
      case PlantType.bonsai:
        _drawBonsai(canvas, size);
      case PlantType.sunflower:
        _drawSunflower(canvas, size);
      case PlantType.bamboo:
        _drawBamboo(canvas, size);
    }

    if (stage == PlantStage.legendary) {
      _drawLegendaryGlow(canvas, size);
    }
  }

  @override
  bool shouldRepaint(PlantPainter old) =>
      old.growthProgress != growthProgress ||
      old.idleOffset != idleOffset ||
      old.stage != stage ||
      old.potColor != potColor ||
      old.isCompletedToday != isCompletedToday;

  // ── Pot & soil ────────────────────────────────────────────────────────────

  void _drawPot(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final potH = size.height * _potHeightFrac;
    final potW = size.width * _potWidthFrac;
    final top = size.height - potH;

    final baseColor = potColor;
    final shadedColor = Color.lerp(baseColor, Colors.black, 0.25)!;

    // Body (slightly tapered trapezoid)
    final body = Path()
      ..moveTo(cx - potW * 0.42, top + potH * 0.10)
      ..lineTo(cx + potW * 0.42, top + potH * 0.10)
      ..lineTo(cx + potW * 0.30, size.height - 2)
      ..lineTo(cx - potW * 0.30, size.height - 2)
      ..close();

    canvas.drawPath(body, Paint()..color = shadedColor);

    // Rim
    final rimRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, top + potH * 0.09),
        width: potW * 0.88,
        height: potH * 0.14,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(rimRect, Paint()..color = baseColor);

    // Soil
    final soilTop = top + potH * 0.16;
    final soilRect = Rect.fromLTRB(
      cx - potW * 0.38,
      soilTop,
      cx + potW * 0.38,
      soilTop + size.height * _soilHeightFrac,
    );
    canvas.drawRect(
      soilRect,
      Paint()..color = isDark ? const Color(0xFF3D2B1F) : const Color(0xFF6B4226),
    );
  }

  void _drawSeedBump(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final potH = size.height * _potHeightFrac;
    final soilY = size.height - potH + potH * 0.20;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, soilY - 2), width: 18, height: 8),
      Paint()
        ..color = (isDark ? const Color(0xFF4A3728) : const Color(0xFF8B5E3C))
            .withAlpha(180),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double get _soilY {
    // Y coordinate of the soil surface (stem anchor point).
    final potH = 1.0 * _potHeightFrac; // fractional; caller multiplies by height
    return 1.0 - potH + potH * 0.20;
  }

  /// Swaying offset at a given height fraction [hf] (0 = root, 1 = tip).
  double _sway(double hf) => idleOffset * 6 * hf * hf;

  Paint _stemPaint([double width = 2.5]) => Paint()
    ..color = isDark ? const Color(0xFF4A7C59) : const Color(0xFF2D6A4F)
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  Paint _leafPaint(Color color, {bool fill = true}) => Paint()
    ..color = isCompletedToday ? Color.lerp(color, const Color(0xFFFFD700), 0.25)! : color
    ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke;

  Color get _leafGreen =>
      isDark ? const Color(0xFF52B788) : const Color(0xFF40916C);

  Color get _darkGreen =>
      isDark ? const Color(0xFF2D6A4F) : const Color(0xFF1B4332);

  void _drawStem(Canvas canvas, Size size, double heightFrac) {
    final cx = size.width / 2;
    final rootY = size.height * _soilY;
    final tipY = rootY - size.height * heightFrac;
    final tipX = cx + _sway(1.0);
    final cpX = cx + _sway(0.5);
    final cpY = (rootY + tipY) / 2;

    final path = Path()
      ..moveTo(cx, rootY)
      ..quadraticBezierTo(cpX, cpY, tipX, tipY);

    canvas.drawPath(path, _stemPaint());
  }

  /// Draws a simple leaf bezier. [side] = 1 for right, −1 for left.
  void _drawLeaf(
    Canvas canvas, {
    required Offset anchor,
    required double angle,
    required double size,
    required Color color,
  }) {
    final tip = Offset(
      anchor.dx + math.cos(angle) * size,
      anchor.dy + math.sin(angle) * size,
    );
    final cp1 = Offset(
      anchor.dx + math.cos(angle - 0.4) * size * 0.6,
      anchor.dy + math.sin(angle - 0.4) * size * 0.6,
    );
    final cp2 = Offset(
      anchor.dx + math.cos(angle + 0.4) * size * 0.6,
      anchor.dy + math.sin(angle + 0.4) * size * 0.6,
    );

    final path = Path()
      ..moveTo(anchor.dx, anchor.dy)
      ..cubicTo(cp1.dx, cp1.dy, tip.dx, tip.dy, tip.dx, tip.dy)
      ..cubicTo(cp2.dx, cp2.dy, anchor.dx, anchor.dy, anchor.dx, anchor.dy)
      ..close();

    canvas.drawPath(path, _leafPaint(color));
  }

  // ── FERN ─────────────────────────────────────────────────────────────────

  void _drawFern(Canvas canvas, Size size) {
    final frondCount = _lerp(1.0, 5.0, growthProgress).round();
    final stemH = _lerp(0.08, 0.50, growthProgress);
    final cx = size.width / 2;
    final rootY = size.height * _soilY;

    for (int i = 0; i < frondCount; i++) {
      final angle = -math.pi / 2 + (i - frondCount / 2 + 0.5) * 0.45;
      final frondLen = size.height * stemH * _lerp(0.6, 1.0, i / frondCount.toDouble());
      final swayAmount = _sway(0.7 + i * 0.1);

      _drawFrond(
        canvas,
        size,
        start: Offset(cx + swayAmount * 0.3, rootY),
        angle: angle + idleOffset * 0.05,
        length: frondLen,
        leafCount: (2 + i * 1.5).round(),
      );
    }
  }

  void _drawFrond(
    Canvas canvas,
    Size size, {
    required Offset start,
    required double angle,
    required double length,
    required int leafCount,
  }) {
    final stem = _stemPaint(1.8);
    final tip = Offset(
      start.dx + math.cos(angle) * length,
      start.dy + math.sin(angle) * length,
    );
    canvas.drawLine(start, tip, stem);

    for (int i = 1; i <= leafCount; i++) {
      final t = i / (leafCount + 1);
      final pos = Offset(
        start.dx + math.cos(angle) * length * t,
        start.dy + math.sin(angle) * length * t,
      );
      final leafAngle = angle + math.pi / 2;
      final leafSize = 10.0 * (1 - t * 0.4);

      _drawLeaf(canvas, anchor: pos, angle: leafAngle - 0.3, size: leafSize, color: _leafGreen);
      _drawLeaf(canvas, anchor: pos, angle: leafAngle + 0.3 + math.pi, size: leafSize, color: _leafGreen);
    }
  }

  // ── CACTUS ────────────────────────────────────────────────────────────────

  void _drawCactus(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final rootY = size.height * _soilY;
    final bodyH = size.height * _lerp(0.08, 0.42, growthProgress);
    final bodyW = size.width * 0.20;
    final swayX = cx + _sway(0.6);

    final cactusColor = isDark ? const Color(0xFF52B788) : const Color(0xFF2D6A4F);
    final spineColor = isDark ? const Color(0xFFD4C5A9) : const Color(0xFFB8A88A);

    // Main barrel
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(swayX, rootY - bodyH / 2),
        width: bodyW,
        height: bodyH,
      ),
      Radius.circular(bodyW * 0.45),
    );
    canvas.drawRRect(barrelRect, Paint()..color = cactusColor);

    // Ribbing lines
    final ribPaint = Paint()
      ..color = _darkGreen.withAlpha(80)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (int r = 1; r <= 3; r++) {
      final rx = swayX - bodyW * 0.5 + bodyW * r / 4;
      canvas.drawLine(Offset(rx, rootY - bodyH + 6), Offset(rx, rootY - 4), ribPaint);
    }

    // Spines (appears from sprout stage)
    if (stage.index >= PlantStage.sprout.index) {
      _drawCactusSpines(canvas, Offset(swayX, rootY), bodyH, bodyW, spineColor);
    }

    // Arms (young+)
    if (stage.index >= PlantStage.young.index && growthProgress > 0.3) {
      final armH = bodyH * 0.35;
      final armW = bodyW * 0.75;
      final armY = rootY - bodyH * 0.60;
      _drawCactusArm(canvas, size, baseX: swayX - bodyW * 0.45, baseY: armY, dir: -1, height: armH, width: armW, color: cactusColor);
    }
    if (stage.index >= PlantStage.mature.index) {
      final armH = bodyH * 0.28;
      final armW = bodyW * 0.65;
      final armY = rootY - bodyH * 0.40;
      _drawCactusArm(canvas, size, baseX: swayX + bodyW * 0.45, baseY: armY, dir: 1, height: armH, width: armW, color: cactusColor);
    }

    // Legendary flower
    if (stage == PlantStage.legendary) {
      _drawCactusFlower(canvas, Offset(swayX, rootY - bodyH - 4));
    }
  }

  void _drawCactusArm(
    Canvas canvas,
    Size size, {
    required double baseX,
    required double baseY,
    required double dir, // −1 left, 1 right
    required double height,
    required double width,
    required Color color,
  }) {
    final armRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(baseX + dir * width / 2, baseY - height / 2),
        width: width,
        height: height,
      ),
      Radius.circular(width * 0.45),
    );
    canvas.drawRRect(armRect, Paint()..color = color);
  }

  void _drawCactusSpines(Canvas canvas, Offset base, double bodyH, double bodyW, Color color) {
    final spinePaint = Paint()
      ..color = color
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;

    final cx = base.dx;
    final rootY = base.dy;

    for (int row = 0; row < 4; row++) {
      final y = rootY - bodyH * 0.2 - bodyH * row * 0.22;
      for (final side in [-1.0, 1.0]) {
        final sx = cx + side * bodyW * 0.48;
        canvas.drawLine(
          Offset(sx, y),
          Offset(sx + side * 4.5, y - 3),
          spinePaint,
        );
      }
    }
  }

  void _drawCactusFlower(Canvas canvas, Offset center) {
    final petalPaint = Paint()..color = const Color(0xFFFF6B9D);
    final centerPaint = Paint()..color = const Color(0xFFFFE066);

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final px = center.dx + math.cos(angle) * 7;
      final py = center.dy + math.sin(angle) * 7;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py), width: 6, height: 9),
        petalPaint,
      );
    }
    canvas.drawCircle(center, 4, centerPaint);
  }

  // ── ORCHID ────────────────────────────────────────────────────────────────

  void _drawOrchid(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final rootY = size.height * _soilY;
    final stemH = size.height * _lerp(0.08, 0.50, growthProgress);

    _drawStem(canvas, size, _lerp(0.08, 0.50, growthProgress));

    final tipX = cx + _sway(1.0);
    final tipY = rootY - stemH;

    // Base leaves (pair)
    if (growthProgress > 0.15) {
      _drawLeaf(canvas, anchor: Offset(cx, rootY - stemH * 0.15), angle: -math.pi * 0.70, size: 22, color: _leafGreen);
      _drawLeaf(canvas, anchor: Offset(cx, rootY - stemH * 0.15), angle: -math.pi * 0.30, size: 22, color: _leafGreen);
    }

    final flowerCount = (growthProgress * 4).floor().clamp(0, 4);
    final orchidColor = isDark ? const Color(0xFFCC88CC) : const Color(0xFF9B59B6);

    for (int i = 0; i < flowerCount; i++) {
      final t = (i + 0.5) / 4;
      final pos = Offset(
        cx + _sway(t) + (i.isEven ? -8.0 : 8.0),
        rootY - stemH * (0.35 + t * 0.55),
      );

      if (stage.index >= PlantStage.mature.index) {
        _drawOrchidFlower(canvas, pos, orchidColor, tipX, tipY);
      } else {
        // Bud
        canvas.drawOval(
          Rect.fromCenter(center: pos, width: 5, height: 8),
          Paint()..color = orchidColor,
        );
      }
    }
  }

  void _drawOrchidFlower(Canvas canvas, Offset center, Color color, double tipX, double tipY) {
    final p = Paint()..color = color;
    final labellum = Paint()..color = const Color(0xFFF9E7FF);

    for (int i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5 - math.pi / 2;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + math.cos(angle) * 6, center.dy + math.sin(angle) * 6),
          width: 7,
          height: 10,
        ),
        p,
      );
    }
    canvas.drawCircle(center, 4, labellum);
  }

  // ── BONSAI ────────────────────────────────────────────────────────────────

  void _drawBonsai(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final rootY = size.height * _soilY;
    final trunkH = size.height * _lerp(0.08, 0.38, growthProgress);
    final trunkW = size.width * _lerp(0.04, 0.10, growthProgress);
    final swayX = cx + _sway(0.4);

    final trunkColor = isDark ? const Color(0xFF8B6914) : const Color(0xFF6B4F12);

    // Trunk (tapered rectangle)
    final trunk = Path()
      ..moveTo(swayX - trunkW / 2, rootY)
      ..lineTo(swayX + trunkW / 2, rootY)
      ..lineTo(swayX + trunkW * 0.25, rootY - trunkH)
      ..lineTo(swayX - trunkW * 0.25, rootY - trunkH)
      ..close();
    canvas.drawPath(trunk, Paint()..color = trunkColor);

    // Branch structure grows with stage
    final branchCount = (growthProgress * 5).round().clamp(2, 5);
    final leafPuffRadius = _lerp(8.0, 18.0, growthProgress);

    for (int i = 0; i < branchCount; i++) {
      final t = (i + 1) / (branchCount + 1);
      final branchY = rootY - trunkH * t;
      final branchX = swayX + (i.isEven ? -1.0 : 1.0) * size.width * 0.14 * t;
      final branchLen = size.width * 0.15 * (1 - t * 0.3);

      final side = (i.isEven ? -1.0 : 1.0);
      final endX = branchX + side * branchLen + _sway(t) * 0.5;
      final endY = branchY - branchLen * 0.5;

      canvas.drawLine(
        Offset(swayX + (i.isEven ? -1.0 : 1.0) * trunkW * 0.2, branchY),
        Offset(endX, endY),
        _stemPaint(trunkW * 0.35),
      );

      // Leaf puff at branch tip
      canvas.drawCircle(
        Offset(endX, endY),
        leafPuffRadius * (0.6 + t * 0.4),
        Paint()..color = _leafGreen.withAlpha(210),
      );
    }

    // Top canopy puff
    canvas.drawCircle(
      Offset(swayX + _sway(1.0), rootY - trunkH - leafPuffRadius * 0.5),
      leafPuffRadius * 1.1,
      Paint()..color = _darkGreen.withAlpha(200),
    );
  }

  // ── SUNFLOWER ─────────────────────────────────────────────────────────────

  void _drawSunflower(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final rootY = size.height * _soilY;
    final stemH = size.height * _lerp(0.08, 0.52, growthProgress);
    final tipX = cx + _sway(1.0);
    final tipY = rootY - stemH;

    _drawStem(canvas, size, _lerp(0.08, 0.52, growthProgress));

    // Stem leaves
    if (growthProgress > 0.3) {
      _drawLeaf(canvas, anchor: Offset(cx + _sway(0.5), rootY - stemH * 0.45), angle: -math.pi * 0.75, size: 16, color: _leafGreen);
      _drawLeaf(canvas, anchor: Offset(cx + _sway(0.5), rootY - stemH * 0.60), angle: -math.pi * 0.25, size: 14, color: _leafGreen);
    }

    if (stage.index < PlantStage.mature.index || growthProgress < 0.5) return;

    // Petals
    final petalCount = stage == PlantStage.legendary ? 16 : 12;
    final headR = size.width * 0.14;
    final petalColor = const Color(0xFFFFC300);

    for (int i = 0; i < petalCount; i++) {
      final angle = i * math.pi * 2 / petalCount;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            tipX + math.cos(angle) * (headR + 6),
            tipY + math.sin(angle) * (headR + 6),
          ),
          width: 7,
          height: 14,
        ),
        Paint()..color = petalColor,
      );
    }

    // Seed head
    canvas.drawCircle(Offset(tipX, tipY), headR, Paint()..color = const Color(0xFF6B3A0F));

    // Seed pattern (legendary)
    if (stage == PlantStage.legendary) {
      final seedPaint = Paint()..color = const Color(0xFF4A2A0A);
      for (int r = 0; r < 3; r++) {
        final count = 4 + r * 4;
        for (int s = 0; s < count; s++) {
          final angle = s * math.pi * 2 / count;
          final dist = (r + 1) * headR / 4;
          canvas.drawCircle(
            Offset(tipX + math.cos(angle) * dist, tipY + math.sin(angle) * dist),
            1.2,
            seedPaint,
          );
        }
      }
    }
  }

  // ── BAMBOO ────────────────────────────────────────────────────────────────

  void _drawBamboo(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final rootY = size.height * _soilY;
    final stalkCount = (growthProgress * 3).ceil().clamp(1, 3);
    final stalkH = size.height * _lerp(0.10, 0.52, growthProgress);
    final stalkW = size.width * 0.065;

    final bambooColor = isDark ? const Color(0xFF74C69D) : const Color(0xFF52B788);
    final nodeColor = isDark ? const Color(0xFF2D6A4F) : const Color(0xFF1B4332);
    final leafColor = _leafGreen;

    const spacing = 0.17;

    for (int s = 0; s < stalkCount; s++) {
      final offset = (s - (stalkCount - 1) / 2.0) * spacing;
      final ox = cx + size.width * offset + _sway(0.5 + s * 0.1) * (0.8 + s * 0.1);
      final segCount = (2 + growthProgress * 3).round().clamp(2, 5);
      final segH = stalkH / segCount;

      for (int seg = 0; seg < segCount; seg++) {
        final segY = rootY - segH * seg;
        final rect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(ox, segY - segH / 2),
            width: stalkW,
            height: segH - 2,
          ),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, Paint()..color = bambooColor);

        // Node ring
        canvas.drawLine(
          Offset(ox - stalkW / 2, segY - 2),
          Offset(ox + stalkW / 2, segY - 2),
          Paint()
            ..color = nodeColor
            ..strokeWidth = 1.5,
        );

        // Leaves at each node (except root segment)
        if (seg > 0 && seg % 2 == 0) {
          _drawBambooLeaf(canvas, Offset(ox + stalkW / 2, segY - 4), 1, leafColor);
          _drawBambooLeaf(canvas, Offset(ox - stalkW / 2, segY - 4), -1, leafColor);
        }
      }
    }
  }

  void _drawBambooLeaf(Canvas canvas, Offset base, double side, Color color) {
    final angle = side > 0 ? -math.pi * 0.2 : -math.pi * 0.8;
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx + math.cos(angle) * 14,
        base.dy + math.sin(angle) * 14,
        base.dx + math.cos(angle) * 22,
        base.dy + math.sin(angle) * 22,
      )
      ..quadraticBezierTo(
        base.dx + math.cos(angle + 0.3) * 10,
        base.dy + math.sin(angle + 0.3) * 10,
        base.dx,
        base.dy,
      )
      ..close();

    canvas.drawPath(path, Paint()..color = color);
  }

  // ── Legendary glow ────────────────────────────────────────────────────────

  void _drawLegendaryGlow(Canvas canvas, Size size) {
    final cx = size.width / 2 + _sway(0.8);
    final cy = size.height * 0.35;

    // Pulsing golden particle ring — uses idleOffset to animate.
    final rng = math.Random(42);
    const particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = i * math.pi * 2 / particleCount + idleOffset * 0.4;
      final r = 28.0 + rng.nextDouble() * 8 + math.sin(idleOffset + i) * 4;
      final px = cx + math.cos(angle) * r;
      final py = cy + math.sin(angle) * r;
      final alpha = (0.5 + math.sin(idleOffset * 2 + i) * 0.3).clamp(0.2, 0.9);

      canvas.drawCircle(
        Offset(px, py),
        1.5 + rng.nextDouble(),
        Paint()..color = const Color(0xFFFFD700).withAlpha((alpha * 255).round()),
      );
    }
  }

  // ── Lerp helper ───────────────────────────────────────────────────────────

  static double _lerp(double a, double b, double t) => a + (b - a) * t.clamp(0.0, 1.0);
}
