/**
 * New Conversation Modal
 * 
 * Modal for starting a new conversation with user search.
 * Handles user search, selection, and initiating E2EE session.
 * 
 * @module components/chat/NewConversationModal
 */

import { Component, createSignal, For, Show, onMount, onCleanup } from 'solid-js';
import { encryptionManager } from '../../services/encryption';

// =============================================================================
// TYPES
// =============================================================================

export interface UserSearchResult {
  id: string;
  displayName: string;
  username: string;
  avatarUrl?: string;
  isOnline?: boolean;
}

export interface NewConversationModalProps {
  isOpen: boolean;
  onClose: () => void;
  onStartConversation: (userId: string, userName: string) => void;
}

// =============================================================================
// COMPONENT
// =============================================================================

export const NewConversationModal: Component<NewConversationModalProps> = (props) => {
  const [searchQuery, setSearchQuery] = createSignal('');
  const [searchResults, setSearchResults] = createSignal<UserSearchResult[]>([]);
  const [isSearching, setIsSearching] = createSignal(false);
  const [selectedUser, setSelectedUser] = createSignal<UserSearchResult | null>(null);
  const [isInitiating, setIsInitiating] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);

  // Close on escape key
  onMount(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        props.onClose();
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    onCleanup(() => document.removeEventListener('keydown', handleKeyDown));
  });

  // Mock search - replace with actual API call
  const handleSearch = async () => {
    const query = searchQuery().trim();
    if (!query) {
      setSearchResults([]);
      return;
    }

    setIsSearching(true);
    setError(null);

    try {
      // TODO: Replace with actual user search API
      // Simulated search results for development
      await new Promise(resolve => setTimeout(resolve, 300));
      
      const mockResults: UserSearchResult[] = [
        { id: 'user_1', displayName: 'Alice Smith', username: 'alice', isOnline: true },
        { id: 'user_2', displayName: 'Bob Johnson', username: 'bob', isOnline: false },
        { id: 'user_3', displayName: 'Charlie Brown', username: 'charlie', isOnline: true },
      ].filter(u => 
        u.displayName.toLowerCase().includes(query.toLowerCase()) ||
        u.username.toLowerCase().includes(query.toLowerCase())
      );

      setSearchResults(mockResults);
    } catch (err) {
      setError('Failed to search users');
    } finally {
      setIsSearching(false);
    }
  };

  const handleSelectUser = (user: UserSearchResult) => {
    setSelectedUser(user);
  };

  const handleStartConversation = async () => {
    const user = selectedUser();
    if (!user) return;

    setIsInitiating(true);
    setError(null);

    try {
      // Initialize encryption if needed
      if (!encryptionManager.isInitialized()) {
        await encryptionManager.initialize();
      }

      // TODO: Fetch recipient's key bundle from server
      // For now, pass to parent to handle
      props.onStartConversation(user.id, user.displayName);
      
      // Reset state and close
      setSearchQuery('');
      setSearchResults([]);
      setSelectedUser(null);
      props.onClose();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to start conversation');
    } finally {
      setIsInitiating(false);
    }
  };

  const handleBackdropClick = (e: MouseEvent) => {
    if (e.target === e.currentTarget) {
      props.onClose();
    }
  };

  return (
    <Show when={props.isOpen}>
      <div
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm"
        onClick={handleBackdropClick}
      >
        <div
          class="w-full max-w-md rounded-xl bg-white dark:bg-gray-800 shadow-2xl"
          style={{ 'animation': 'scaleIn 0.2s ease-out' }}
        >
          {/* Header */}
          <div class="flex items-center justify-between p-4 border-b border-gray-200 dark:border-gray-700">
            <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
              New Conversation
            </h2>
            <button
              onClick={() => props.onClose()}
              class="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              aria-label="Close"
            >
              <svg class="w-5 h-5 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Search Input */}
          <div class="p-4">
            <div class="relative">
              <input
                type="text"
                placeholder="Search by name or username..."
                value={searchQuery()}
                onInput={(e) => {
                  setSearchQuery(e.currentTarget.value);
                  handleSearch();
                }}
                class="w-full px-4 py-3 pl-10 rounded-lg bg-gray-100 dark:bg-gray-700 
                       text-gray-900 dark:text-white placeholder-gray-500
                       focus:outline-none focus:ring-2 focus:ring-green-500"
              />
              <svg 
                class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400"
                fill="none" viewBox="0 0 24 24" stroke="currentColor"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </div>
          </div>

          {/* Search Results */}
          <div class="max-h-64 overflow-y-auto px-4">
            <Show when={isSearching()}>
              <div class="flex items-center justify-center py-8">
                <div class="w-6 h-6 border-2 border-green-500 border-t-transparent rounded-full animate-spin" />
              </div>
            </Show>

            <Show when={!isSearching() && searchResults().length === 0 && searchQuery()}>
              <div class="text-center py-8 text-gray-500">
                No users found
              </div>
            </Show>

            <Show when={!isSearching() && searchResults().length > 0}>
              <For each={searchResults()}>
                {(user) => (
                  <button
                    onClick={() => handleSelectUser(user)}
                    class={`w-full flex items-center gap-3 p-3 rounded-lg transition-colors
                            ${selectedUser()?.id === user.id 
                              ? 'bg-green-100 dark:bg-green-900/30 border-2 border-green-500' 
                              : 'hover:bg-gray-100 dark:hover:bg-gray-700'}`}
                  >
                    {/* Avatar */}
                    <div class="relative">
                      <div class="w-10 h-10 rounded-full bg-gradient-to-br from-green-400 to-green-600 
                                  flex items-center justify-center text-white font-semibold">
                        {user.displayName.charAt(0).toUpperCase()}
                      </div>
                      <Show when={user.isOnline}>
                        <div class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 
                                    rounded-full border-2 border-white dark:border-gray-800" />
                      </Show>
                    </div>

                    {/* User Info */}
                    <div class="flex-1 text-left">
                      <div class="font-medium text-gray-900 dark:text-white">
                        {user.displayName}
                      </div>
                      <div class="text-sm text-gray-500">
                        @{user.username}
                      </div>
                    </div>

                    {/* Selected Indicator */}
                    <Show when={selectedUser()?.id === user.id}>
                      <svg class="w-5 h-5 text-green-500" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd" />
                      </svg>
                    </Show>
                  </button>
                )}
              </For>
            </Show>
          </div>

          {/* Error Message */}
          <Show when={error()}>
            <div class="px-4 py-2">
              <div class="text-sm text-red-500 bg-red-50 dark:bg-red-900/20 rounded-lg p-3">
                {error()}
              </div>
            </div>
          </Show>

          {/* Footer */}
          <div class="flex items-center justify-end gap-3 p-4 border-t border-gray-200 dark:border-gray-700">
            <button
              onClick={() => props.onClose()}
              class="px-4 py-2 rounded-lg text-gray-700 dark:text-gray-300 
                     hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleStartConversation}
              disabled={!selectedUser() || isInitiating()}
              class="px-4 py-2 rounded-lg bg-green-500 text-white font-medium
                     hover:bg-green-600 disabled:opacity-50 disabled:cursor-not-allowed
                     transition-colors flex items-center gap-2"
            >
              <Show when={isInitiating()}>
                <div class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin" />
              </Show>
              Start Chat
            </button>
          </div>
        </div>
      </div>
    </Show>
  );
};

export default NewConversationModal;
