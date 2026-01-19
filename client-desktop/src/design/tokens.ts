/**
 * Guardyn Design Tokens
 * 
 * Central source of truth for all design values.
 * These tokens are mirrored in the Flutter mobile client.
 * 
 * @see docs/DESIGN_SYSTEM.md for usage guidelines
 */

// =============================================================================
// COLOR PALETTE
// =============================================================================

/**
 * Guardyn brand colors (green scale)
 * Primary: 500, Dark interactions: 600, Light accents: 400
 */
export const guardynColors = {
  50: '#f0fdf4',
  100: '#dcfce7',
  200: '#bbf7d0',
  300: '#86efac',
  400: '#4ade80',
  500: '#22c55e', // Primary
  600: '#16a34a', // Primary dark / hover
  700: '#15803d',
  800: '#166534',
  900: '#14532d',
  950: '#052e16',
} as const;

/**
 * Neutral gray scale
 */
export const grayColors = {
  50: '#fafafa',
  100: '#f4f4f5',
  200: '#e4e4e7',
  300: '#d4d4d8',
  400: '#a1a1aa',
  500: '#71717a',
  600: '#52525b',
  700: '#3f3f46',
  800: '#27272a',
  900: '#18181b',
  950: '#09090b',
} as const;

/**
 * Semantic colors for feedback and status
 */
export const semanticColors = {
  error: {
    light: '#fef2f2',
    main: '#ef4444',
    dark: '#dc2626',
  },
  warning: {
    light: '#fffbeb',
    main: '#f59e0b',
    dark: '#d97706',
  },
  success: {
    light: '#f0fdf4',
    main: '#22c55e',
    dark: '#16a34a',
  },
  info: {
    light: '#eff6ff',
    main: '#3b82f6',
    dark: '#2563eb',
  },
} as const;

/**
 * Chat-specific backgrounds
 * Light: Soft pastel green tint
 * Dark: Deep forest green for eye comfort
 */
export const chatBackgrounds = {
  light: {
    main: '#f5fdf8',      // Very soft green tint
    pattern: '#ecfdf3',   // Slightly darker for patterns
    bubble: '#ffffff',    // White message bubbles
  },
  dark: {
    main: '#0d1f12',      // Deep forest green
    pattern: '#0f2616',   // Slightly lighter for patterns
    bubble: '#1a2e1f',    // Dark green bubbles
  },
} as const;

/**
 * Sidebar backgrounds
 * Subtle contrast from chat area
 */
export const sidebarBackgrounds = {
  light: '#fafafa',       // Gray 50
  dark: '#111111',        // Near black
  border: {
    light: '#e4e4e7',     // Gray 200
    dark: '#27272a',      // Gray 800
  },
} as const;

// =============================================================================
// TYPOGRAPHY
// =============================================================================

/**
 * Font family stack
 * Inter Variable is primary, with system fallbacks
 */
export const fontFamily = {
  sans: "'Inter Variable', 'Inter', system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
  mono: "'JetBrains Mono', 'Fira Code', 'SF Mono', Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace",
} as const;

/**
 * Font sizes with corresponding line heights
 * Follows a modular scale (1.2 ratio)
 */
export const fontSize = {
  xs: { size: '0.75rem', lineHeight: '1rem' },       // 12px
  sm: { size: '0.875rem', lineHeight: '1.25rem' },   // 14px
  base: { size: '1rem', lineHeight: '1.5rem' },      // 16px
  lg: { size: '1.125rem', lineHeight: '1.75rem' },   // 18px
  xl: { size: '1.25rem', lineHeight: '1.75rem' },    // 20px
  '2xl': { size: '1.5rem', lineHeight: '2rem' },     // 24px
  '3xl': { size: '1.875rem', lineHeight: '2.25rem' }, // 30px
  '4xl': { size: '2.25rem', lineHeight: '2.5rem' },  // 36px
} as const;

/**
 * Font weights
 * Use numeric values for Inter Variable
 */
export const fontWeight = {
  normal: 400,
  medium: 500,
  semibold: 600,
  bold: 700,
} as const;

// =============================================================================
// SPACING
// =============================================================================

/**
 * Spacing scale (4px base unit)
 */
export const spacing = {
  0: '0',
  0.5: '0.125rem',  // 2px
  1: '0.25rem',     // 4px
  1.5: '0.375rem',  // 6px
  2: '0.5rem',      // 8px
  2.5: '0.625rem',  // 10px
  3: '0.75rem',     // 12px
  4: '1rem',        // 16px
  5: '1.25rem',     // 20px
  6: '1.5rem',      // 24px
  8: '2rem',        // 32px
  10: '2.5rem',     // 40px
  12: '3rem',       // 48px
  16: '4rem',       // 64px
  20: '5rem',       // 80px
  24: '6rem',       // 96px
} as const;

// =============================================================================
// BORDER RADIUS
// =============================================================================

export const borderRadius = {
  none: '0',
  sm: '0.125rem',    // 2px
  DEFAULT: '0.25rem', // 4px
  md: '0.375rem',    // 6px
  lg: '0.5rem',      // 8px
  xl: '0.75rem',     // 12px
  '2xl': '1rem',     // 16px
  '3xl': '1.5rem',   // 24px - for cards
  full: '9999px',    // Pills, avatars
} as const;

// =============================================================================
// Z-INDEX SCALE
// =============================================================================

export const zIndex = {
  hide: -1,
  auto: 'auto',
  base: 0,
  dropdown: 1000,
  sticky: 1100,
  fixed: 1200,
  overlay: 1300,
  modal: 1400,
  popover: 1500,
  toast: 1600,
  tooltip: 1700,
} as const;

// =============================================================================
// TRANSITIONS
// =============================================================================

export const transitions = {
  fast: '150ms ease-out',
  normal: '200ms ease-out',
  slow: '300ms ease-out',
  spring: '300ms cubic-bezier(0.16, 1, 0.3, 1)',
} as const;

// =============================================================================
// BREAKPOINTS
// =============================================================================

export const breakpoints = {
  sm: '640px',
  md: '768px',
  lg: '1024px',
  xl: '1280px',
  '2xl': '1536px',
} as const;

// =============================================================================
// THEME TYPES
// =============================================================================

export type ThemeMode = 'light' | 'dark' | 'system';

export interface ThemeColors {
  // Brand
  primary: string;
  primaryDark: string;
  primaryLight: string;
  
  // Backgrounds
  background: string;
  surface: string;
  surfaceHover: string;
  
  // Chat
  chatBackground: string;
  chatPattern: string;
  messageBubble: string;
  messageBubbleOwn: string;
  
  // Sidebar
  sidebarBackground: string;
  sidebarBorder: string;
  
  // Text
  textPrimary: string;
  textSecondary: string;
  textTertiary: string;
  textInverse: string;
  
  // Borders
  border: string;
  borderHover: string;
  borderFocus: string;
  
  // States
  error: string;
  warning: string;
  success: string;
  info: string;
}

/**
 * Light theme colors
 */
export const lightTheme: ThemeColors = {
  primary: guardynColors[500],
  primaryDark: guardynColors[600],
  primaryLight: guardynColors[400],
  
  background: '#ffffff',
  surface: grayColors[50],
  surfaceHover: grayColors[100],
  
  chatBackground: chatBackgrounds.light.main,
  chatPattern: chatBackgrounds.light.pattern,
  messageBubble: chatBackgrounds.light.bubble,
  messageBubbleOwn: guardynColors[500],
  
  sidebarBackground: sidebarBackgrounds.light,
  sidebarBorder: sidebarBackgrounds.border.light,
  
  textPrimary: grayColors[900],
  textSecondary: grayColors[600],
  textTertiary: grayColors[400],
  textInverse: '#ffffff',
  
  border: grayColors[200],
  borderHover: grayColors[300],
  borderFocus: guardynColors[500],
  
  error: semanticColors.error.main,
  warning: semanticColors.warning.main,
  success: semanticColors.success.main,
  info: semanticColors.info.main,
};

/**
 * Dark theme colors (smart inversion)
 */
export const darkTheme: ThemeColors = {
  primary: guardynColors[500],
  primaryDark: guardynColors[400],
  primaryLight: guardynColors[600],
  
  background: grayColors[950],
  surface: grayColors[900],
  surfaceHover: grayColors[800],
  
  chatBackground: chatBackgrounds.dark.main,
  chatPattern: chatBackgrounds.dark.pattern,
  messageBubble: chatBackgrounds.dark.bubble,
  messageBubbleOwn: guardynColors[600],
  
  sidebarBackground: sidebarBackgrounds.dark,
  sidebarBorder: sidebarBackgrounds.border.dark,
  
  textPrimary: grayColors[50],
  textSecondary: grayColors[400],
  textTertiary: grayColors[500],
  textInverse: grayColors[900],
  
  border: grayColors[800],
  borderHover: grayColors[700],
  borderFocus: guardynColors[500],
  
  error: semanticColors.error.main,
  warning: semanticColors.warning.main,
  success: semanticColors.success.main,
  info: semanticColors.info.main,
};

/**
 * Get theme by mode
 */
export function getTheme(mode: 'light' | 'dark'): ThemeColors {
  return mode === 'light' ? lightTheme : darkTheme;
}
