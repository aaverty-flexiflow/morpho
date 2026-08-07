import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../database/habit_repository.dart';
import '../../features/habits/data/habits_provider.dart';
import '../theme/app_colors.dart';

/// Shows the debug panel as a modal bottom sheet.
/// Must only be called when [kDebugMode] is true.
void showDebugPanel(BuildContext context) {
  assert(kDebugMode);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _DebugPanel(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _DebugPanel extends ConsumerStatefulWidget {
  const _DebugPanel();

  @override
  ConsumerState<_DebugPanel> createState() => _DebugPanelState();
}

class _DebugPanelState extends ConsumerState<_DebugPanel> {
  double _days = 30;
  bool _loading = false;
  String? _message;
  String? _dbPath;

  HabitRepository get _repo => ref.read(habitRepositoryProvider);

  Future<void> _run(Future<void> Function() action, String successMsg) async {
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await action();
      if (mounted) {
        setState(() {
          _loading = false;
          _message = successMsg;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _message = 'Erreur : $e';
        });
      }
    }
  }

  Future<void> _seedDays() => _run(
    () => _repo.debugSeedDays(_days.toInt()),
    '✅ ${_days.toInt()} jours seedés pour toutes les habitudes',
  );

  Future<void> _seedToday() => _run(
    () => _repo.debugSeedToday(),
    "✅ Aujourd'hui validé pour toutes les habitudes",
  );

  Future<void> _clearEntries() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer les check-ins ?'),
        content: const Text(
          'Tous les check-ins seront supprimés. Les habitudes restent intactes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(
        () => _repo.debugClearAllEntries(),
        '🗑️ Tous les check-ins supprimés',
      );
    }
  }

  Future<void> _copyDbPath() async {
    final path = await _repo.debugGetDbPath();
    if (!mounted) return;
    await Clipboard.setData(ClipboardData(text: path));
    setState(() => _dbPath = path);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chemin copié dans le presse-papier')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),

          // Title
          Row(
            children: [
              const Text('🐛', style: TextStyle(fontSize: 20)),
              const Gap(8),
              Text(
                'Panel de debug',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange.withAlpha(80)),
                ),
                child: const Text(
                  'DEBUG ONLY',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Gap(24),

          // Days slider
          Row(
            children: [
              Text('Jours à seeder :', style: theme.textTheme.labelLarge),
              const Spacer(),
              Text(
                '${_days.toInt()} j',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Slider(
            value: _days,
            min: 1,
            max: 210,
            divisions: 14,
            label: '${_days.toInt()} j',
            onChanged: _loading ? null : (v) => setState(() => _days = v),
          ),
          const Gap(4),

          // Seed N days
          FilledButton.icon(
            onPressed: _loading ? null : _seedDays,
            icon: const Text('🌱', style: TextStyle(fontSize: 16)),
            label: Text(
              'Seeder ${_days.toInt()} jours pour toutes les habitudes',
            ),
          ),
          const Gap(8),

          // Seed today
          OutlinedButton.icon(
            onPressed: _loading ? null : _seedToday,
            icon: const Text('✅', style: TextStyle(fontSize: 16)),
            label: const Text("Valider aujourd'hui pour toutes les habitudes"),
          ),
          const Gap(8),

          // Clear entries
          OutlinedButton.icon(
            onPressed: _loading ? null : _clearEntries,
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            label: const Text('Effacer tous les check-ins'),
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
          ),
          const Gap(8),

          // Copy DB path
          OutlinedButton.icon(
            onPressed: _loading ? null : _copyDbPath,
            icon: const Icon(Icons.folder_outlined, size: 18),
            label: const Text('Copier le chemin de la base de données'),
          ),

          if (_dbPath != null) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _dbPath!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],

          if (_loading) ...[
            const Gap(16),
            const Center(child: CircularProgressIndicator()),
          ],

          if (_message != null && !_loading) ...[
            const Gap(12),
            Text(
              _message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _message!.startsWith('Erreur')
                    ? AppColors.error
                    : AppColors.green700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
