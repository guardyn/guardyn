/// AuthLayout Widget
///
/// Modern glassmorphism-inspired authentication layout.
/// Matches the desktop client design system.
///
/// Features:
/// - Gradient background with animated orbs
/// - Frosted glass card effect
/// - Security badges footer
/// - Responsive design
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';

/// Authentication page layout with glassmorphism design
class AuthLayout extends StatelessWidget {
  /// Creates an authentication layout
  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  /// Main title (e.g., "Guardyn")
  final String title;

  /// Subtitle text (e.g., "Secure Communication Platform")
  final String subtitle;

  /// Form content
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0F1A),
                    const Color(0xFF111827),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFF1F5F9),
                  ],
          ),
        ),
        child: Stack(
          children: [
            // Animated gradient orbs
            const _GradientOrbs(),

            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _AuthCard(
                    title: title,
                    subtitle: subtitle,
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated gradient orbs for background
class _GradientOrbs extends StatefulWidget {
  const _GradientOrbs();

  @override
  State<_GradientOrbs> createState() => _GradientOrbsState();
}

class _GradientOrbsState extends State<_GradientOrbs>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orbOpacity = isDark ? 0.4 : 0.2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Stack(
          children: [
            // Green orb - top right
            Positioned(
              top: -200 + (30 * _wave(value, 0)),
              right: -200 + (20 * _wave(value, 0.25)),
              child: _Orb(
                size: 600,
                gradient: const LinearGradient(
                  colors: [
                    GuardynColors.guardyn500,
                    GuardynColors.guardyn700,
                  ],
                ),
                opacity: orbOpacity,
              ),
            ),
            // Cyan orb - bottom left
            Positioned(
              bottom: -150 + (20 * _wave(value, 0.5)),
              left: -150 + (30 * _wave(value, 0.75)),
              child: _Orb(
                size: 400,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0EA5E9),
                    Color(0xFF06B6D4),
                  ],
                ),
                opacity: orbOpacity,
              ),
            ),
            // Purple orb - center
            Positioned.fill(
              child: Center(
                child: Transform.translate(
                  offset: Offset(
                    20 * _wave(value, 0.3),
                    10 * _wave(value, 0.6),
                  ),
                  child: _Orb(
                    size: 300,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B5CF6),
                        Color(0xFFA855F7),
                      ],
                    ),
                    opacity: orbOpacity * 0.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  double _wave(double t, double offset) {
    return (t + offset) % 1.0 * 2 - 1;
  }
}

/// Individual gradient orb
class _Orb extends StatelessWidget {
  const _Orb({
    required this.size,
    required this.gradient,
    required this.opacity,
  });

  final double size;
  final Gradient gradient;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
      ),
      child: Opacity(
        opacity: opacity,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: gradient,
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass card with content
class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF111827).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                blurRadius: 50,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo with glow
              _LogoWithGlow(),
              const SizedBox(height: 16),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    GuardynColors.guardyn400,
                    GuardynColors.guardyn600,
                  ],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? GrayColors.gray400 : GrayColors.gray500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Form content
              child,

              // Security badges
              const SizedBox(height: 32),
              const Divider(height: 1),
              const SizedBox(height: 24),
              const _SecurityBadges(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo with glowing effect
class _LogoWithGlow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: GuardynColors.guardyn500.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Icon(
        Icons.verified_user_outlined,
        size: 48,
        color: GuardynColors.guardyn500,
      ),
    );
  }
}

/// Security badges footer
class _SecurityBadges extends StatelessWidget {
  const _SecurityBadges();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? GrayColors.gray500 : GrayColors.gray400;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          'E2E Encrypted',
          style: TextStyle(fontSize: 12, color: color),
        ),
        const SizedBox(width: 12),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Icon(Icons.security_outlined, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          'Post-Quantum Ready',
          style: TextStyle(fontSize: 12, color: color),
        ),
      ],
    );
  }
}
