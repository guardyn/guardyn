/**
 * Badge Component
 * 
 * Displays a count badge with optional max display (99+).
 * Supports different variants and sizes.
 */

import { Component, Show, createMemo } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type BadgeVariant = 'primary' | 'secondary' | 'success' | 'warning' | 'error';
export type BadgeSize = 'sm' | 'md' | 'lg';

export interface BadgeProps {
  /** Count to display */
  count?: number;
  /** Text content (alternative to count) */
  text?: string;
  /** Maximum count before showing "+" */
  max?: number;
  /** Badge variant */
  variant?: BadgeVariant;
  /** Badge size */
  size?: BadgeSize;
  /** Whether to show as a dot without content */
  dot?: boolean;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const VARIANT_CLASSES: Record<BadgeVariant, string> = {
  primary: 'bg-guardyn-500 text-white',
  secondary: 'bg-gray-500 text-white',
  success: 'bg-green-500 text-white',
  warning: 'bg-yellow-500 text-white',
  error: 'bg-red-500 text-white',
};

const SIZE_CLASSES: Record<BadgeSize, { container: string; text: string }> = {
  sm: { container: 'min-w-[1rem] h-4 px-1', text: 'text-[10px]' },
  md: { container: 'min-w-[1.25rem] h-5 px-1.5', text: 'text-xs' },
  lg: { container: 'min-w-[1.5rem] h-6 px-2', text: 'text-sm' },
};

const DOT_SIZES: Record<BadgeSize, string> = {
  sm: 'w-2 h-2',
  md: 'w-2.5 h-2.5',
  lg: 'w-3 h-3',
};

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * Badge displays a count or status indicator.
 * 
 * @example
 * ```tsx
 * // Count badge
 * <Badge count={5} />
 * 
 * // With max
 * <Badge count={150} max={99} />
 * 
 * // Text badge
 * <Badge text="New" variant="success" />
 * 
 * // Dot indicator
 * <Badge dot variant="error" />
 * ```
 */
export const Badge: Component<BadgeProps> = (props) => {
  const variant = () => props.variant ?? 'primary';
  const size = () => props.size ?? 'md';
  const maxCount = () => props.max ?? 99;

  const displayText = createMemo(() => {
    if (props.text) return props.text;
    if (props.count === undefined) return '';
    if (props.count > maxCount()) return `${maxCount()}+`;
    return String(props.count);
  });

  const shouldShow = () => {
    if (props.dot) return true;
    if (props.text) return true;
    return props.count !== undefined && props.count > 0;
  };

  const sizeClasses = () => SIZE_CLASSES[size()];

  return (
    <Show when={shouldShow()}>
      <Show
        when={!props.dot}
        fallback={
          <span
            class={`
              ${DOT_SIZES[size()]}
              ${VARIANT_CLASSES[variant()]}
              rounded-full
              ${props.class ?? ''}
            `}
          />
        }
      >
        <span
          class={`
            inline-flex items-center justify-center
            ${sizeClasses().container}
            ${sizeClasses().text}
            ${VARIANT_CLASSES[variant()]}
            rounded-full
            font-medium
            ${props.class ?? ''}
          `}
        >
          {displayText()}
        </span>
      </Show>
    </Show>
  );
};

export default Badge;
