import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Produces [ThemeData] for both modes from the Morpho botanical palette.
///
/// Uses Material 3 with [ColorScheme.fromSeed] as a base, then overrides
/// individual component themes to match the design vision.
abstract final class AppTheme {
  static ThemeData light() => _build(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green700,
          brightness: Brightness.light,
        ).copyWith(
          surface: AppColors.backgroundLight,
          onSurface: AppColors.textPrimaryLight,
          primary: AppColors.green700,
          secondary: AppColors.amber700,
        ),
        backgroundColor: AppColors.backgroundLight,
        cardColor: AppColors.surfaceLight,
        dividerColor: AppColors.dividerLight,
        textPrimary: AppColors.textPrimaryLight,
        textSecondary: AppColors.textSecondaryLight,
        statusBarStyle: SystemUiOverlayStyle.dark,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green500,
          brightness: Brightness.dark,
        ).copyWith(
          surface: AppColors.backgroundDark,
          onSurface: AppColors.textPrimaryDark,
          primary: AppColors.green300,
          secondary: AppColors.amber500,
        ),
        backgroundColor: AppColors.backgroundDark,
        cardColor: AppColors.surfaceDark,
        dividerColor: AppColors.dividerDark,
        textPrimary: AppColors.textPrimaryDark,
        textSecondary: AppColors.textSecondaryDark,
        statusBarStyle: SystemUiOverlayStyle.light,
      );

  // ──────────────────────────────────────────────────────────────────────────

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color cardColor,
    required Color dividerColor,
    required Color textPrimary,
    required Color textSecondary,
    required SystemUiOverlayStyle statusBarStyle,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      dividerColor: dividerColor,
      fontFamily: 'SF Pro Display', // falls back to system sans-serif
    );

    return base.copyWith(
      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: statusBarStyle,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardColor,
        modalBackgroundColor: cardColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        elevation: 0,
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? AppColors.surface2Light
            : AppColors.surface2Dark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // ── FilledButton ──────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // ── Text ──────────────────────────────────────────────────────────────
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
    );
  }
}
