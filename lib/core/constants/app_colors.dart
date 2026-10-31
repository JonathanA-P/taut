import 'package:flutter/material.dart';

/// Semantic colors following Material 3 guidelines.
/// Calibrated for accessibility, high-contrast readability, and calm healthcare clarity.
/// Visual identity: TAUT Sage Green & Dark Green palette inspired by modern healthcare design.
class AppColors {
  AppColors._();

  // Established TAUT Brand Palette
  static const Color sageGreen = Color(0xFFD7E3D1);
  static const Color darkGreen = Color(0xFF263D2F);
  static const Color primaryGreen = Color(0xFF527B5D);
  static const Color lightGreen = Color(0xFFE5EEE5);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8FAF7);

  // Material 3 Semantic Mappings
  static const Color primary = primaryGreen;
  static const Color onPrimary = white;
  static const Color primaryContainer = lightGreen;
  static const Color onPrimaryContainer = darkGreen;

  // Secondary Palette: Dark Green for high contrast actions
  static const Color secondary = darkGreen;
  static const Color onSecondary = white;
  static const Color secondaryContainer = sageGreen;
  static const Color onSecondaryContainer = darkGreen;

  // Surface & Neutral
  static const Color surface = background;
  static const Color onSurface = darkGreen;
  static const Color surfaceCard = white;
  static const Color surfaceVariant = lightGreen;
  static const Color onSurfaceVariant = Color(0xFF4A6052);
  static const Color outline = Color(0xFFD8E2D8);
  static const Color subtleDivider = Color(0xFFE8EFE8);

  // Text Colors
  static const Color textPrimary = darkGreen;
  static const Color textSecondary = Color(0xFF4A6052);
  static const Color textMuted = Color(0xFF7A8E80);

  // Feature Accent Colors (used sparingly for feature cards and badges)
  // Speech-to-Text / Coral
  static const Color accentStt = Color(0xFFE07A5F);
  static const Color accentSttBg = Color(0xFFFDF0ED);
  static const Color onAccentStt = Color(0xFF8A341E);

  // Motion-to-Sound / Warm Amber
  static const Color accentMts = Color(0xFFD4A373);
  static const Color accentMtsBg = Color(0xFFFEF8E7);
  static const Color onAccentMts = Color(0xFF7A4F20);

  // Healthcare Finder / Mint
  static const Color accentHealthcare = Color(0xFF527B5D);
  static const Color accentHealthcareBg = Color(0xFFEBF5F0);
  static const Color onAccentHealthcare = Color(0xFF1E3A25);

  // Location Sharing / Soft Slate Blue
  static const Color accentLocation = Color(0xFF5E81AC);
  static const Color accentLocationBg = Color(0xFFF0F4F8);
  static const Color onAccentLocation = Color(0xFF2E4562);

  // Status Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFEDF7ED);
  static const Color warning = Color(0xFFE67E22);
  static const Color warningBg = Color(0xFFFEF9E7);
  static const Color error = Color(0xFFC0392B);
  static const Color errorBg = Color(0xFFFDECEA);
  static const Color info = Color(0xFF2980B9);
  static const Color infoBg = Color(0xFFEAF2F8);

  // Shadows
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A263D2F),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> heroShadow = [
    BoxShadow(
      color: Color(0x12263D2F),
      blurRadius: 20,
      offset: Offset(0, 6),
      spreadRadius: -2,
    ),
  ];
}
