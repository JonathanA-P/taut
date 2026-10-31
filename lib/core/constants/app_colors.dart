import 'package:flutter/material.dart';

/// Semantic colors following Material 3 guidelines.
/// Calibrated for accessibility, high-contrast readability, and calm clarity.
class AppColors {
  AppColors._();

  // Primary palette: Deep Navy / Accessible Teal
  static const Color primary = Color(
    0xFF0F4C81,
  ); // Classic deep accessibility blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD4E3F5);
  static const Color onPrimaryContainer = Color(0xFF051D33);

  // Secondary palette: Warm Terracotta / Amber
  static const Color secondary = Color(0xFFC05621);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFEEBC8);
  static const Color onSecondaryContainer = Color(0xFF431A03);

  // Surface & Neutral
  static const Color surface = Color(0xFFF8FAFC);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFFE2E8F0);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFFCBD5E1);

  // Status Colors
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB91C1C);
  static const Color info = Color(0xFF0369A1);
}
