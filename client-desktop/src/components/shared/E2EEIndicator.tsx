/**
 * E2EE Indicator Component
 *
 * Visual indicator showing end-to-end encryption status.
 * Used in chat headers and group info pages to show users
 * that their messages are protected by end-to-end encryption.
 */

import { Component, Show, JSX } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type E2EEStatus = 'encrypted' | 'mls' | 'not-encrypted' | 'verifying';

export interface E2EEIndicatorProps {
  /** Current encryption status */
  status: E2EEStatus;
  /** Whether to show the label next to the icon */
  showLabel?: boolean;
  /** Icon size in pixels */
  size?: number;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const STATUS_CONFIG: Record<
  E2EEStatus,
  {
    icon: string;
    label: string;
    color: string;
    tooltip: string;
  }
> = {
  encrypted: {
    icon: '🔒',
    label: 'E2EE',
    color: 'text-green-500',
    tooltip: 'Messages are end-to-end encrypted using Double Ratchet',
  },
  mls: {
    icon: '🔐',
    label: 'MLS',
    color: 'text-green-500',
    tooltip: 'Group messages are end-to-end encrypted using MLS (RFC 9420)',
  },
  'not-encrypted': {
    icon: '🔓',
    label: 'Not secure',
    color: 'text-red-500',
    tooltip: 'Messages are NOT encrypted. This conversation is not secure.',
  },
  verifying: {
    icon: '⏳',
    label: 'Verifying...',
    color: 'text-yellow-500',
    tooltip: 'Verifying encryption keys...',
  },
};

// =============================================================================
// COMPONENT
// =============================================================================

const E2EEIndicator: Component<E2EEIndicatorProps> = (props) => {
  const config = () => STATUS_CONFIG[props.status];
  const size = () => props.size || 16;

  return (
    <div
      class={`flex items-center gap-1 ${config().color} ${props.class || ''}`}
      title={config().tooltip}
      role="status"
      aria-label={`Encryption status: ${config().label}`}
    >
      <span
        class="select-none"
        style={{ 'font-size': `${size()}px` }}
        aria-hidden="true"
      >
        {config().icon}
      </span>
      <Show when={props.showLabel}>
        <span class="text-xs font-medium">{config().label}</span>
      </Show>
    </div>
  );
};

// =============================================================================
// ALTERNATIVE SVG ICON VERSION
// =============================================================================

/**
 * Alternative version using Material Icons or SVG.
 * Use this if you prefer a more consistent icon style.
 */
export const E2EEIndicatorSvg: Component<E2EEIndicatorProps> = (props) => {
  const config = () => STATUS_CONFIG[props.status];
  const size = () => props.size || 16;

  const renderIcon = (): JSX.Element => {
    const iconSize = size();
    const iconClass = `w-[${iconSize}px] h-[${iconSize}px]`;

    switch (props.status) {
      case 'encrypted':
        return (
          <svg
            class={iconClass}
            fill="currentColor"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z" />
          </svg>
        );
      case 'mls':
        return (
          <svg
            class={iconClass}
            fill="currentColor"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11V12z" />
          </svg>
        );
      case 'not-encrypted':
        return (
          <svg
            class={iconClass}
            fill="currentColor"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path d="M12 17c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm6-9h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6h1.9c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm0 12H6V10h12v10z" />
          </svg>
        );
      case 'verifying':
        return (
          <svg
            class={`${iconClass} animate-pulse`}
            fill="currentColor"
            viewBox="0 0 24 24"
            aria-hidden="true"
          >
            <path d="M6 2v6h.01L6 8.01 10 12l-4 4 .01.01H6V22h12v-5.99h-.01L18 16l-4-4 4-3.99-.01-.01H18V2H6zm10 14.5V20H8v-3.5l4-4 4 4zm-4-5l-4-4V4h8v3.5l-4 4z" />
          </svg>
        );
      default:
        return <span>{config().icon}</span>;
    }
  };

  return (
    <div
      class={`flex items-center gap-1 ${config().color} ${props.class || ''}`}
      title={config().tooltip}
      role="status"
      aria-label={`Encryption status: ${config().label}`}
    >
      {renderIcon()}
      <Show when={props.showLabel}>
        <span class="text-xs font-medium">{config().label}</span>
      </Show>
    </div>
  );
};

export default E2EEIndicator;
