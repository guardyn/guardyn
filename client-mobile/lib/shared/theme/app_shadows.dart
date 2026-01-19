/// Guardyn Shadow & Effect Definitions
///
/// Includes elevation shadows and neumorphic effects.
library;

import 'package:flutter/material.dart';

/// Shadow/elevation presets
class AppShadows {
  AppShadows._();

  /// Small shadow
  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  /// Default shadow
  static List<BoxShadow> get base => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
    ),
  ];

  /// Medium shadow
  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
    ),
  ];

  /// Large shadow
  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 10),
      blurRadius: 15,
      spreadRadius: -3,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
    ),
  ];

  /// Extra large shadow
  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 20),
      blurRadius: 25,
      spreadRadius: -5,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: const Offset(0, 8),
      blurRadius: 10,
      spreadRadius: -6,
    ),
  ];

  /// Neumorphic raised shadow (light mode)
  static List<BoxShadow> get neumorphicLight => [
    const BoxShadow(
      color: Color(0xFFD1D9E6),
      offset: Offset(6, 6),
      blurRadius: 12,
    ),
    const BoxShadow(
      color: Colors.white,
      offset: Offset(-6, -6),
      blurRadius: 12,
    ),
  ];

  /// Neumorphic raised shadow (dark mode)
  static List<BoxShadow> get neumorphicDark => [
    const BoxShadow(
      color: Color(0xFF0A0A0A),
      offset: Offset(6, 6),
      blurRadius: 12,
    ),
    const BoxShadow(
      color: Color(0xFF1E1E1E),
      offset: Offset(-6, -6),
      blurRadius: 12,
    ),
  ];

  /// Neumorphic pressed shadow (light mode)
  static List<BoxShadow> get neumorphicPressedLight => [
    const BoxShadow(
      color: Color(0xFFD1D9E6),
      offset: Offset(4, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
    const BoxShadow(
      color: Colors.white,
      offset: Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];

  /// Neumorphic pressed shadow (dark mode)
  static List<BoxShadow> get neumorphicPressedDark => [
    const BoxShadow(
      color: Color(0xFF0A0A0A),
      offset: Offset(4, 4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
    const BoxShadow(
      color: Color(0xFF1E1E1E),
      offset: Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: -2,
    ),
  ];

  /// Primary color glow
  static List<BoxShadow> get glowPrimary => [
    BoxShadow(color: const Color(0xFF22C55E).withOpacity(0.4), blurRadius: 16),
  ];

  /// Error color glow
  static List<BoxShadow> get glowError => [
    BoxShadow(color: const Color(0xFFEF4444).withOpacity(0.4), blurRadius: 16),
  ];
}

/// Get neumorphic shadows based on brightness
List<BoxShadow> getNeumorphicShadows({
  required Brightness brightness,
  bool pressed = false,
}) {
  if (brightness == Brightness.light) {
    return pressed
        ? AppShadows.neumorphicPressedLight
        : AppShadows.neumorphicLight;
  } else {
    return pressed
        ? AppShadows.neumorphicPressedDark
        : AppShadows.neumorphicDark;
  }
}
