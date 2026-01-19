/// Guardyn Theme Configuration
///
/// Complete ThemeData for light and dark modes.
/// Matches the desktop client design system.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Main theme configuration
class AppTheme {
  AppTheme._();

  /// Light theme
  static ThemeData get light => _buildTheme(Brightness.light);

  /// Dark theme
  static ThemeData get dark => _buildTheme(Brightness.dark);

  /// Build theme for given brightness
  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      // Primary
      primary: GuardynColors.guardyn500,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? GuardynColors.guardyn900
          : GuardynColors.guardyn100,
      onPrimaryContainer: isDark
          ? GuardynColors.guardyn100
          : GuardynColors.guardyn900,
      // Secondary (using primary for consistency)
      secondary: GuardynColors.guardyn600,
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? GuardynColors.guardyn800
          : GuardynColors.guardyn200,
      onSecondaryContainer: isDark
          ? GuardynColors.guardyn200
          : GuardynColors.guardyn800,
      // Tertiary
      tertiary: isDark ? const Color(0xFF0EA5E9) : const Color(0xFF0284C7),
      onTertiary: Colors.white,
      tertiaryContainer: isDark
          ? const Color(0xFF0C4A6E)
          : const Color(0xFFE0F2FE),
      onTertiaryContainer: isDark
          ? const Color(0xFFE0F2FE)
          : const Color(0xFF0C4A6E),
      // Error
      error: SemanticColors.error,
      onError: Colors.white,
      errorContainer: isDark
          ? const Color(0xFF7F1D1D)
          : SemanticColors.errorLight,
      onErrorContainer: isDark
          ? SemanticColors.errorLight
          : const Color(0xFF7F1D1D),
      // Surface
      surface: isDark ? GrayColors.gray900 : Colors.white,
      onSurface: isDark ? GrayColors.gray50 : GrayColors.gray900,
      // Surface variants
      surfaceContainerHighest: isDark ? GrayColors.gray800 : GrayColors.gray100,
      onSurfaceVariant: isDark ? GrayColors.gray400 : GrayColors.gray600,
      // Outline
      outline: isDark ? GrayColors.gray700 : GrayColors.gray300,
      outlineVariant: isDark ? GrayColors.gray800 : GrayColors.gray200,
      // Inverse
      inverseSurface: isDark ? GrayColors.gray50 : GrayColors.gray900,
      onInverseSurface: isDark ? GrayColors.gray900 : GrayColors.gray50,
      inversePrimary: isDark
          ? GuardynColors.guardyn400
          : GuardynColors.guardyn600,
      // Shadow and scrim
      shadow: Colors.black,
      scrim: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,

      // Typography
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),

      // Scaffold
      scaffoldBackgroundColor: isDark ? GrayColors.gray950 : Colors.white,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: isDark ? GrayColors.gray950 : Colors.white,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              ),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? GrayColors.gray900 : Colors.white,
        selectedItemColor: GuardynColors.guardyn500,
        unselectedItemColor: GrayColors.gray500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? GrayColors.gray900 : Colors.white,
        indicatorColor: GuardynColors.guardyn100,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelMedium.copyWith(
              color: GuardynColors.guardyn600,
            );
          }
          return AppTypography.labelMedium.copyWith(color: GrayColors.gray500);
        }),
      ),

      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? GrayColors.gray800 : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl2),
          side: BorderSide(
            color: isDark ? GrayColors.gray700 : GrayColors.gray200,
            width: 1,
          ),
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GuardynColors.guardyn500,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: GuardynColors.guardyn600,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space6,
            vertical: AppSpacing.space4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          side: BorderSide(
            color: isDark ? GrayColors.gray700 : GrayColors.gray300,
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: GuardynColors.guardyn600,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.space4,
            vertical: AppSpacing.space2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: GuardynColors.guardyn500,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.03) : GrayColors.gray50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: isDark ? GrayColors.gray700 : GrayColors.gray300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(
            color: isDark ? GrayColors.gray700 : GrayColors.gray300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(
            color: GuardynColors.guardyn500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: SemanticColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: SemanticColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: GrayColors.gray500),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? GrayColors.gray400 : GrayColors.gray600,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? GrayColors.gray800 : GrayColors.gray100,
        labelStyle: AppTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        side: BorderSide.none,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? GrayColors.gray900 : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl3),
        ),
        titleTextStyle: AppTypography.headlineMedium.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? GrayColors.gray900 : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl3),
          ),
        ),
        dragHandleColor: isDark ? GrayColors.gray600 : GrayColors.gray400,
        dragHandleSize: const Size(32, 4),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? GrayColors.gray800 : GrayColors.gray900,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? GrayColors.gray800 : GrayColors.gray200,
        thickness: 1,
        space: 0,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return isDark ? GrayColors.gray400 : GrayColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GuardynColors.guardyn500;
          }
          return isDark ? GrayColors.gray700 : GrayColors.gray300;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GuardynColors.guardyn500;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: BorderSide(
          color: isDark ? GrayColors.gray600 : GrayColors.gray400,
          width: 2,
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GuardynColors.guardyn500;
          }
          return isDark ? GrayColors.gray600 : GrayColors.gray400;
        }),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: GuardynColors.guardyn500,
        linearTrackColor: GrayColors.gray200,
        circularTrackColor: GrayColors.gray200,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? GrayColors.gray700 : GrayColors.gray900,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: AppTypography.bodySmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space3,
          vertical: AppSpacing.space2,
        ),
      ),

      // Icon
      iconTheme: IconThemeData(
        color: isDark ? GrayColors.gray400 : GrayColors.gray600,
        size: 24,
      ),

      // Primary Icon
      primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),

      // Extensions
      extensions: const <ThemeExtension<dynamic>>[],
    );
  }
}
