import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/database/habit_repository.dart';
import 'core/notifications/notification_service.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/habits/data/habits_provider.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocaleSettings.useDeviceLocale();

  await NotificationService.initialize();

  final repository = await HabitRepository.open();

  final prefs = await SharedPreferences.getInstance();
  final gracePeriod = prefs.getBool('grace_period') ?? false;
  final themeModeIndex = prefs.getInt('theme_mode') ?? 0;

  runApp(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          habitRepositoryProvider.overrideWithValue(repository),
          gracePeriodEnabledProvider.overrideWith((ref) => gracePeriod),
          themeModeProvider.overrideWith((ref) => ThemeMode.values[themeModeIndex]),
        ],
        child: const MorphoApp(),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class MorphoApp extends ConsumerStatefulWidget {
  const MorphoApp({super.key});

  @override
  ConsumerState<MorphoApp> createState() => _MorphoAppState();
}

class _MorphoAppState extends ConsumerState<MorphoApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Process any check-ins tapped in the widget while the app was suspended
      ref.read(habitRepositoryProvider).syncPendingWidgetCheckIns();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Morpho',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
