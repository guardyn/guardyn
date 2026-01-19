/**
 * Theme Context for Guardyn Desktop
 * 
 * Provides theme switching (light/dark/system) with localStorage persistence.
 * Automatically responds to system preference changes.
 */

import {
    createContext,
    createEffect,
    createSignal,
    onCleanup,
    onMount,
    useContext,
    type Accessor,
    type ParentComponent,
} from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type ThemeMode = 'light' | 'dark' | 'system';
export type ResolvedTheme = 'light' | 'dark';

interface ThemeContextValue {
  /** Current theme mode setting (light/dark/system) */
  mode: Accessor<ThemeMode>;
  /** Resolved theme after applying system preference */
  resolvedTheme: Accessor<ResolvedTheme>;
  /** Set the theme mode */
  setMode: (mode: ThemeMode) => void;
  /** Toggle between light and dark (ignores system) */
  toggle: () => void;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const STORAGE_KEY = 'guardyn-theme';
const DEFAULT_MODE: ThemeMode = 'system';

// =============================================================================
// CONTEXT
// =============================================================================

const ThemeContext = createContext<ThemeContextValue>();

// =============================================================================
// UTILITIES
// =============================================================================

/**
 * Get the system preference for color scheme
 */
function getSystemPreference(): ResolvedTheme {
  if (typeof window === 'undefined') return 'dark';
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

/**
 * Load theme mode from localStorage
 */
function loadStoredMode(): ThemeMode {
  if (typeof window === 'undefined') return DEFAULT_MODE;
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === 'light' || stored === 'dark' || stored === 'system') {
    return stored;
  }
  return DEFAULT_MODE;
}

/**
 * Save theme mode to localStorage
 */
function saveMode(mode: ThemeMode): void {
  if (typeof window !== 'undefined') {
    localStorage.setItem(STORAGE_KEY, mode);
  }
}

/**
 * Resolve the actual theme from mode and system preference
 */
function resolveTheme(mode: ThemeMode): ResolvedTheme {
  if (mode === 'system') {
    return getSystemPreference();
  }
  return mode;
}

/**
 * Apply theme class to document
 */
function applyThemeToDocument(theme: ResolvedTheme): void {
  if (typeof document !== 'undefined') {
    const root = document.documentElement;
    root.classList.remove('light', 'dark');
    root.classList.add(theme);
    
    // Also update meta theme-color for mobile browsers
    const metaThemeColor = document.querySelector('meta[name="theme-color"]');
    if (metaThemeColor) {
      metaThemeColor.setAttribute(
        'content',
        theme === 'dark' ? '#09090b' : '#ffffff'
      );
    }
  }
}

// =============================================================================
// PROVIDER
// =============================================================================

export const ThemeProvider: ParentComponent = (props) => {
  const [mode, setModeSignal] = createSignal<ThemeMode>(loadStoredMode());
  const [resolvedTheme, setResolvedTheme] = createSignal<ResolvedTheme>(
    resolveTheme(loadStoredMode())
  );

  // Set theme mode with persistence
  const setMode = (newMode: ThemeMode) => {
    setModeSignal(newMode);
    saveMode(newMode);
    setResolvedTheme(resolveTheme(newMode));
  };

  // Toggle between light and dark
  const toggle = () => {
    const current = resolvedTheme();
    setMode(current === 'dark' ? 'light' : 'dark');
  };

  // Apply theme to document when resolved theme changes
  createEffect(() => {
    applyThemeToDocument(resolvedTheme());
  });

  // Listen for system preference changes
  onMount(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)');
    
    const handleChange = () => {
      // Only update if using system mode
      if (mode() === 'system') {
        setResolvedTheme(getSystemPreference());
      }
    };

    mediaQuery.addEventListener('change', handleChange);
    
    onCleanup(() => {
      mediaQuery.removeEventListener('change', handleChange);
    });
  });

  // Initial application of theme
  onMount(() => {
    applyThemeToDocument(resolvedTheme());
  });

  const contextValue: ThemeContextValue = {
    mode,
    resolvedTheme,
    setMode,
    toggle,
  };

  return (
    <ThemeContext.Provider value={contextValue}>
      {props.children}
    </ThemeContext.Provider>
  );
};

// =============================================================================
// HOOK
// =============================================================================

/**
 * Use the theme context
 * 
 * @example
 * ```tsx
 * const { mode, resolvedTheme, setMode, toggle } = useTheme();
 * 
 * // Check current theme
 * if (resolvedTheme() === 'dark') { ... }
 * 
 * // Set specific mode
 * setMode('system');
 * 
 * // Toggle between light/dark
 * toggle();
 * ```
 */
export function useTheme(): ThemeContextValue {
  const context = useContext(ThemeContext);
  if (!context) {
    throw new Error('useTheme must be used within a ThemeProvider');
  }
  return context;
}

// =============================================================================
// EXPORTS
// =============================================================================

export { ThemeContext };
