/**
 * Avatar Component
 * 
 * Displays a user avatar with fallback to initials.
 * Supports presence indicator and multiple sizes.
 */

import { Component, createSignal, Show } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export type AvatarSize = 'xs' | 'sm' | 'md' | 'lg' | 'xl';
export type PresenceStatus = 'online' | 'offline' | 'away' | 'busy';

export interface AvatarProps {
  /** Image source URL */
  src?: string;
  /** User name for initials fallback and alt text */
  name: string;
  /** Avatar size */
  size?: AvatarSize;
  /** Whether to show presence indicator */
  showPresence?: boolean;
  /** Presence status */
  presence?: PresenceStatus;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const SIZE_CLASSES: Record<AvatarSize, { container: string; text: string; indicator: string }> = {
  xs: { container: 'w-6 h-6', text: 'text-xs', indicator: 'w-2 h-2 border' },
  sm: { container: 'w-8 h-8', text: 'text-sm', indicator: 'w-2.5 h-2.5 border-2' },
  md: { container: 'w-10 h-10', text: 'text-base', indicator: 'w-3 h-3 border-2' },
  lg: { container: 'w-12 h-12', text: 'text-lg', indicator: 'w-3.5 h-3.5 border-2' },
  xl: { container: 'w-16 h-16', text: 'text-xl', indicator: 'w-4 h-4 border-2' },
};

const PRESENCE_COLORS: Record<PresenceStatus, string> = {
  online: 'bg-green-500',
  away: 'bg-yellow-500',
  busy: 'bg-red-500',
  offline: 'bg-gray-400',
};

// =============================================================================
// HELPERS
// =============================================================================

function getInitials(name: string): string {
  return name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
}

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * Avatar displays a user's profile image or initials fallback.
 * 
 * @example
 * ```tsx
 * // With image
 * <Avatar src="/avatar.jpg" name="Alice Johnson" size="lg" />
 * 
 * // With presence
 * <Avatar name="Bob Smith" showPresence presence="online" />
 * 
 * // Initials fallback
 * <Avatar name="Charlie Brown" size="md" />
 * ```
 */
export const Avatar: Component<AvatarProps> = (props) => {
  const [imageError, setImageError] = createSignal(false);
  const [imageLoading, setImageLoading] = createSignal(true);

  const size = () => props.size ?? 'md';
  const sizeClasses = () => SIZE_CLASSES[size()];

  const handleImageLoad = () => {
    setImageLoading(false);
  };

  const handleImageError = () => {
    setImageError(true);
    setImageLoading(false);
  };

  const showFallback = () => !props.src || imageError();

  return (
    <div class={`relative inline-flex ${props.class ?? ''}`}>
      {/* Avatar container */}
      <div
        class={`
          ${sizeClasses().container}
          rounded-full overflow-hidden
          flex items-center justify-center
          ${showFallback() 
            ? 'bg-gradient-to-br from-guardyn-400 to-guardyn-600' 
            : 'bg-gray-200 dark:bg-gray-700'
          }
          shadow-md
        `}
      >
        <Show
          when={!showFallback()}
          fallback={
            <span class={`${sizeClasses().text} font-medium text-white`}>
              {getInitials(props.name)}
            </span>
          }
        >
          {/* Loading skeleton */}
          <Show when={imageLoading()}>
            <div class={`absolute inset-0 bg-gray-200 dark:bg-gray-700 animate-pulse rounded-full`} />
          </Show>
          
          <img
            src={props.src}
            alt={props.name}
            onLoad={handleImageLoad}
            onError={handleImageError}
            class={`w-full h-full object-cover ${imageLoading() ? 'opacity-0' : 'opacity-100'} transition-opacity`}
          />
        </Show>
      </div>

      {/* Presence indicator */}
      <Show when={props.showPresence && props.presence}>
        <div
          class={`
            absolute bottom-0 right-0
            ${sizeClasses().indicator}
            ${PRESENCE_COLORS[props.presence ?? 'offline']}
            rounded-full
            border-white dark:border-gray-800
            ${props.presence === 'online' ? 'animate-pulse' : ''}
          `}
        />
      </Show>
    </div>
  );
};

export default Avatar;
