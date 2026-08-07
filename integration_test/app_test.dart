import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:morpho/core/database/habit_repository.dart';
import 'package:morpho/core/notifications/notification_service.dart';
import 'package:morpho/core/router/app_router.dart';
import 'package:morpho/core/theme/app_theme.dart';
import 'package:morpho/features/habits/data/habits_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots a minimal version of the app with a real (but ephemeral) SQLite database.
/// SharedPreferences is seeded so onboarding is skipped.
Future<void> _pumpApp(WidgetTester tester) async {
  await NotificationService.initialize();

  // Mark onboarding done so we land directly on the garden.
  SharedPreferences.setMockInitialValues({'onboarding_done': true});
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_done', true);

  final repository = await HabitRepository.open();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [habitRepositoryProvider.overrideWithValue(repository)],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(
            title: 'Morpho Test',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            routerConfig: router,
          );
        },
      ),
    ),
  );

  // Allow routing + initial DB query to resolve.
  await tester.pumpAndSettle(const Duration(seconds: 2));
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Garden flow', () {
    testWidgets('empty garden shows empty state', (tester) async {
      await _pumpApp(tester);
      // The empty-state widget should be visible on first launch.
      expect(find.text('Ton jardin vous attend'), findsOneWidget);
    });

    testWidgets('add habit → appears in grid', (tester) async {
      await _pumpApp(tester);

      // Tap the FAB to open the creation sheet.
      await tester.tap(find.text('Habitude'));
      await tester.pumpAndSettle();

      // Type the habit name.
      await tester.enterText(
        find.byType(TextFormField).first,
        'Méditation',
      );

      // Submit the form.
      await tester.tap(find.text('Planter 🌱'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // The new habit card should be visible.
      expect(find.text('Méditation'), findsOneWidget);
    });

    testWidgets('check-in updates streak badge', (tester) async {
      await _pumpApp(tester);

      // Create an habit first (relies on the previous test's data OR a fresh DB).
      // In a clean DB, tap the FAB.
      final fabFinder = find.text('Habitude');
      if (fabFinder.evaluate().isNotEmpty) {
        await tester.tap(fabFinder);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).first, 'Lecture');
        await tester.tap(find.text('Planter 🌱'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Tap the check-in (+) button.
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();

      // After check-in, the badge should show "1 j" and the button show a checkmark.
      expect(find.byIcon(Icons.check_rounded), findsWidgets);
    });

    testWidgets('navigate to habit detail', (tester) async {
      await _pumpApp(tester);

      // If no habits, create one.
      if (find.text('Ton jardin vous attend').evaluate().isNotEmpty) {
        await tester.tap(find.text('Habitude'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField).first, 'Yoga');
        await tester.tap(find.text('Planter 🌱'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Tap a card to navigate to the detail page.
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // The detail page shows the 30-day heatmap section label.
      expect(find.text('30 derniers jours'), findsOneWidget);
    });
  });

  group('Settings flow', () {
    testWidgets('settings page opens from garden', (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Paramètres'), findsOneWidget);
    });
  });
}
