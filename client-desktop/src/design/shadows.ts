/**
 * Guardyn Shadow & Effect Tokens
 * 
 * Includes:
 * - Elevation shadows
 * - Glassmorphism effects
 * - Neumorphic shadows
 */

// =============================================================================
// ELEVATION SHADOWS
// =============================================================================

/**
 * Standard elevation shadows (Material-inspired)
 */
export const elevation = {
  none: 'none',
  
  sm: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
  
  DEFAULT: '0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1)',
  
  md: '0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1)',
  
  lg: '0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1)',
  
  xl: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)',
  
  '2xl': '0 25px 50px -12px rgb(0 0 0 / 0.25)',
  
  inner: 'inset 0 2px 4px 0 rgb(0 0 0 / 0.05)',
} as const;

// =============================================================================
// GLASSMORPHISM
// =============================================================================

/**
 * Glassmorphism effect configurations
 * Use with backdrop-blur and semi-transparent backgrounds
 */
export const glass = {
  blur: {
    sm: '4px',
    md: '12px',
    lg: '20px',
    xl: '40px',
  },
  
  background: {
    light: {
      subtle: 'rgba(255, 255, 255, 0.6)',
      medium: 'rgba(255, 255, 255, 0.7)',
      strong: 'rgba(255, 255, 255, 0.85)',
    },
    dark: {
      subtle: 'rgba(17, 24, 39, 0.6)',
      medium: 'rgba(17, 24, 39, 0.75)',
      strong: 'rgba(17, 24, 39, 0.9)',
    },
  },
  
  border: {
    light: 'rgba(255, 255, 255, 0.2)',
    dark: 'rgba(255, 255, 255, 0.1)',
  },
} as const;

/**
 * Pre-composed glassmorphism styles
 */
export const glassStyles = {
  card: {
    light: {
      background: glass.background.light.medium,
      backdropFilter: `blur(${glass.blur.lg})`,
      border: `1px solid ${glass.border.light}`,
      boxShadow: elevation.lg,
    },
    dark: {
      background: glass.background.dark.medium,
      backdropFilter: `blur(${glass.blur.lg})`,
      border: `1px solid ${glass.border.dark}`,
      boxShadow: elevation.lg,
    },
  },
  
  modal: {
    light: {
      background: glass.background.light.strong,
      backdropFilter: `blur(${glass.blur.xl})`,
      border: `1px solid ${glass.border.light}`,
      boxShadow: elevation['2xl'],
    },
    dark: {
      background: glass.background.dark.strong,
      backdropFilter: `blur(${glass.blur.xl})`,
      border: `1px solid ${glass.border.dark}`,
      boxShadow: elevation['2xl'],
    },
  },
  
  tooltip: {
    light: {
      background: glass.background.light.subtle,
      backdropFilter: `blur(${glass.blur.md})`,
      border: `1px solid ${glass.border.light}`,
      boxShadow: elevation.md,
    },
    dark: {
      background: glass.background.dark.subtle,
      backdropFilter: `blur(${glass.blur.md})`,
      border: `1px solid ${glass.border.dark}`,
      boxShadow: elevation.md,
    },
  },
} as const;

// =============================================================================
// NEUMORPHISM
// =============================================================================

/**
 * Neumorphic shadow configurations
 * Creates soft, raised appearance
 */
export const neumorphic = {
  light: {
    raised: {
      boxShadow: '6px 6px 12px #d1d9e6, -6px -6px 12px #ffffff',
    },
    pressed: {
      boxShadow: 'inset 4px 4px 8px #d1d9e6, inset -4px -4px 8px #ffffff',
    },
    subtle: {
      boxShadow: '3px 3px 6px #d1d9e6, -3px -3px 6px #ffffff',
    },
  },
  
  dark: {
    raised: {
      boxShadow: '6px 6px 12px #0a0a0a, -6px -6px 12px #1e1e1e',
    },
    pressed: {
      boxShadow: 'inset 4px 4px 8px #0a0a0a, inset -4px -4px 8px #1e1e1e',
    },
    subtle: {
      boxShadow: '3px 3px 6px #0a0a0a, -3px -3px 6px #1e1e1e',
    },
  },
} as const;

/**
 * Neumorphic button styles with states
 */
export const neumorphicButton = {
  light: {
    default: {
      background: '#f0f0f3',
      boxShadow: neumorphic.light.raised.boxShadow,
      transition: 'all 0.2s ease-out',
    },
    hover: {
      background: '#e8e8eb',
      boxShadow: neumorphic.light.subtle.boxShadow,
    },
    active: {
      background: '#f0f0f3',
      boxShadow: neumorphic.light.pressed.boxShadow,
    },
  },
  
  dark: {
    default: {
      background: '#141414',
      boxShadow: neumorphic.dark.raised.boxShadow,
      transition: 'all 0.2s ease-out',
    },
    hover: {
      background: '#1a1a1a',
      boxShadow: neumorphic.dark.subtle.boxShadow,
    },
    active: {
      background: '#141414',
      boxShadow: neumorphic.dark.pressed.boxShadow,
    },
  },
} as const;

// =============================================================================
// GLOW EFFECTS
// =============================================================================

/**
 * Glow effects for interactive elements
 */
export const glow = {
  primary: {
    sm: '0 0 8px rgba(34, 197, 94, 0.3)',
    md: '0 0 16px rgba(34, 197, 94, 0.4)',
    lg: '0 0 24px rgba(34, 197, 94, 0.5)',
  },
  
  error: {
    sm: '0 0 8px rgba(239, 68, 68, 0.3)',
    md: '0 0 16px rgba(239, 68, 68, 0.4)',
  },
  
  focus: {
    ring: '0 0 0 3px rgba(34, 197, 94, 0.2)',
    ringError: '0 0 0 3px rgba(239, 68, 68, 0.2)',
  },
} as const;

// =============================================================================
// CSS HELPER FUNCTIONS
// =============================================================================

/**
 * Generate glassmorphism CSS properties
 */
export function getGlassStyle(variant: 'card' | 'modal' | 'tooltip', theme: 'light' | 'dark') {
  return glassStyles[variant][theme];
}

/**
 * Generate neumorphic button CSS for current state
 */
export function getNeumorphicStyle(
  state: 'default' | 'hover' | 'active',
  theme: 'light' | 'dark'
) {
  return neumorphicButton[theme][state];
}

/**
 * Combine multiple shadow values
 */
export function combineShadows(...shadows: string[]): string {
  return shadows.filter(Boolean).join(', ');
}
