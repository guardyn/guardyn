/**
 * EmptyState Component
 * 
 * Displays an empty state with icon, message, and optional action.
 * Used when there's no data to show.
 */

import { Component, JSX, Show } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface EmptyStateProps {
  /** Custom icon component */
  icon?: JSX.Element;
  /** Main title text */
  title: string;
  /** Description text */
  description?: string;
  /** Action button text */
  actionLabel?: string;
  /** Action button callback */
  onAction?: () => void;
  /** Size variant */
  size?: 'sm' | 'md' | 'lg';
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// ICONS
// =============================================================================

const DefaultIcon: Component<{ class?: string }> = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    stroke-width="2"
    stroke-linecap="round"
    stroke-linejoin="round"
    class={props.class ?? 'w-12 h-12'}
  >
    <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
  </svg>
);

// =============================================================================
// CONSTANTS
// =============================================================================

const SIZE_CLASSES = {
  sm: {
    container: 'py-6 px-4',
    icon: 'w-8 h-8 mb-2',
    title: 'text-sm font-medium',
    description: 'text-xs',
    button: 'text-xs px-3 py-1.5',
  },
  md: {
    container: 'py-8 px-6',
    icon: 'w-12 h-12 mb-3',
    title: 'text-base font-medium',
    description: 'text-sm',
    button: 'text-sm px-4 py-2',
  },
  lg: {
    container: 'py-12 px-8',
    icon: 'w-16 h-16 mb-4',
    title: 'text-lg font-semibold',
    description: 'text-base',
    button: 'text-base px-5 py-2.5',
  },
};

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * EmptyState displays a placeholder when there's no content.
 * 
 * @example
 * ```tsx
 * // Basic usage
 * <EmptyState
 *   title="No messages yet"
 *   description="Start a conversation to see messages here"
 * />
 * 
 * // With action
 * <EmptyState
 *   title="No contacts"
 *   description="Add contacts to start messaging"
 *   actionLabel="Add Contact"
 *   onAction={() => setShowAddContact(true)}
 * />
 * 
 * // Custom icon
 * <EmptyState
 *   icon={<SearchIcon class="w-12 h-12" />}
 *   title="No results found"
 *   description="Try adjusting your search"
 * />
 * ```
 */
export const EmptyState: Component<EmptyStateProps> = (props) => {
  const size = () => props.size ?? 'md';
  const classes = () => SIZE_CLASSES[size()];

  return (
    <div
      class={`
        flex flex-col items-center justify-center text-center
        ${classes().container}
        ${props.class ?? ''}
      `}
    >
      {/* Icon */}
      <div class={`text-gray-300 dark:text-gray-600 ${classes().icon}`}>
        <Show when={props.icon} fallback={<DefaultIcon class="w-full h-full" />}>
          {props.icon}
        </Show>
      </div>

      {/* Title */}
      <h3 class={`text-gray-900 dark:text-white ${classes().title}`}>
        {props.title}
      </h3>

      {/* Description */}
      <Show when={props.description}>
        <p class={`text-gray-500 dark:text-gray-400 mt-1 max-w-xs ${classes().description}`}>
          {props.description}
        </p>
      </Show>

      {/* Action button */}
      <Show when={props.actionLabel && props.onAction}>
        <button
          onClick={() => props.onAction?.()}
          class={`
            mt-4 ${classes().button}
            bg-guardyn-500 hover:bg-guardyn-600
            text-white font-medium
            rounded-lg
            transition-colors duration-200
            focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:ring-offset-2
          `}
        >
          {props.actionLabel}
        </button>
      </Show>
    </div>
  );
};

export default EmptyState;
