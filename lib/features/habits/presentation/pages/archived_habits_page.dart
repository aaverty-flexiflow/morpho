import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:morpho/i18n/strings.g.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/data/habits_provider.dart';
import '../../../../features/habits/domain/habit.dart';

/// Shows archived habits with options to restore or permanently delete them.
class ArchivedHabitsPage extends ConsumerWidget {
  const ArchivedHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedAsync = ref.watch(archivedHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.archived.title)),
      body: archivedAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(t.common.error(error: e))),
        data: (habits) => habits.isEmpty
            ? const _EmptyArchive()
            : _ArchivedList(habits: habits),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ArchivedList extends StatelessWidget {
  const _ArchivedList({required this.habits});
  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: habits.length,
      separatorBuilder: (_, _) => const Gap(8),
      itemBuilder: (context, index) => _ArchivedHabitTile(
        key: ValueKey(habits[index].id),
        habit: habits[index],
      )
          .animate(delay: Duration(milliseconds: 40 * index))
          .fadeIn(duration: 250.ms)
          .slideX(begin: 0.04, end: 0, curve: Curves.easeOut),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ArchivedHabitTile extends ConsumerWidget {
  const _ArchivedHabitTile({super.key, required this.habit});
  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final potColor = Color(habit.colorValue);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: potColor.withAlpha(25),
            shape: BoxShape.circle,
            border: Border.all(color: potColor.withAlpha(80)),
          ),
          child: Center(
            child: Text(habit.emoji, style: const TextStyle(fontSize: 22)),
          ),
        ),
        title: Text(
          habit.name,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          habit.frequency.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(130),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Restore button
            Tooltip(
              message: t.archived.restoreTooltip,
              child: IconButton(
                icon: const Icon(Icons.restore_rounded),
                color: AppColors.green500,
                onPressed: () => _restore(context, ref),
              ),
            ),
            // Delete button
            Tooltip(
              message: t.archived.deleteTooltip,
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.error,
                onPressed: () => _confirmDelete(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    await ref.read(habitsNotifierProvider.notifier).unarchiveHabit(habit.id!);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.archived.restoredSnackbar(name: habit.name)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.archived.deleteTitle),
        content: Text(t.archived.deleteBody(name: habit.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(t.common.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await NotificationService.cancel(habit.id!);
      await ref.read(habitsNotifierProvider.notifier).deleteHabit(habit.id!);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyArchive extends StatelessWidget {
  const _EmptyArchive();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📦', style: TextStyle(fontSize: 52)),
            const Gap(16),
            Text(
              t.archived.emptyTitle,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              t.archived.emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
