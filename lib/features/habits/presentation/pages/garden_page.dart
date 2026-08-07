import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:morpho/i18n/strings.g.dart';

import '../../../../core/debug/debug_panel.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/data/habits_provider.dart';
import '../../../../features/habits/domain/habit_summary.dart';
import '../../../../features/habits/domain/plant_stage.dart';
import '../../../../shared/widgets/celebration_overlay.dart';
import '../widgets/add_habit_sheet.dart';
import '../widgets/habit_card.dart';

/// The main screen — a responsive grid of living plant cards.
///
/// Adapts column count to screen width (compact: 2, medium: 3, expanded: 4)
/// and shows an empty state when no habits have been created yet.
class GardenPage extends ConsumerWidget {
  const GardenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(habitSummariesProvider);

    return Scaffold(
      appBar: _AppBar(),
      floatingActionButton: _Fab(),
      body: summariesAsync.when(
        loading: () => const _LoadingGrid(),
        error: (e, _) => _ErrorState(error: e),
        data: (summaries) => summaries.isEmpty
            ? const _EmptyState()
            : _GardenGrid(summaries: summaries),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _AppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summariesAsync = ref.watch(habitSummariesProvider);
    final doneToday = summariesAsync.value?.where((s) => s.isCompletedToday).length ?? 0;
    final total = summariesAsync.value?.length ?? 0;

    final greeting = _greeting();

    return AppBar(
      title: GestureDetector(
        onLongPress: kDebugMode ? () => showDebugPanel(context) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greeting,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (total > 0)
              Text(
                t.garden.todayProgress(done: doneToday, total: total),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
                    ),
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          tooltip: t.garden.settingsTooltip,
          onPressed: () => context.push('/settings'),
        ),
      ],
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.garden.greetingMorning;
    if (hour < 18) return t.garden.greetingDay;
    return t.garden.greetingEvening;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GardenGrid extends ConsumerWidget {
  const _GardenGrid({required this.summaries});

  final List<HabitSummary> summaries;

  // Number of columns depends on available width.
  static int _columnCount(double width) {
    if (width >= 840) return 4;
    if (width >= 560) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = _columnCount(width);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              // Slightly taller than wide to accommodate plant + info.
              childAspectRatio: 0.82,
            ),
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];

              return _HabitCardWrapper(
                key: ValueKey(summary.habit.id),
                summary: summary,
              )
                  .animate(delay: Duration(milliseconds: 40 * index))
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [HabitCard] and owns the check-in logic, including celebration trigger.
class _HabitCardWrapper extends ConsumerWidget {
  const _HabitCardWrapper({super.key, required this.summary});

  final HabitSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HabitCard(
      summary: summary,
      onTap: () => context.push('/habit/${summary.habit.id}'),
      onCheckIn: (tapPosition) async {
        final notifier = ref.read(habitsNotifierProvider.notifier);
        final wasNew = await notifier.checkIn(summary.habit.id!);

        if (!wasNew || !context.mounted) return;

        // Always celebrate a successful check-in.
        // Stage milestones get the full confetti; daily completions get a lighter burst.
        final newStreak = summary.currentStreak + 1;
        final oldStage = summary.stage;
        final newStage = PlantStage.fromStreak(newStreak);
        final isMilestone = newStage != oldStage && newStage.isMilestone;

        CelebrationOverlay.show(context, origin: tapPosition, milestone: isMilestone);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _Fab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddSheet(context),
      icon: const Icon(Icons.add_rounded),
      label: Text(t.garden.addHabitLabel),
      elevation: 2,
    );
  }

  void _showAddSheet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 600) {
      // On iPad / wide screens, show as a centered dialog instead of a bottom sheet
      showDialog<void>(
        context: context,
        builder: (ctx) => Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: const AddHabitSheet(),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const AddHabitSheet(),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌱', style: TextStyle(fontSize: 56)),
            const Gap(16),
            Text(
              t.garden.emptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              t.garden.emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95));
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: 4,
      itemBuilder: (_, _) => _SkeletonCard(),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
          duration: 1200.ms,
          color: isDark
              ? Colors.white.withAlpha(15)
              : Colors.black.withAlpha(8),
        );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const Gap(12),
            Text(t.garden.loadError, style: Theme.of(context).textTheme.titleMedium),
            const Gap(4),
            Text(error.toString(), style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
