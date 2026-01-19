import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, Show } from 'solid-js';
import { Avatar, Button, TextInput } from '../../components/shared';

interface UserSearchResult {
  id: string;
  username: string;
  display_name: string;
  avatar_url?: string;
}

export interface AddMemberDialogProps {
  /** Group ID to add members to */
  groupId: string;
  /** List of current member IDs to exclude from search */
  existingMemberIds: string[];
  /** Whether dialog is visible */
  isOpen: boolean;
  /** Callback when dialog is closed */
  onClose: () => void;
  /** Callback when members are added */
  onMembersAdded: (members: UserSearchResult[]) => void;
}

/**
 * AddMemberDialog Component
 * 
 * Modal dialog for searching and adding new members to a group.
 * Features:
 * - User search with debounce
 * - Selected members chips
 * - Bulk add functionality
 */
const AddMemberDialog: Component<AddMemberDialogProps> = (props) => {
  const [searchQuery, setSearchQuery] = createSignal('');
  const [searchResults, setSearchResults] = createSignal<UserSearchResult[]>([]);
  const [selectedMembers, setSelectedMembers] = createSignal<UserSearchResult[]>([]);
  const [searching, setSearching] = createSignal(false);
  const [adding, setAdding] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);

  const searchUsers = async (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }

    setSearching(true);
    try {
      const results = await invoke<UserSearchResult[]>('search_users', { query });
      // Filter out existing members and already selected
      const existingIds = new Set([
        ...props.existingMemberIds,
        ...selectedMembers().map((m) => m.id),
      ]);
      setSearchResults(results.filter((u) => !existingIds.has(u.id)));
    } catch (err) {
      console.error('Failed to search users:', err);
      // Use mock data
      setSearchResults(getMockSearchResults(query, props.existingMemberIds, selectedMembers()));
    } finally {
      setSearching(false);
    }
  };

  const handleSearchInput = (value: string) => {
    setSearchQuery(value);
    // Debounced search
    setTimeout(() => {
      if (searchQuery() === value) {
        searchUsers(value);
      }
    }, 300);
  };

  const selectMember = (user: UserSearchResult) => {
    setSelectedMembers((prev) => [...prev, user]);
    setSearchResults((prev) => prev.filter((u) => u.id !== user.id));
  };

  const deselectMember = (userId: string) => {
    setSelectedMembers((prev) => prev.filter((m) => m.id !== userId));
  };

  const addMembers = async () => {
    if (selectedMembers().length === 0) return;

    setAdding(true);
    setError(null);

    try {
      await invoke('add_group_members', {
        groupId: props.groupId,
        memberIds: selectedMembers().map((m) => m.id),
      });
      props.onMembersAdded(selectedMembers());
      resetAndClose();
    } catch (err) {
      console.error('Failed to add members:', err);
      setError('Failed to add members. Please try again.');
    } finally {
      setAdding(false);
    }
  };

  const resetAndClose = () => {
    setSearchQuery('');
    setSearchResults([]);
    setSelectedMembers([]);
    setError(null);
    props.onClose();
  };

  return (
    <Show when={props.isOpen}>
      <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
      <div class="bg-white dark:bg-neutral-900 rounded-2xl shadow-xl w-full max-w-md mx-4 max-h-[80vh] flex flex-col">
        {/* Header */}
        <div class="flex items-center justify-between px-6 py-4 border-b border-neutral-200 dark:border-neutral-800">
          <h2 class="text-lg font-semibold text-neutral-900 dark:text-white">
            Add Members
          </h2>
          <button
            onClick={resetAndClose}
            class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        {/* Content */}
        <div class="flex-1 overflow-y-auto p-6">
          {/* Selected members chips */}
          <Show when={selectedMembers().length > 0}>
            <div class="mb-4">
              <p class="text-sm text-neutral-500 dark:text-neutral-400 mb-2">
                Selected ({selectedMembers().length})
              </p>
              <div class="flex flex-wrap gap-2">
                <For each={selectedMembers()}>
                  {(member) => (
                    <div class="flex items-center gap-2 px-3 py-1.5 bg-guardyn-100 dark:bg-guardyn-900/30 text-guardyn-700 dark:text-guardyn-300 rounded-full">
                      <Avatar name={member.display_name} src={member.avatar_url} size="xs" />
                      <span class="text-sm">{member.display_name}</span>
                      <button
                        onClick={() => deselectMember(member.id)}
                        class="p-0.5 hover:bg-guardyn-200 dark:hover:bg-guardyn-800 rounded-full"
                      >
                        <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                      </button>
                    </div>
                  )}
                </For>
              </div>
            </div>
          </Show>

          {/* Search input */}
          <div class="relative">
            <TextInput
              value={searchQuery()}
              onInput={(e: InputEvent & { currentTarget: HTMLInputElement }) => handleSearchInput(e.currentTarget.value)}
              placeholder="Search users by name or username..."
              class="w-full"
            />
            <Show when={searching()}>
              <div class="absolute right-3 top-1/2 -translate-y-1/2">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-guardyn-500" />
              </div>
            </Show>
          </div>

          {/* Search results */}
          <Show when={searchResults().length > 0}>
            <div class="mt-4 divide-y divide-neutral-100 dark:divide-neutral-800">
              <For each={searchResults()}>
                {(user) => (
                  <button
                    onClick={() => selectMember(user)}
                    class="w-full flex items-center gap-3 px-2 py-3 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 rounded-lg transition-colors"
                  >
                    <Avatar name={user.display_name} src={user.avatar_url} size="md" />
                    <div class="text-left flex-1">
                      <p class="font-medium text-neutral-900 dark:text-white">
                        {user.display_name}
                      </p>
                      <p class="text-sm text-neutral-500 dark:text-neutral-400">
                        @{user.username}
                      </p>
                    </div>
                    <svg class="w-5 h-5 text-guardyn-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                    </svg>
                  </button>
                )}
              </For>
            </div>
          </Show>

          {/* Empty state */}
          <Show when={searchQuery() && !searching() && searchResults().length === 0}>
            <div class="mt-8 text-center">
              <svg class="w-12 h-12 mx-auto text-neutral-300 dark:text-neutral-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <p class="mt-3 text-neutral-500 dark:text-neutral-400">
                No users found matching "{searchQuery()}"
              </p>
            </div>
          </Show>

          {/* Error message */}
          <Show when={error()}>
            <p class="mt-4 text-sm text-red-500 dark:text-red-400">{error()}</p>
          </Show>
        </div>

        {/* Footer */}
        <div class="flex gap-3 px-6 py-4 border-t border-neutral-200 dark:border-neutral-800">
          <Button variant="secondary" onClick={resetAndClose} class="flex-1">
            Cancel
          </Button>
          <Button
            variant="primary"
            onClick={addMembers}
            disabled={selectedMembers().length === 0 || adding()}
            class="flex-1"
          >
            <Show when={adding()} fallback={`Add ${selectedMembers().length || ''} Member${selectedMembers().length !== 1 ? 's' : ''}`}>
              <div class="flex items-center gap-2">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white" />
                Adding...
              </div>
            </Show>
          </Button>
        </div>
      </div>
    </div>
    </Show>
  );
};

// Mock search results for development
function getMockSearchResults(
  query: string,
  existingIds: string[],
  selected: UserSearchResult[]
): UserSearchResult[] {
  const allUsers: UserSearchResult[] = [
    { id: 'user-10', username: 'frank', display_name: 'Frank Miller' },
    { id: 'user-11', username: 'grace', display_name: 'Grace Lee' },
    { id: 'user-12', username: 'henry', display_name: 'Henry Wilson' },
    { id: 'user-13', username: 'ivy', display_name: 'Ivy Chen' },
    { id: 'user-14', username: 'jack', display_name: 'Jack Taylor' },
    { id: 'user-15', username: 'kate', display_name: 'Kate Martinez' },
  ];

  const excludeIds = new Set([...existingIds, ...selected.map((m) => m.id)]);

  return allUsers.filter(
    (u) =>
      !excludeIds.has(u.id) &&
      (u.username.toLowerCase().includes(query.toLowerCase()) ||
        u.display_name.toLowerCase().includes(query.toLowerCase()))
  );
}

export default AddMemberDialog;
