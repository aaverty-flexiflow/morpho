import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:morpho/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/habits/domain/plant_stage.dart';
import '../../../../features/habits/domain/plant_type.dart';
import '../../../../shared/widgets/plant_view.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;
  bool _notifGranted = false;

  static const _totalPages = 3;

  Future<void> _next() async {
    if (_currentPage < _totalPages - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) context.go('/');
  }

  Future<void> _requestNotifications() async {
    final granted = await NotificationService.requestPermission();
    if (mounted) setState(() => _notifGranted = granted);
  }

  bool get _isHeroPage => _currentPage == 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _totalPages - 1;
    final theme = Theme.of(context);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: _isHeroPage ? AppColors.green900 : theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // ── Page indicator ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (i) {
                    final active = i == _currentPage;
                    final dotColor = _isHeroPage
                        ? (active ? Colors.white : Colors.white38)
                        : (active ? AppColors.green700 : AppColors.green300);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dotColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),

              // ── Page content ───────────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  children: [
                    _WelcomeScreen(),
                    _GrowthScreen(),
                    _NotificationScreen(
                      granted: _notifGranted,
                      onRequest: _requestNotifications,
                    ),
                  ],
                ),
              ),

              // ── CTA ────────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: _isHeroPage
                      ? OutlinedButton(
                          key: const ValueKey('outlined'),
                          onPressed: _next,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54, width: 1.5),
                          ),
                          child: Text(t.onboarding.next),
                        )
                      : FilledButton(
                          key: const ValueKey('filled'),
                          onPressed: _next,
                          child: Text(isLast ? t.onboarding.start : t.onboarding.next),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Brand wordmark
          Text(
            'morpho',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              letterSpacing: 8,
              color: Colors.white.withAlpha(160),
            ),
          ).animate().fadeIn(duration: 500.ms),

          const Gap(28),

          // Three plants at staggered heights to create depth
          SizedBox(
            height: 195,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Left — young fern, smaller
                PlantView(
                  type: PlantType.fern,
                  stage: PlantStage.sprout,
                  currentStreak: 4,
                  potColor: AppColors.green300,
                  size: 78,
                ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.15, curve: Curves.easeOut),

                const Gap(8),

                // Center — mature bonsai, hero size
                PlantView(
                  type: PlantType.bonsai,
                  stage: PlantStage.mature,
                  currentStreak: 45,
                  potColor: AppColors.potColors[0],
                  size: 162,
                )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.82, 0.82), curve: Curves.easeOut),

                const Gap(8),

                // Right — young cactus, shifted up slightly
                Padding(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: PlantView(
                    type: PlantType.cactus,
                    stage: PlantStage.young,
                    currentStreak: 14,
                    potColor: AppColors.potColors[2],
                    size: 82,
                  ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.15, curve: Curves.easeOut),
                ),
              ],
            ),
          ),

          const Gap(32),

          Text(
            t.onboarding.welcomeTitle,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.08),

          const Gap(10),

          Text(
            t.onboarding.welcomeSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(170),
              height: 1.55,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 360.ms).fadeIn().slideY(begin: 0.08),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _GrowthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stageData = [
      (PlantType.bonsai, PlantStage.seed, 0, '0j'),
      (PlantType.bonsai, PlantStage.sprout, 3, '3j'),
      (PlantType.bonsai, PlantStage.young, 14, '14j'),
      (PlantType.bonsai, PlantStage.mature, 45, '45j'),
      (PlantType.bonsai, PlantStage.legendary, 100, '100j+'),
    ];

    final steps = [
      (Icons.add_circle_outline_rounded, t.onboarding.step1Title, t.onboarding.step1Subtitle, AppColors.green700),
      (Icons.check_circle_outline_rounded, t.onboarding.step2Title, t.onboarding.step2Subtitle, AppColors.amber700),
      (Icons.local_fire_department_rounded, t.onboarding.step3Title, t.onboarding.step3Subtitle, AppColors.error),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
      child: Column(
        children: [
          Text(
            t.onboarding.howTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.08),

          const Gap(22),

          // ── Plant growth progression ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surface2Dark
                  : AppColors.green900.withAlpha(10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.dividerDark : AppColors.green300.withAlpha(80),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stageData.asMap().entries.map((e) {
                final i = e.key;
                final data = e.value;
                final size = 26.0 + i * 13.0; // 26 → 78
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PlantView(
                      type: data.$1,
                      stage: data.$2,
                      currentStreak: data.$3,
                      potColor: AppColors.green700,
                      size: size,
                    ).animate(delay: Duration(milliseconds: 80 + i * 110))
                        .fadeIn()
                        .slideY(begin: 0.2, curve: Curves.easeOut),
                    const Gap(5),
                    Text(
                      data.$4,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(110),
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),

          const Gap(28),

          // ── Three key steps ────────────────────────────────────────────────
          ...steps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return _StepRow(
              icon: step.$1,
              title: step.$2,
              subtitle: step.$3,
              color: step.$4,
            ).animate(delay: Duration(milliseconds: 600 + i * 130))
                .fadeIn()
                .slideX(begin: 0.08, curve: Curves.easeOut);
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                const Gap(2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationScreen extends StatelessWidget {
  const _NotificationScreen({required this.granted, required this.onRequest});
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated notification icon with rings
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: (granted ? AppColors.green300 : AppColors.green100).withAlpha(60),
                    shape: BoxShape.circle,
                  ),
                ).animate(
                  onPlay: (c) => c.repeat(reverse: true),
                ).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.0, 1.0),
                  duration: 1800.ms,
                  curve: Curves.easeInOut,
                ),
                // Inner circle
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: granted ? AppColors.green300 : AppColors.green100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    granted ? Icons.notifications_active_rounded : Icons.notifications_outlined,
                    size: 42,
                    color: granted ? AppColors.green900 : AppColors.green700,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.75, 0.75), curve: Curves.elasticOut),

          const Gap(28),

          Text(
            granted ? t.onboarding.notifGrantedTitle : t.onboarding.notifTitle,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.08),

          const Gap(12),

          Text(
            granted ? t.onboarding.notifGrantedSubtitle : t.onboarding.notifSubtitle,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(160),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.08),

          if (!granted) ...[
            const Gap(28),
            OutlinedButton.icon(
              onPressed: onRequest,
              icon: const Icon(Icons.notifications_outlined),
              label: Text(t.onboarding.notifButton),
            ).animate(delay: 450.ms).fadeIn().slideY(begin: 0.08),
          ],
        ],
      ),
    );
  }
}
