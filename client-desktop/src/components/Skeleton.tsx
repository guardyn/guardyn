/**
 * Skeleton Loading Components
 *
 * Provides skeleton placeholders for content loading states.
 * Improves perceived performance by showing content structure before data loads.
 */

import { Component, For } from 'solid-js';

/**
 * Base skeleton pulse animation class
 */
const pulseClass = 'animate-pulse bg-gray-300/50 dark:bg-gray-700/50 rounded';

/**
 * Generic skeleton box
 */
interface SkeletonBoxProps {
  width?: string;
  height?: string;
  class?: string;
  rounded?: 'none' | 'sm' | 'md' | 'lg' | 'full';
}

export const SkeletonBox: Component<SkeletonBoxProps> = (props) => {
  const roundedClasses = {
    none: 'rounded-none',
    sm: 'rounded-sm',
    md: 'rounded-md',
    lg: 'rounded-lg',
    full: 'rounded-full',
  };

  return (
    <div
      class={`animate-pulse bg-gray-300/50 dark:bg-gray-700/50 ${roundedClasses[props.rounded || 'md']} ${props.class || ''}`}
      style={{
        width: props.width || '100%',
        height: props.height || '1rem',
      }}
      role="status"
      aria-label="Loading..."
    />
  );
};

/**
 * Skeleton text line
 */
interface SkeletonTextProps {
  lines?: number;
  class?: string;
}

export const SkeletonText: Component<SkeletonTextProps> = (props) => {
  const lineCount = props.lines || 1;

  return (
    <div class={`space-y-2 ${props.class || ''}`} role="status" aria-label="Loading text...">
      <For each={Array(lineCount).fill(0)}>
        {(_, index) => (
          <div
            class={`${pulseClass} h-4`}
            style={{
              width: index() === lineCount - 1 && lineCount > 1 ? '75%' : '100%',
            }}
          />
        )}
      </For>
    </div>
  );
};

/**
 * Skeleton avatar
 */
interface SkeletonAvatarProps {
  size?: 'sm' | 'md' | 'lg' | 'xl';
  class?: string;
}

export const SkeletonAvatar: Component<SkeletonAvatarProps> = (props) => {
  const sizeClasses = {
    sm: 'w-8 h-8',
    md: 'w-10 h-10',
    lg: 'w-12 h-12',
    xl: 'w-16 h-16',
  };

  return (
    <div
      class={`${pulseClass} rounded-full ${sizeClasses[props.size || 'md']} ${props.class || ''}`}
      role="status"
      aria-label="Loading avatar..."
    />
  );
};

/**
 * Skeleton for conversation list item
 */
export const SkeletonConversationItem: Component = () => {
  return (
    <div
      class="flex items-center gap-3 p-3 rounded-lg"
      role="status"
      aria-label="Loading conversation..."
    >
      <SkeletonAvatar size="lg" />
      <div class="flex-1 min-w-0">
        <SkeletonBox height="1rem" width="60%" class="mb-2" />
        <SkeletonBox height="0.75rem" width="80%" />
      </div>
      <SkeletonBox height="0.75rem" width="2.5rem" />
    </div>
  );
};

/**
 * Skeleton for conversation list
 */
interface SkeletonConversationListProps {
  count?: number;
}

export const SkeletonConversationList: Component<SkeletonConversationListProps> = (props) => {
  const count = props.count || 5;

  return (
    <div class="space-y-1" role="status" aria-label="Loading conversations...">
      <For each={Array(count).fill(0)}>
        {() => <SkeletonConversationItem />}
      </For>
    </div>
  );
};

/**
 * Skeleton for message bubble
 */
interface SkeletonMessageProps {
  isOwn?: boolean;
}

export const SkeletonMessage: Component<SkeletonMessageProps> = (props) => {
  const alignment = props.isOwn ? 'justify-end' : 'justify-start';
  const bgColor = props.isOwn ? 'bg-guardyn-800/30' : 'bg-gray-300/30 dark:bg-gray-700/30';

  return (
    <div class={`flex ${alignment}`} role="status" aria-label="Loading message...">
      <div class={`max-w-[70%] ${bgColor} rounded-2xl p-3 animate-pulse`}>
        <SkeletonText lines={2} />
        <SkeletonBox height="0.625rem" width="3rem" class="mt-2 ml-auto" />
      </div>
    </div>
  );
};

/**
 * Skeleton for message list
 */
interface SkeletonMessageListProps {
  count?: number;
}

export const SkeletonMessageList: Component<SkeletonMessageListProps> = (props) => {
  const count = props.count || 6;
  // Alternate between own and other messages - this is data preparation, not rendering
  // eslint-disable-next-line solid/prefer-for
  const messages = Array(count)
    .fill(0)
    .map((_, i) => i % 3 !== 0);

  return (
    <div class="space-y-3 p-4" role="status" aria-label="Loading messages...">
      <For each={messages}>
        {(isOwn) => <SkeletonMessage isOwn={isOwn} />}
      </For>
    </div>
  );
};

/**
 * Skeleton for user profile card
 */
export const SkeletonProfileCard: Component = () => {
  return (
    <div
      class="flex items-center gap-4 p-4 rounded-lg bg-gray-100/50 dark:bg-gray-800/50"
      role="status"
      aria-label="Loading profile..."
    >
      <SkeletonAvatar size="xl" />
      <div class="flex-1">
        <SkeletonBox height="1.25rem" width="40%" class="mb-2" />
        <SkeletonBox height="0.875rem" width="60%" />
      </div>
    </div>
  );
};

/**
 * Skeleton for settings section
 */
export const SkeletonSettingsSection: Component = () => {
  return (
    <div class="space-y-4" role="status" aria-label="Loading settings...">
      <SkeletonBox height="1.5rem" width="30%" class="mb-4" />
      <For each={Array(4).fill(0)}>
        {() => (
          <div class="flex items-center justify-between py-3">
            <div class="flex-1">
              <SkeletonBox height="1rem" width="40%" class="mb-1" />
              <SkeletonBox height="0.75rem" width="60%" />
            </div>
            <SkeletonBox height="1.5rem" width="3rem" rounded="full" />
          </div>
        )}
      </For>
    </div>
  );
};

/**
 * Skeleton for call participant
 */
export const SkeletonCallParticipant: Component = () => {
  return (
    <div
      class="flex flex-col items-center justify-center p-4 bg-gray-100/50 dark:bg-gray-800/50 rounded-xl animate-pulse"
      role="status"
      aria-label="Loading participant..."
    >
      <SkeletonAvatar size="xl" />
      <SkeletonBox height="1rem" width="5rem" class="mt-3" />
      <SkeletonBox height="0.75rem" width="3rem" class="mt-1" />
    </div>
  );
};

/**
 * Skeleton for search result item
 */
export const SkeletonSearchResult: Component = () => {
  return (
    <div
      class="flex items-center gap-3 p-3 rounded-lg"
      role="status"
      aria-label="Loading search result..."
    >
      <SkeletonAvatar size="md" />
      <div class="flex-1">
        <SkeletonBox height="1rem" width="50%" class="mb-1" />
        <SkeletonBox height="0.75rem" width="30%" />
      </div>
    </div>
  );
};

/**
 * Full page loading skeleton
 */
interface FullPageSkeletonProps {
  type: 'chat' | 'settings' | 'call';
}

export const FullPageSkeleton: Component<FullPageSkeletonProps> = (props) => {
  switch (props.type) {
    case 'chat':
      return (
        <div class="flex h-full">
          {/* Sidebar skeleton */}
          <div class="w-72 border-r border-gray-700 p-4">
            <SkeletonBox height="2.5rem" class="mb-4" />
            <SkeletonConversationList count={8} />
          </div>
          {/* Main content skeleton */}
          <div class="flex-1 flex flex-col">
            {/* Header */}
            <div class="h-16 border-b border-gray-700 px-4 flex items-center gap-3">
              <SkeletonAvatar />
              <SkeletonBox height="1rem" width="10rem" />
            </div>
            {/* Messages */}
            <div class="flex-1 overflow-hidden">
              <SkeletonMessageList count={8} />
            </div>
            {/* Input */}
            <div class="h-16 border-t border-gray-700 px-4 flex items-center gap-2">
              <SkeletonBox height="2.5rem" class="flex-1" rounded="lg" />
              <SkeletonBox height="2.5rem" width="2.5rem" rounded="full" />
            </div>
          </div>
        </div>
      );

    case 'settings':
      return (
        <div class="max-w-2xl mx-auto p-6">
          <SkeletonBox height="2rem" width="12rem" class="mb-8" />
          <SkeletonProfileCard />
          <div class="mt-8 space-y-8">
            <SkeletonSettingsSection />
            <SkeletonSettingsSection />
          </div>
        </div>
      );

    case 'call':
      return (
        <div class="flex flex-col items-center justify-center h-full p-8">
          <div class="grid grid-cols-2 gap-4 mb-8">
            <SkeletonCallParticipant />
            <SkeletonCallParticipant />
          </div>
          <div class="flex gap-4">
            <SkeletonBox height="3.5rem" width="3.5rem" rounded="full" />
            <SkeletonBox height="3.5rem" width="3.5rem" rounded="full" />
            <SkeletonBox height="3.5rem" width="3.5rem" rounded="full" />
          </div>
        </div>
      );
  }
};

/**
 * Inline loading indicator with text
 */
interface LoadingIndicatorProps {
  text?: string;
  size?: 'sm' | 'md' | 'lg';
}

export const LoadingIndicator: Component<LoadingIndicatorProps> = (props) => {
  const sizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  };

  return (
    <div
      class={`flex items-center gap-2 text-gray-400 ${sizeClasses[props.size || 'md']}`}
      role="status"
      aria-label={props.text || 'Loading...'}
    >
      <svg class="animate-spin w-5 h-5" fill="none" viewBox="0 0 24 24">
        <circle
          class="opacity-25"
          cx="12"
          cy="12"
          r="10"
          stroke="currentColor"
          stroke-width="4"
        />
        <path
          class="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
      {props.text && <span>{props.text}</span>}
    </div>
  );
};

export default SkeletonBox;
