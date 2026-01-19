/// Guardyn Spacing & Layout Constants
///
/// Consistent spacing scale (4px base unit).
library;

/// Spacing scale based on 4px grid
class AppSpacing {
  AppSpacing._();

  static const double space0 = 0;
  static const double space0_5 = 2; // 0.5 * 4
  static const double space1 = 4;
  static const double space1_5 = 6;
  static const double space2 = 8;
  static const double space2_5 = 10;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;
  static const double space20 = 80;
  static const double space24 = 96;
}

/// Border radius values
class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double sm = 2;
  static const double base = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 12;
  static const double xl2 = 16;
  static const double xl3 = 24; // For cards
  static const double full = 9999; // For pills, avatars
}

/// Icon sizes
class AppIconSize {
  AppIconSize._();

  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 32;
  static const double xl2 = 40;
  static const double xl3 = 48;
}
