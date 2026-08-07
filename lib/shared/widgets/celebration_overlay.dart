import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Full-screen confetti burst that appears on streak milestones.
///
/// Pure Flutter — no external assets. 60 particles spawn at the tap position
/// (or screen centre) and fall with gravity over 2.5 seconds, then the overlay
/// removes itself.
class CelebrationOverlay {
  static OverlayEntry? _entry;

  /// Show confetti anchored at [origin] (screen coordinates).
  ///
  /// [milestone] = true → full burst (60 particles, 2.5 s) for stage upgrades.
  /// [milestone] = false → light burst (20 particles, 1.2 s) for every check-in.
  /// Safe to call multiple times — replaces any existing overlay.
  static void show(BuildContext context, {Offset? origin, bool milestone = false}) {
    _entry?.remove();

    final overlayState = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _ConfettiWidget(
        origin: origin ?? _screenCenter(context),
        milestone: milestone,
        onDone: () {
          if (_entry == entry) _entry = null;
          entry.remove();
        },
      ),
    );

    _entry = entry;
    overlayState.insert(entry);
  }

  static Offset _screenCenter(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Offset(size.width / 2, size.height * 0.4);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiWidget extends StatefulWidget {
  const _ConfettiWidget({required this.origin, required this.onDone, required this.milestone});

  final Offset origin;
  final VoidCallback onDone;
  final bool milestone;

  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  static const _palette = [
    Color(0xFF52B788),
    Color(0xFFFFD166),
    Color(0xFFEF476F),
    Color(0xFF06D6A0),
    Color(0xFFFFB347),
    Color(0xFF9B59B6),
    Color(0xFF3498DB),
  ];

  @override
  void initState() {
    super.initState();

    final rng = math.Random();
    final count = widget.milestone ? 60 : 20;
    _particles = List.generate(
      count,
      (_) => _Particle(widget.origin, rng, _palette),
    );

    final durationMs = widget.milestone ? 2500 : 1200;
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: durationMs))
      ..forward().whenComplete(() {
        if (mounted) widget.onDone();
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) => CustomPaint(
          size: MediaQuery.sizeOf(context),
          painter: _ConfettiPainter(_particles, _ctrl.value),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Particle {
  _Particle(Offset origin, math.Random rng, List<Color> palette) {
    x = origin.dx;
    y = origin.dy;
    vx = (rng.nextDouble() - 0.5) * 300;
    vy = -(rng.nextDouble() * 350 + 150);
    color = palette[rng.nextInt(palette.length)];
    size = rng.nextDouble() * 7 + 4;
    rotation = rng.nextDouble() * math.pi * 2;
    rotationSpeed = (rng.nextDouble() - 0.5) * 8;
    isCircle = rng.nextBool();
  }

  late double x, y, vx, vy;
  late Color color;
  late double size;
  late double rotation;
  late double rotationSpeed;
  late bool isCircle;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.progress);

  final List<_Particle> particles;
  final double progress;

  // Gravity constant (px/s²)
  static const _gravity = 600.0;
  static const _duration = 2.5; // seconds

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress * _duration;

    for (final p in particles) {
      final px = p.x + p.vx * t;
      final py = p.y + p.vy * t + 0.5 * _gravity * t * t;

      // Fade out in the last third
      final alpha = (1.0 - (progress - 0.66).clamp(0.0, 0.34) / 0.34).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withAlpha((alpha * 255).round());

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      if (p.isCircle) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
