/**
 * Theme Switcher Component
 * 
 * Three-way toggle for light/dark/system theme modes.
 * Features smooth animations and neumorphic styling.
 */

import { Component, createMemo, For, Show } from 'solid-js';
import { useTheme, type ThemeMode } from '../contexts/ThemeContext';

// =============================================================================
// ICONS
// =============================================================================

const SunIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-5 h-5'}
  >
    <circle cx="12" cy="12" r="4" />
    <path d="M12 2v2" />
    <path d="M12 20v2" />
    <path d="m4.93 4.93 1.41 1.41" />
    <path d="m17.66 17.66 1.41 1.41" />
    <path d="M2 12h2" />
    <path d="M20 12h2" />
    <path d="m6.34 17.66-1.41 1.41" />
    <path d="m19.07 4.93-1.41 1.41" />
  </svg>
);

const MoonIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-5 h-5'}
  >
    <path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z" />
  </svg>
);

const SystemIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-5 h-5'}
  >
    <rect width="20" height="14" x="2" y="3" rx="2" />
    <line x1="8" x2="16" y1="21" y2="21" />
    <line x1="12" x2="12" y1="17" y2="21" />
  </svg>
);

// =============================================================================
// TYPES
// =============================================================================

interface ThemeSwitcherProps {
  /** Additional CSS classes */
  class?: string;
  /** Show labels next to icons */
  showLabels?: boolean;
  /** Compact mode (smaller size) */
  compact?: boolean;
}

interface ThemeOption {
  mode: ThemeMode;
  icon: Component<{ class?: string }>;
  label: string;
  shortLabel: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const THEME_OPTIONS: ThemeOption[] = [
  { mode: 'light', icon: SunIcon, label: 'Light Mode', shortLabel: 'Light' },
  { mode: 'dark', icon: MoonIcon, label: 'Dark Mode', shortLabel: 'Dark' },
  { mode: 'system', icon: SystemIcon, label: 'System', shortLabel: 'Auto' },
];

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * Theme Switcher with three modes: Light, Dark, System
 * 
 * @example
 * ```tsx
 * // Default usage
 * <ThemeSwitcher />
 * 
 * // With labels
 * <ThemeSwitcher showLabels />
 * 
 * // Compact mode
 * <ThemeSwitcher compact />
 * ```
 */
export const ThemeSwitcher: Component<ThemeSwitcherProps> = (props) => {
  const { mode, setMode } = useTheme();

  const buttonSize = createMemo(() => 
    props.compact ? 'w-8 h-8' : 'w-10 h-10'
  );

  const iconSize = createMemo(() => 
    props.compact ? 'w-4 h-4' : 'w-5 h-5'
  );

  return (
    <div
      class={`
        inline-flex items-center gap-1 p-1 rounded-xl
        bg-gray-100 dark:bg-gray-800
        ${props.class ?? ''}
      `}
      role="radiogroup"
      aria-label="Theme selection"
    >
      <For each={THEME_OPTIONS}>
        {(option) => {
          const isActive = () => mode() === option.mode;
          const Icon = option.icon;

          return (
            <button
              type="button"
              role="radio"
              aria-checked={isActive()}
              aria-label={option.label}
              title={option.label}
              onClick={() => setMode(option.mode)}
              class={`
                relative flex items-center justify-center gap-2
                ${buttonSize()} ${props.showLabels ? 'px-3' : ''}
                rounded-lg font-medium text-sm
                transition-all duration-200 ease-out
                focus:outline-none focus-visible:ring-2 focus-visible:ring-guardyn-500 focus-visible:ring-offset-2
                ${isActive()
                  ? `
                    bg-white dark:bg-gray-700
                    text-guardyn-600 dark:text-guardyn-400
                    shadow-md
                  `
                  : `
                    text-gray-500 dark:text-gray-400
                    hover:text-gray-700 dark:hover:text-gray-300
                    hover:bg-gray-200/50 dark:hover:bg-gray-700/50
                  `
                }
              `}
            >
              <Icon class={`${iconSize()} transition-transform ${isActive() ? 'scale-110' : ''}`} />
              <Show when={props.showLabels}>
                <span class="hidden sm:inline">{option.shortLabel}</span>
              </Show>
            </button>
          );
        }}
      </For>
    </div>
  );
};

// =============================================================================
// SIMPLE TOGGLE (Light/Dark only)
// =============================================================================

interface ThemeToggleProps {
  class?: string;
}

/**
 * Simple light/dark toggle button
 * 
 * @example
 * ```tsx
 * <ThemeToggle />
 * ```
 */
export const ThemeToggle: Component<ThemeToggleProps> = (props) => {
  const { resolvedTheme, toggle } = useTheme();

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={`Switch to ${resolvedTheme() === 'dark' ? 'light' : 'dark'} mode`}
      class={`
        relative p-2 rounded-lg
        text-gray-500 dark:text-gray-400
        hover:text-gray-700 dark:hover:text-gray-300
        hover:bg-gray-100 dark:hover:bg-gray-800
        transition-colors duration-200
        focus:outline-none focus-visible:ring-2 focus-visible:ring-guardyn-500
        ${props.class ?? ''}
      `}
    >
      <div class="relative w-5 h-5">
        {/* Sun icon - visible in dark mode */}
        <SunIcon
          class={`
            absolute inset-0 w-5 h-5
            transition-all duration-300
            ${resolvedTheme() === 'dark'
              ? 'opacity-100 rotate-0 scale-100'
              : 'opacity-0 rotate-90 scale-0'
            }
          `}
        />
        {/* Moon icon - visible in light mode */}
        <MoonIcon
          class={`
            absolute inset-0 w-5 h-5
            transition-all duration-300
            ${resolvedTheme() === 'light'
              ? 'opacity-100 rotate-0 scale-100'
              : 'opacity-0 -rotate-90 scale-0'
            }
          `}
        />
      </div>
    </button>
  );
};

// =============================================================================
// EXPORTS
// =============================================================================

export default ThemeSwitcher;
