/**
 * PresenceIndicator Component
 * 
 * Shows a colored dot indicating user presence status.
 * Animated pulse for online status.
 */

import { Component } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type PresenceStatus = 'online' | 'offline' | 'away' | 'busy';
export type IndicatorSize = 'sm' | 'md' | 'lg';

export interface PresenceIndicatorProps {
  /** Presence status */
  status: PresenceStatus;
  /** Size of the indicator */
  size?: IndicatorSize;
  /** Whether to show pulse animation for online status */
  animate?: boolean;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const STATUS_COLORS: Record<PresenceStatus, string> = {
  online: 'bg-green-500',
  away: 'bg-yellow-500',
  busy: 'bg-red-500',
  offline: 'bg-gray-400 dark:bg-gray-500',
};

const STATUS_LABELS: Record<PresenceStatus, string> = {
  online: 'Online',
  away: 'Away',
  busy: 'Do not disturb',
  offline: 'Offline',
};

const SIZE_CLASSES: Record<IndicatorSize, string> = {
  sm: 'w-2 h-2',
  md: 'w-2.5 h-2.5',
  lg: 'w-3 h-3',
};

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * PresenceIndicator displays a status dot with optional animation.
 * 
 * @example
 * ```tsx
 * <PresenceIndicator status="online" animate />
 * <PresenceIndicator status="away" size="lg" />
 * <PresenceIndicator status="busy" />
 * ```
 */
export const PresenceIndicator: Component<PresenceIndicatorProps> = (props) => {
  const size = () => props.size ?? 'md';
  const shouldAnimate = () => props.animate !== false && props.status === 'online';

  return (
    <div
      class={`
        relative inline-flex items-center justify-center
        ${props.class ?? ''}
      `}
      role="status"
      aria-label={STATUS_LABELS[props.status]}
    >
      {/* Main indicator dot */}
      <span
        class={`
          ${SIZE_CLASSES[size()]}
          ${STATUS_COLORS[props.status]}
          rounded-full
        `}
      />
      
      {/* Animated pulse ring for online status */}
      {shouldAnimate() && (
        <span
          class={`
            absolute
            ${SIZE_CLASSES[size()]}
            bg-green-500
            rounded-full
            animate-ping
            opacity-75
          `}
        />
      )}
    </div>
  );
};

export default PresenceIndicator;
