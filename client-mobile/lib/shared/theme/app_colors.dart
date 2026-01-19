/// Guardyn Color Palette
///
/// Central source of truth for all colors in the mobile app.
/// These tokens match the desktop client design system.
///
/// See: docs/DESIGN_SYSTEM.md
library;

import 'package:flutter/material.dart';

/// Guardyn brand colors (green scale)
///
/// Primary: [guardyn500]
/// Dark interactions: [guardyn600]
/// Light accents: [guardyn400]
class GuardynColors {
  GuardynColors._();

  // Guardyn Brand Scale
  static const Color guardyn50 = Color(0xFFF0FDF4);
  static const Color guardyn100 = Color(0xFFDCFCE7);
  static const Color guardyn200 = Color(0xFFBBF7D0);
  static const Color guardyn300 = Color(0xFF86EFAC);
  static const Color guardyn400 = Color(0xFF4ADE80);
  static const Color guardyn500 = Color(0xFF22C55E); // Primary
  static const Color guardyn600 = Color(0xFF16A34A); // Primary dark / hover
  static const Color guardyn700 = Color(0xFF15803D);
  static const Color guardyn800 = Color(0xFF166534);
  static const Color guardyn900 = Color(0xFF14532D);
  static const Color guardyn950 = Color(0xFF052E16);

  /// Primary color swatch for Material theming
  static const MaterialColor guardynSwatch =
      MaterialColor(0xFF22C55E, <int, Color>{
        50: guardyn50,
        100: guardyn100,
        200: guardyn200,
        300: guardyn300,
        400: guardyn400,
        500: guardyn500,
        600: guardyn600,
        700: guardyn700,
        800: guardyn800,
        900: guardyn900,
      });
}

/// Neutral gray scale
class GrayColors {
  GrayColors._();

  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);
  static const Color gray950 = Color(0xFF09090B);
}

/// Semantic colors for feedback and status
class SemanticColors {
  SemanticColors._();

  // Error
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  // Warning
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);

  // Success
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color success = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF16A34A);

  // Info
  static const Color infoLight = Color(0xFFEFF6FF);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);
}

/// Chat-specific background colors
///
/// Light: Soft pastel green tint
/// Dark: Deep forest green for eye comfort
class ChatColors {
  ChatColors._();

  // Light mode
  static const Color lightBackground = Color(
    0xFFF5FDF8,
  ); // Very soft green tint
  static const Color lightPattern = Color(
    0xFFECFDF3,
  ); // Slightly darker for patterns
  static const Color lightBubble = Color(0xFFFFFFFF); // White message bubbles

  // Dark mode
  static const Color darkBackground = Color(0xFF0D1F12); // Deep forest green
  static const Color darkPattern = Color(
    0xFF0F2616,
  ); // Slightly lighter for patterns
  static const Color darkBubble = Color(0xFF1A2E1F); // Dark green bubbles
}

/// Sidebar background colors
class SidebarColors {
  SidebarColors._();

  static const Color light = Color(0xFFFAFAFA); // Gray 50
  static const Color dark = Color(0xFF111111); // Near black

  static const Color borderLight = Color(0xFFE4E4E7); // Gray 200
  static const Color borderDark = Color(0xFF27272A); // Gray 800
}

/// Extension for easy access to app colors from BuildContext
extension AppColorsExtension on BuildContext {
  /// Get the current theme's brightness
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get chat background color for current theme
  Color get chatBackground =>
      isDarkMode ? ChatColors.darkBackground : ChatColors.lightBackground;

  /// Get chat pattern color for current theme
  Color get chatPattern =>
      isDarkMode ? ChatColors.darkPattern : ChatColors.lightPattern;

  /// Get sidebar background color for current theme
  Color get sidebarBackground =>
      isDarkMode ? SidebarColors.dark : SidebarColors.light;

  /// Get sidebar border color for current theme
  Color get sidebarBorder =>
      isDarkMode ? SidebarColors.borderDark : SidebarColors.borderLight;
}
