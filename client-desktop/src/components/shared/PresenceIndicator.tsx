/**
 * PresenceIndicator Component
 *
 * Shows a colored dot indicating user presence status.
 * Animated pulse for online status.
 * Integrates with presenceStore for real-time data.
 */

import { Component, Show, createMemo } from 'solid-js';
import type { PresenceStatus } from '../../api/websocket.types';
import {
    createPresenceMemo,
    formatLastSeen,
    getStatusText,
} from '../../stores/presenceStore';

// =============================================================================
// TYPES
// =============================================================================

export type IndicatorSize = 'sm' | 'md' | 'lg';

export interface PresenceIndicatorProps {
  /** User ID to show presence for (reactive) */
  userId?: string;
  /** Presence status (used if userId is not provided) */
  status?: PresenceStatus;
  /** Size of the indicator */
  size?: IndicatorSize;
  /** Whether to show pulse animation for online status */
  animate?: boolean;
  /** Whether to show last seen tooltip on hover */
  showLastSeen?: boolean;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const STATUS_COLORS: Record<PresenceStatus, string> = {
  online: 'bg-green-500',
  away: 'bg-yellow-500',
  do_not_disturb: 'bg-red-500',
  offline: 'bg-gray-400 dark:bg-gray-500',
};

const STATUS_LABELS: Record<PresenceStatus, string> = {
  online: 'Online',
  away: 'Away',
  do_not_disturb: 'Do not disturb',
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
 * Can be used in two modes:
 * 1. With userId - automatically fetches presence from store
 * 2. With status - uses provided status directly
 *
 * @example
 * ```tsx
 * // With userId (reactive from store)
 * <PresenceIndicator userId="user-123" showLastSeen />
 *
 * // With static status
 * <PresenceIndicator status="online" animate />
 * <PresenceIndicator status="away" size="lg" />
 * ```
 */
export const PresenceIndicator: Component<PresenceIndicatorProps> = (props) => {
  // Create reactive presence memo if userId is provided
  const userPresence = createMemo(() => {
    if (props.userId) {
      const presenceMemo = createPresenceMemo(props.userId);
      return presenceMemo();
    }
    return undefined;
  });

  // Determine the actual status to display
  const currentStatus = createMemo((): PresenceStatus => {
    if (props.userId && userPresence()) {
      return userPresence()!.status;
    }
    return props.status ?? 'offline';
  });

  // Get last seen text if available
  const lastSeenText = createMemo(() => {
    const presence = userPresence();
    if (!presence || !presence.lastSeen) return undefined;
    return formatLastSeen(presence.lastSeen);
  });

  // Build tooltip text
  const tooltipText = createMemo(() => {
    const status = getStatusText(currentStatus());
    const lastSeen = lastSeenText();

    if (currentStatus() === 'offline' && lastSeen && props.showLastSeen) {
      return `${status} • Last seen ${lastSeen}`;
    }
    return status;
  });

  const size = () => props.size ?? 'md';
  const shouldAnimate = () => props.animate !== false && currentStatus() === 'online';

  return (
    <div
      class={`
        relative inline-flex items-center justify-center
        group
        ${props.class ?? ''}
      `}
      role="status"
      aria-label={STATUS_LABELS[currentStatus()]}
      title={tooltipText()}
    >
      {/* Main indicator dot */}
      <span
        class={`
          ${SIZE_CLASSES[size()]}
          ${STATUS_COLORS[currentStatus()]}
          rounded-full
          transition-colors duration-200
        `}
      />

      {/* Animated pulse ring for online status */}
      <Show when={shouldAnimate()}>
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
      </Show>

      {/* Last seen tooltip (enhanced) */}
      <Show when={props.showLastSeen && currentStatus() === 'offline' && lastSeenText()}>
        <div
          class="
            absolute z-50 bottom-full left-1/2 -translate-x-1/2 mb-2
            px-2 py-1 text-xs whitespace-nowrap
            bg-gray-900 dark:bg-gray-700 text-white
            rounded shadow-lg
            opacity-0 group-hover:opacity-100
            transition-opacity duration-200
            pointer-events-none
          "
        >
          Last seen {lastSeenText()}
          <div
            class="
              absolute top-full left-1/2 -translate-x-1/2
              border-4 border-transparent border-t-gray-900
              dark:border-t-gray-700
            "
          />
        </div>
      </Show>
    </div>
  );
};

export default PresenceIndicator;

// Re-export PresenceStatus type for convenience
export type { PresenceStatus };
