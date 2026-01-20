/**
 * UserSearch Component
 *
 * A search component for finding users with debounced input,
 * presence indicators, and action buttons.
 *
 * @module components/UserSearch
 */

import {
  Component,
  createSignal,
  createEffect,
  For,
  Show,
  onCleanup,
} from 'solid-js';
import { Avatar } from './shared/Avatar';
import { PresenceIndicator } from './shared/PresenceIndicator';
import { Button } from './shared/Button';
import { TextInput } from './shared/TextInput';
import { Badge } from './shared/Badge';
import type { UserSearchResult, UserProfile } from '../api/users';
import { searchUsersMock } from '../api/users';

// =============================================================================
// TYPES
// =============================================================================

export interface UserSearchProps {
  /** Placeholder text for search input */
  placeholder?: string;
  /** Called when a user is selected */
  onSelect?: (user: UserProfile) => void;
  /** Called when message action is clicked */
  onMessage?: (user: UserProfile) => void;
  /** Called when add to group action is clicked */
  onAddToGroup?: (user: UserProfile) => void;
  /** Whether to show action buttons */
  showActions?: boolean;
  /** Filter to contacts only */
  contactsOnly?: boolean;
  /** Maximum results to show */
  maxResults?: number;
  /** Debounce delay in milliseconds */
  debounceMs?: number;
  /** Additional CSS classes */
  class?: string;
  /** Whether the component is in a modal (affects styling) */
  inModal?: boolean;
}

export interface UserCardProps {
  /** User data */
  user: UserProfile;
  /** Match highlight text */
  highlight?: string;
  /** Called when card is clicked */
  onClick?: () => void;
  /** Called when message button is clicked */
  onMessage?: () => void;
  /** Called when add to group button is clicked */
  onAddToGroup?: () => void;
  /** Whether to show action buttons */
  showActions?: boolean;
}

// =============================================================================
// USER CARD COMPONENT
// =============================================================================

/**
 * UserCard displays a user with avatar, presence, and action buttons
 */
export const UserCard: Component<UserCardProps> = (props) => {
  return (
    <div
      class={`
        flex items-center gap-3 p-3 rounded-lg
        bg-white dark:bg-gray-800
        hover:bg-gray-50 dark:hover:bg-gray-700
        border border-gray-200 dark:border-gray-700
        transition-colors duration-150
        cursor-pointer
      `}
      onClick={() => props.onClick?.()}
    >
      {/* Avatar with presence */}
      <div class="relative flex-shrink-0">
        <Avatar
          name={props.user.displayName}
          src={props.user.avatarUrl}
          size="md"
        />
        <div class="absolute -bottom-0.5 -right-0.5">
          <PresenceIndicator
            status={props.user.presenceStatus ?? 'offline'}
            size="sm"
          />
        </div>
      </div>

      {/* User info */}
      <div class="flex-1 min-w-0">
        <div class="flex items-center gap-2">
          <span class="font-medium text-gray-900 dark:text-white truncate">
            {props.user.displayName}
          </span>
          <Show when={props.user.isVerified}>
            <svg
              class="w-4 h-4 text-blue-500"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clip-rule="evenodd"
              />
            </svg>
          </Show>
          <Show when={props.user.isContact}>
            <Badge variant="success" size="sm" text="Contact" />
          </Show>
        </div>
        <div class="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
          <span class="truncate">@{props.user.username}</span>
          <Show when={props.user.bio}>
            <span class="hidden sm:inline">•</span>
            <span class="hidden sm:inline truncate">{props.user.bio}</span>
          </Show>
        </div>
      </div>

      {/* Action buttons */}
      <Show when={props.showActions}>
        <div class="flex items-center gap-2 flex-shrink-0">
          <Button
            variant="ghost"
            size="sm"
            onClick={(e) => {
              e.stopPropagation();
              props.onMessage?.();
            }}
            title="Send message"
          >
            <svg
              class="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z"
              />
            </svg>
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={(e) => {
              e.stopPropagation();
              props.onAddToGroup?.();
            }}
            title="Add to group"
          >
            <svg
              class="w-5 h-5"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"
              />
            </svg>
          </Button>
        </div>
      </Show>
    </div>
  );
};

// =============================================================================
// USER SEARCH COMPONENT
// =============================================================================

/**
 * UserSearch provides a search interface with results
 */
export const UserSearch: Component<UserSearchProps> = (props) => {
  const [query, setQuery] = createSignal('');
  const [results, setResults] = createSignal<UserSearchResult[]>([]);
  const [isLoading, setIsLoading] = createSignal(false);
  const [hasSearched, setHasSearched] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);

  let debounceTimer: ReturnType<typeof setTimeout> | null = null;

  const debounceMs = () => props.debounceMs ?? 300;
  const maxResults = () => props.maxResults ?? 10;

  // Cleanup debounce timer on unmount
  onCleanup(() => {
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }
  });

  // Debounced search effect
  createEffect(() => {
    const searchQuery = query();

    // Clear previous timer
    if (debounceTimer) {
      clearTimeout(debounceTimer);
    }

    // Clear results if query is empty
    if (!searchQuery.trim()) {
      setResults([]);
      setHasSearched(false);
      setError(null);
      return;
    }

    // Debounce search
    debounceTimer = setTimeout(async () => {
      setIsLoading(true);
      setError(null);

      try {
        const response = await searchUsersMock({
          query: searchQuery,
          limit: maxResults(),
          contactsOnly: props.contactsOnly ?? false,
          excludeBlocked: true,
        });

        setResults(response.results);
        setHasSearched(true);
      } catch (err) {
        // eslint-disable-next-line no-console
        console.error('[UserSearch] Search error:', err);
        setError('Failed to search users. Please try again.');
      } finally {
        setIsLoading(false);
      }
    }, debounceMs());
  });

  const handleSelect = (user: UserProfile) => {
    props.onSelect?.(user);
  };

  const handleMessage = (user: UserProfile) => {
    props.onMessage?.(user);
  };

  const handleAddToGroup = (user: UserProfile) => {
    props.onAddToGroup?.(user);
  };

  return (
    <div class={`flex flex-col ${props.class ?? ''}`}>
      {/* Search input */}
      <div class="relative">
        <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
          <Show
            when={!isLoading()}
            fallback={
              <svg
                class="w-5 h-5 text-gray-400 animate-spin"
                fill="none"
                viewBox="0 0 24 24"
              >
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
            }
          >
            <svg
              class="w-5 h-5 text-gray-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </Show>
        </div>
        <TextInput
          type="text"
          value={query()}
          onInput={(e) => setQuery(e.currentTarget.value)}
          placeholder={props.placeholder ?? 'Search users...'}
          class="pl-10 w-full"
          size="md"
        />
        <Show when={query()}>
          <button
            type="button"
            class="absolute inset-y-0 right-0 pr-3 flex items-center"
            onClick={() => setQuery('')}
          >
            <svg
              class="w-5 h-5 text-gray-400 hover:text-gray-600"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M6 18L18 6M6 6l12 12"
              />
            </svg>
          </button>
        </Show>
      </div>

      {/* Error message */}
      <Show when={error()}>
        <div class="mt-2 p-3 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-lg text-sm">
          {error()}
        </div>
      </Show>

      {/* Results list */}
      <div class="mt-3 space-y-2 max-h-80 overflow-y-auto">
        <Show
          when={results().length > 0}
          fallback={
            <Show when={hasSearched() && !isLoading()}>
              <div class="text-center py-8 text-gray-500 dark:text-gray-400">
                <svg
                  class="w-12 h-12 mx-auto mb-3 opacity-50"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="1.5"
                    d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                  />
                </svg>
                <p class="font-medium">No users found</p>
                <p class="text-sm mt-1">Try a different search term</p>
              </div>
            </Show>
          }
        >
          <For each={results()}>
            {(result) => (
              <UserCard
                user={result.user}
                highlight={result.matchHighlight}
                onClick={() => handleSelect(result.user)}
                onMessage={() => handleMessage(result.user)}
                onAddToGroup={() => handleAddToGroup(result.user)}
                showActions={props.showActions ?? true}
              />
            )}
          </For>
        </Show>
      </div>

      {/* Results count */}
      <Show when={results().length > 0}>
        <div class="mt-2 text-sm text-gray-500 dark:text-gray-400 text-center">
          Showing {results().length} result{results().length !== 1 ? 's' : ''}
        </div>
      </Show>
    </div>
  );
};

export default UserSearch;
