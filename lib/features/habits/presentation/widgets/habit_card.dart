import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morpho/i18n/strings.g.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/domain/habit_frequency.dart';
import '../../../../features/habits/domain/habit_summary.dart';
import '../../../../shared/widgets/plant_view.dart';

/// A single habit card for the garden grid.
///
/// Shows the plant, habit name, streak badge, and a check-in button.
/// The card itself is a [ConsumerWidget] so it re-renders independently
/// when its [summary] changes — other cards are unaffected.
class HabitCard extends StatelessWidget {
  const HabitCard({
    super.key,
    required this.summary,
    required this.onCheckIn,
    required this.onTap,
  });

  final HabitSummary summary;

  /// Called when the user taps the check-in button.
  /// Returns an [Offset] in global coordinates so the caller can anchor
  /// the celebration overlay at the right place on screen.
  final void Function(Offset tapPosition) onCheckIn;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habit = summary.habit;
    final potColor = Color(habit.colorValue);

    final cardBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final goalMet = summary.isGoalMetForPeriod;
    final borderColor = goalMet
        ? potColor.withAlpha(100)
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: goalMet ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // ── Plant ──────────────────────────────────────────────────────
            Expanded(
              child: _PlantPopAnimator(
                goalMet: goalMet,
                child: PlantView(
                  type: habit.plantType,
                  stage: summary.stage,
                  currentStreak: summary.currentStreak,
                  potColor: potColor,
                  isCompletedToday: goalMet,
                  size: 96,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ── Name ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                habit.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 4),

            // ── Streak / progress badge ───────────────────────────────────
            _StreakBadge(
              streak: summary.currentStreak,
              color: potColor,
              frequency: habit.frequency,
              completionsThisPeriod: summary.completionsThisPeriod,
              isGoalMet: goalMet,
            ),

            const SizedBox(height: 10),

            // ── Check-in button ───────────────────────────────────────────
            _CheckInButton(
              isCompleted: goalMet,
              // Disable if already checked in today OR quota already met.
              isEnabled: !summary.isCompletedToday && !goalMet,
              potColor: potColor,
              onTap: onCheckIn,
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({
    required this.streak,
    required this.color,
    required this.frequency,
    required this.completionsThisPeriod,
    required this.isGoalMet,
  });

  final int streak;
  final Color color;
  final HabitFrequency frequency;
  final int completionsThisPeriod;
  final bool isGoalMet;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall;

    if (frequency.isDaily) {
      // Daily: show streak in days or "Get started".
      if (streak == 0) {
        return Text(
          t.habitCard.start,
          style: textStyle?.copyWith(color: AppColors.textTertiaryLight),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, size: 13, color: color),
          const SizedBox(width: 3),
          Text(
            '$streak ${t.frequency.streakUnitDay}',
            style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    // Non-daily: show quota progress when goal not yet met for this period.
    if (!isGoalMet) {
      final progress = '$completionsThisPeriod/${frequency.timesPerPeriod}';
      if (completionsThisPeriod == 0) {
        return Text(
          t.habitCard.start,
          style: textStyle?.copyWith(color: AppColors.textTertiaryLight),
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radio_button_checked, size: 12, color: color.withAlpha(160)),
          const SizedBox(width: 3),
          Text(
            progress,
            style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    // Goal met: show streak in weeks.
    if (streak == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            t.habitCard.thisWeekDone,
            style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.local_fire_department_rounded, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          '$streak ${frequency.streakUnit}',
          style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CheckInButton extends StatefulWidget {
  const _CheckInButton({
    required this.isCompleted,
    required this.isEnabled,
    required this.potColor,
    required this.onTap,
  });

  final bool isCompleted;

  /// When false the button is greyed out and non-interactive.
  /// This covers both "already checked in today" and "quota already met".
  final bool isEnabled;
  final Color potColor;
  final void Function(Offset tapPosition) onTap;

  @override
  State<_CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<_CheckInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details) {
    if (!widget.isEnabled) return;
    _pressCtrl.forward().then((_) => _pressCtrl.reverse());
    widget.onTap(details.globalPosition);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        widget.isEnabled ? widget.potColor : widget.potColor.withAlpha(80);

    return GestureDetector(
      onTapUp: widget.isEnabled ? _handleTap : null,
      onTapDown: widget.isEnabled ? (_) => _pressCtrl.forward() : null,
      onTapCancel: widget.isEnabled ? () => _pressCtrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isCompleted
                ? effectiveColor
                : effectiveColor.withAlpha(30),
            border: Border.all(
              color: effectiveColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.isCompleted ? Icons.check_rounded : Icons.add_rounded,
            size: 18,
            color: widget.isCompleted ? Colors.white : effectiveColor,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Plays a small elastic-scale pop when [goalMet] flips false → true,
/// keeping the [child] alive (no remount) across the transition.
class _PlantPopAnimator extends StatefulWidget {
  const _PlantPopAnimator({required this.goalMet, required this.child});

  final bool goalMet;
  final Widget child;

  @override
  State<_PlantPopAnimator> createState() => _PlantPopAnimatorState();
}

class _PlantPopAnimatorState extends State<_PlantPopAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    if (widget.goalMet) {
      _ctrl.forward(from: 0);
    } else {
      _ctrl.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_PlantPopAnimator old) {
    super.didUpdateWidget(old);
    if (widget.goalMet && !old.goalMet) {
      _ctrl.forward(from: 0);
    } else if (!widget.goalMet && old.goalMet) {
      _ctrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      child: widget.child,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
    );
  }
}
