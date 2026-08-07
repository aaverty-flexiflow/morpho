import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:morpho/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/data/habits_provider.dart';

// ─── Local providers ──────────────────────────────────────────────────────────

/// Transient state that mirrors whether the OS permission is granted.
/// Checked once when the page opens; refreshed after requesting.
final notificationGrantedProvider = StateProvider<bool?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────

/// Settings page — dark mode, grace period, notification permission.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(t.settings.title)),
      body: const _SettingsBody(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SettingsBody extends ConsumerStatefulWidget {
  const _SettingsBody();

  @override
  ConsumerState<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends ConsumerState<_SettingsBody> {
  @override
  void initState() {
    super.initState();
    _checkNotificationPermission();
    _loadPersistedSettings();
  }

  Future<void> _checkNotificationPermission() async {
    try {
      final pending = await NotificationService.pendingCount();
      if (mounted) {
        ref.read(notificationGrantedProvider.notifier).state = pending >= 0;
      }
    } catch (_) {
      if (mounted) {
        ref.read(notificationGrantedProvider.notifier).state = false;
      }
    }
  }

  Future<void> _loadPersistedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode') ?? 0;
    if (mounted) {
      ref.read(themeModeProvider.notifier).state = ThemeMode.values[themeIndex];
    }
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
  }

  Future<void> _requestNotification() async {
    final granted = await NotificationService.requestPermission();
    if (mounted) {
      ref.read(notificationGrantedProvider.notifier).state = granted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.settings.notifDeniedSnackbar)),
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final gracePeriod = ref.watch(gracePeriodEnabledProvider);
    final notifGranted = ref.watch(notificationGrantedProvider);

    return ListView(
      children: [
        // ── Appearance ────────────────────────────────────────────────────
        _SectionHeader(t.settings.sectionAppearance),
        _ThemeTile(current: themeMode, onChange: _saveTheme),

        // ── Habits ────────────────────────────────────────────────────────
        _SectionHeader(t.settings.sectionHabits),
        ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text(t.settings.archivedTitle),
          subtitle: Text(t.settings.archivedSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push('/archived'),
        ),
        SwitchListTile(
          value: gracePeriod,
          onChanged: (v) async {
            ref.read(gracePeriodEnabledProvider.notifier).state = v;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('grace_period', v);
          },
          title: Text(t.settings.gracePeriodTitle),
          subtitle: Text(t.settings.gracePeriodSubtitle),
          secondary: const Icon(Icons.auto_fix_high_rounded),
        ),

        // ── Notifications ─────────────────────────────────────────────────
        _SectionHeader(t.settings.sectionNotifications),
        _NotificationTile(
          granted: notifGranted,
          onRequest: _requestNotification,
        ),

        // ── About ─────────────────────────────────────────────────────────
        _SectionHeader(t.settings.sectionAbout),
        ListTile(
          leading: const Icon(Icons.info_outline_rounded),
          title: Text(t.settings.version),
          subtitle: Text(t.settings.versionNumber),
        ),
        ListTile(
          leading: const Icon(Icons.eco_outlined),
          title: const Text('Morpho'),
          subtitle: Text(t.settings.appDescription),
        ),
        const Gap(24),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
                letterSpacing: 0.8,
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.current, required this.onChange});
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final options = [
      (ThemeMode.system, Icons.brightness_auto_rounded, t.settings.themeSystem),
      (ThemeMode.light, Icons.light_mode_rounded, t.settings.themeLight),
      (ThemeMode.dark, Icons.dark_mode_rounded, t.settings.themeDark),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: options.map((opt) {
          final (mode, icon, label) = opt;
          final isSelected = current == mode;

          return Expanded(
            child: GestureDetector(
              onTap: () => onChange(mode),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withAlpha(20)
                      : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        size: 22,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(150)),
                    const Gap(4),
                    Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.granted, required this.onRequest});
  final bool? granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    if (granted == null) {
      return ListTile(
        leading: const Icon(Icons.notifications_outlined),
        title: Text(t.settings.notifChecking),
        trailing: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (granted == true) {
      return ListTile(
        leading: const Icon(Icons.notifications_active_rounded, color: AppColors.green500),
        title: Text(t.settings.notifActive),
        trailing: const Icon(Icons.check_circle_rounded, color: AppColors.green500, size: 20),
      );
    }

    return ListTile(
      leading: const Icon(Icons.notifications_off_outlined),
      title: Text(t.settings.notifActivateTitle),
      subtitle: Text(t.settings.notifActivateSubtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onRequest,
    );
  }
}
