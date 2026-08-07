import 'package:flutter/material.dart';

/// Central color vocabulary for Morpho.
///
/// Organised around a botanical palette — warm earthy tones with deep greens.
/// Every value has both a light and a dark variant so theming is a single switch.
abstract final class AppColors {
  // ── Brand ────────────────────────────────────────────────────────────────

  static const green900 = Color(0xFF1B4332);
  static const green700 = Color(0xFF2D6A4F);
  static const green500 = Color(0xFF40916C);
  static const green300 = Color(0xFF74C69D);
  static const green100 = Color(0xFFD8F3DC);

  static const amber700 = Color(0xFFB45309);
  static const amber500 = Color(0xFFF59E0B);
  static const amber100 = Color(0xFFFEF3C7);

  // ── Neutrals (light mode) ────────────────────────────────────────────────

  static const backgroundLight = Color(0xFFF7F6F2);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF0EFE9);
  static const dividerLight = Color(0xFFE5E3DC);

  static const textPrimaryLight = Color(0xFF1A1A16);
  static const textSecondaryLight = Color(0xFF6B6860);
  static const textTertiaryLight = Color(0xFFA09D94);

  // ── Neutrals (dark mode) ────────────────────────────────────────────────

  static const backgroundDark = Color(0xFF0D1710);
  static const surfaceDark = Color(0xFF172218);
  static const surface2Dark = Color(0xFF1F2E20);
  static const dividerDark = Color(0xFF2E3E2F);

  static const textPrimaryDark = Color(0xFFF0F4F0);
  static const textSecondaryDark = Color(0xFF8DA98E);
  static const textTertiaryDark = Color(0xFF5C745D);

  // ── Habit pot colours (7 choices, works on both themes) ──────────────────

  static const potColors = [
    Color(0xFF2D6A4F), // forest green
    Color(0xFF1D6FA4), // ocean blue
    Color(0xFF9B2335), // berry red
    Color(0xFF6D3A9C), // lavender
    Color(0xFFC17D00), // amber
    Color(0xFF3A7AA8), // sky
    Color(0xFF7A5C3A), // terracotta
  ];

  static const potColorLabels = [
    'Forêt',
    'Océan',
    'Baie',
    'Lavande',
    'Ambre',
    'Ciel',
    'Terre cuite',
  ];

  // ── Semantic ─────────────────────────────────────────────────────────────

  static const success = Color(0xFF16A34A);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
}
