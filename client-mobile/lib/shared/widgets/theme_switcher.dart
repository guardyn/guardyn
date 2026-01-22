/// Theme Switcher Widget
///
/// Three-way toggle for light/dark/system theme modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_bloc.dart';

/// Theme switcher with segmented control
class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          padding: const EdgeInsets.all(AppSpacing.space1),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ThemeButton(
                icon: Icons.light_mode_outlined,
                label: 'Light',
                isSelected: state.mode == ThemeMode.light,
                onTap: () => context.read<ThemeBloc>().add(SetLightTheme()),
              ),
              _ThemeButton(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isSelected: state.mode == ThemeMode.dark,
                onTap: () => context.read<ThemeBloc>().add(SetDarkTheme()),
              ),
              _ThemeButton(
                icon: Icons.brightness_auto_outlined,
                label: 'Auto',
                isSelected: state.mode == ThemeMode.system,
                onTap: () => context.read<ThemeBloc>().add(SetSystemTheme()),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: label,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppSpacing.space2),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isSelected
                ? GuardynColors.guardyn600
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Simple theme toggle button (light/dark only)
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final isDark =
            state.mode == ThemeMode.dark ||
            (state.mode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);

        return IconButton(
          onPressed: () {
            if (isDark) {
              context.read<ThemeBloc>().add(SetLightTheme());
            } else {
              context.read<ThemeBloc>().add(SetDarkTheme());
            }
          },
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              key: ValueKey(isDark),
            ),
          ),
          tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
        );
      },
    );
  }
}
