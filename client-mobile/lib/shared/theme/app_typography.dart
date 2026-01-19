/// Guardyn Typography Constants
///
/// Font sizes, weights, and text styles.
/// Uses Inter font family to match desktop client.
library;

import 'package:flutter/material.dart';

/// Typography configuration
class AppTypography {
  AppTypography._();

  /// Primary font family
  static const String fontFamily = 'Inter';

  /// Monospace font family for code
  static const String fontFamilyMono = 'JetBrains Mono';

  /// Font weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semibold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  /// Text styles
  static TextStyle get displayLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    height: 1.1,
    fontWeight: bold,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 1.2,
    fontWeight: bold,
    letterSpacing: -0.25,
  );

  static TextStyle get displaySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.25,
    fontWeight: semibold,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: semibold,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.35,
    fontWeight: semibold,
  );

  static TextStyle get headlineSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.4,
    fontWeight: semibold,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.4,
    fontWeight: medium,
  );

  static TextStyle get titleMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: medium,
  );

  static TextStyle get titleSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: medium,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: regular,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: regular,
  );

  static TextStyle get bodySmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.5,
    fontWeight: regular,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.4,
    fontWeight: medium,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: medium,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    height: 1.4,
    fontWeight: medium,
    letterSpacing: 0.5,
  );

  /// Build TextTheme for Material theming
  static TextTheme get textTheme => TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
