import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/habits/presentation/pages/archived_habits_page.dart';
import '../../features/habits/presentation/pages/garden_page.dart';
import '../../features/habits/presentation/pages/habit_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────

/// App-wide router, exposed so the MaterialApp can consume it via ref.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: _onboardingRedirect,
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, _) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/',
        builder: (_, _) => const GardenPage(),
        routes: [
          GoRoute(
            path: 'habit/:id',
            builder: (_, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return const _NotFoundPage();
              return HabitDetailPage(habitId: id);
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (_, _) => const SettingsPage(),
          ),
          GoRoute(
            path: 'archived',
            builder: (_, _) => const ArchivedHabitsPage(),
          ),
        ],
      ),
    ],
  );
});

// ─────────────────────────────────────────────────────────────────────────────

/// Redirect first-time users to onboarding; no-op for returning users.
Future<String?> _onboardingRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  if (state.matchedLocation == '/onboarding') return null; // already there

  final prefs = await SharedPreferences.getInstance();
  final done = prefs.getBool('onboarding_done') ?? false;
  if (!done) return '/onboarding';
  return null;
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Introuvable')),
        body: const Center(child: Text('Cette habitude n\'existe plus.')),
      );
}
