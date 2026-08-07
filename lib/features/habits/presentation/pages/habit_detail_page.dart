import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:morpho/i18n/strings.g.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/data/habits_provider.dart';
import '../../../../features/habits/domain/habit_summary.dart';
import '../../../../features/habits/domain/plant_stage.dart';
import '../../../../features/habits/domain/streak_calculator.dart';
import '../../../../shared/widgets/celebration_overlay.dart';
import '../../../../shared/widgets/plant_view.dart';

/// Full habit detail — larger plant, streak stats, 30-day heatmap, actions.
class HabitDetailPage extends ConsumerWidget {
  const HabitDetailPage({super.key, required this.habitId});

  final int habitId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(habitSummariesProvider);

    return summariesAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text(t.common.error(error: e)))),
      data: (summaries) {
        final summary = summaries.where((s) => s.habit.id == habitId).firstOrNull;
        if (summary == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.pop();
          });
          return const Scaffold(body: SizedBox.shrink());
        }

        return _HabitDetailView(summary: summary);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HabitDetailView extends ConsumerWidget {
  const _HabitDetailView({required this.summary});

  final HabitSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habit = summary.habit;
    final potColor = Color(habit.colorValue);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(habit.name),
        actions: [
          _ActionMenu(summary: summary),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Big plant ─────────────────────────────────────────────────
                Center(
                  child: PlantView(
                    type: habit.plantType,
                    stage: summary.stage,
                    currentStreak: summary.currentStreak,
                    potColor: potColor,
                    isCompletedToday: summary.isCompletedToday,
                    size: 180,
                  ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
                ),
                const Gap(8),

                // ── Stage label ────────────────────────────────────────────────
                Center(
                  child: _StageChip(stage: summary.stage, color: potColor),
                ),
                const Gap(24),

                // ── Stats row ─────────────────────────────────────────────────
                _StatsRow(summary: summary, potColor: potColor),
                const Gap(24),

                // ── Check-in button ───────────────────────────────────────────
                if (!summary.isCompletedToday)
                  _CheckInBanner(summary: summary, potColor: potColor)
                else
                  _CompletedBanner(potColor: potColor),

                const Gap(24),

                // ── 30-day heatmap ─────────────────────────────────────────────
                Text(t.habitDetail.last30Days, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                const Gap(10),
                _HeatmapGrid(completionDates: summary.completionDates),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StageChip extends StatelessWidget {
  const _StageChip({required this.stage, required this.color});
  final PlantStage stage;
  final Color color;

  String _label() {
    switch (stage) {
      case PlantStage.seed:
        return t.plantStage.seed;
      case PlantStage.sprout:
        return t.plantStage.sprout;
      case PlantStage.young:
        return t.plantStage.young;
      case PlantStage.mature:
        return t.plantStage.mature;
      case PlantStage.legendary:
        return t.plantStage.legendary;
    }
  }

  @override
  Widget build(BuildContext context) => Chip(
        label: Text(_label()),
        backgroundColor: color.withAlpha(25),
        labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
        side: BorderSide(color: color.withAlpha(60)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary, required this.potColor});
  final HabitSummary summary;
  final Color potColor;

  @override
  Widget build(BuildContext context) {
    final pct = (summary.completionRate30d * 100).round();

    return Row(
      children: [
        _StatCard(
          label: t.habitDetail.statStreak,
          value: '${summary.currentStreak}${t.frequency.streakUnitDay}',
          icon: Icons.local_fire_department_rounded,
          color: potColor,
        ),
        const Gap(10),
        _StatCard(
          label: t.habitDetail.statRecord,
          value: '${summary.longestStreak}${t.frequency.streakUnitDay}',
          icon: Icons.emoji_events_rounded,
          color: AppColors.amber700,
        ),
        const Gap(10),
        _StatCard(
          label: t.habitDetail.statRate,
          value: '$pct%',
          icon: Icons.bar_chart_rounded,
          color: AppColors.green500,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const Gap(6),
            Text(value,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: color)),
            const Gap(2),
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(130),
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CheckInBanner extends ConsumerWidget {
  const _CheckInBanner({required this.summary, required this.potColor});
  final HabitSummary summary;
  final Color potColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FilledButton.icon(
      onPressed: () async {
        final notifier = ref.read(habitsNotifierProvider.notifier);
        final wasNew = await notifier.checkIn(summary.habit.id!);

        if (!wasNew || !context.mounted) return;

        final newStreak = summary.currentStreak + 1;
        final newStage = PlantStage.fromStreak(newStreak);
        final isMilestone = newStage != summary.stage && newStage.isMilestone;
        CelebrationOverlay.show(context, milestone: isMilestone);
      },
      icon: const Icon(Icons.check_circle_outline_rounded),
      label: Text(t.habitDetail.checkIn),
      style: FilledButton.styleFrom(backgroundColor: potColor),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.potColor});
  final Color potColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: potColor.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: potColor.withAlpha(60)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: potColor, size: 20),
          const Gap(8),
          Text(
            t.habitDetail.completedToday,
            style: TextStyle(color: potColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().scale(begin: const Offset(0.96, 0.96), curve: Curves.elasticOut);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// 30-day calendar grid showing which days were completed (coloured) or missed.
class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.completionDates});

  final List<DateTime> completionDates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final today = DateTime.now();
    final days = List.generate(30, (i) => today.subtract(Duration(days: 29 - i)));

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: days.map((day) {
        final done = completionDates.any((d) => StreakCalculator.isSameDay(d, day));
        final isToday = StreakCalculator.isSameDay(day, today);

        return Tooltip(
          message: '${day.day}/${day.month}${done ? ' ✓' : ''}',
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.green500.withAlpha(isDark ? 180 : 200)
                  : (isDark ? AppColors.surface2Dark : AppColors.surface2Light),
              borderRadius: BorderRadius.circular(6),
              border: isToday ? Border.all(color: AppColors.green700, width: 1.5) : null,
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ActionMenu extends ConsumerWidget {
  const _ActionMenu({required this.summary});
  final HabitSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return IconButton(
        icon: const Icon(Icons.more_horiz_rounded),
        onPressed: () => _showCupertinoSheet(context, ref),
      );
    }
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(context, ref, value),
      itemBuilder: (_) => [
        if (summary.isCompletedToday)
          PopupMenuItem(value: 'undo', child: Text(t.habitDetail.undoCheckIn)),
        PopupMenuItem(value: 'archive', child: Text(t.habitDetail.archive)),
        PopupMenuItem(
          value: 'delete',
          child: Text(t.common.delete, style: const TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String value) async {
    switch (value) {
      case 'undo':
        await ref.read(habitsNotifierProvider.notifier).undoCheckIn(summary.habit.id!);
      case 'archive':
        await ref.read(habitsNotifierProvider.notifier).archiveHabit(summary.habit.id!);
        if (context.mounted) context.pop();
      case 'delete':
        final confirmed = await _confirmDelete(context);
        if (confirmed && context.mounted) {
          await NotificationService.cancel(summary.habit.id!);
          await ref.read(habitsNotifierProvider.notifier).deleteHabit(summary.habit.id!);
          if (context.mounted) context.pop();
        }
    }
  }

  Future<void> _showCupertinoSheet(BuildContext context, WidgetRef ref) async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          if (summary.isCompletedToday)
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await _handleAction(context, ref, 'undo');
              },
              child: Text(t.habitDetail.undoCheckIn),
            ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _handleAction(context, ref, 'archive');
            },
            child: Text(t.habitDetail.archive),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _handleAction(context, ref, 'delete');
            },
            child: Text(t.common.delete),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(t.common.cancel),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: Text(t.habitDetail.deleteTitle),
              content: Text(t.habitDetail.deleteBody),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(t.common.cancel),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(t.common.delete),
                ),
              ],
            ),
          ) ??
          false;
    }
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.habitDetail.deleteTitle),
            content: Text(t.habitDetail.deleteBody),
            actions: [
              TextButton(onPressed: () => ctx.pop(false), child: Text(t.common.cancel)),
              FilledButton(
                onPressed: () => ctx.pop(true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: Text(t.common.delete),
              ),
            ],
          ),
        ) ??
        false;
  }
}
