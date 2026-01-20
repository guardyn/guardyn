import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, onMount, Show } from 'solid-js';
import { Avatar, Badge, EmptyState } from '../../components/shared';
import type { Group } from '../../types';

/**
 * GroupList Page
 * 
 * Displays a list of all groups the user is a member of.
 * Features:
 * - Grid/list view toggle
 * - Group avatars with member count
 * - Unread message indicators
 * - Create group FAB
 * - Search/filter groups
 */
const GroupList: Component = () => {
  const navigate = useNavigate();
  const [groups, setGroups] = createSignal<Group[]>([]);
  const [loading, setLoading] = createSignal(true);
  const [error, setError] = createSignal<string | null>(null);
  const [searchQuery, setSearchQuery] = createSignal('');
  const [viewMode, setViewMode] = createSignal<'grid' | 'list'>('list');

  // Filtered groups based on search query
  const filteredGroups = () => {
    const query = searchQuery().toLowerCase();
    if (!query) return groups();
    return groups().filter(
      (g) =>
        g.name.toLowerCase().includes(query) ||
        g.description?.toLowerCase().includes(query)
    );
  };

  onMount(async () => {
    await loadGroups();
  });

  const loadGroups = async () => {
    setLoading(true);
    setError(null);
    try {
      const result = await invoke<Group[]>('get_groups');
      setGroups(result);
    } catch (err) {
      console.error('Failed to load groups:', err);
      setError('Failed to load groups. Please try again.');
      // Use mock data in development
      setGroups(getMockGroups());
    } finally {
      setLoading(false);
    }
  };

  const openGroup = (groupId: string) => {
    navigate(`/groups/${groupId}`);
  };

  const createNewGroup = () => {
    navigate('/groups/create');
  };

  const formatTimestamp = (timestamp: number): string => {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));

    if (days === 0) {
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    } else if (days === 1) {
      return 'Yesterday';
    } else if (days < 7) {
      return date.toLocaleDateString([], { weekday: 'short' });
    } else {
      return date.toLocaleDateString([], { month: 'short', day: 'numeric' });
    }
  };

  return (
    <div class="flex flex-col h-full bg-neutral-50 dark:bg-neutral-900">
      {/* Header */}
      <header class="flex items-center justify-between px-6 py-4 border-b border-neutral-200 dark:border-neutral-800">
        <h1 class="text-2xl font-semibold text-neutral-900 dark:text-white">Groups</h1>
        <div class="flex items-center gap-3">
          {/* View Mode Toggle */}
          <div class="flex items-center bg-neutral-200 dark:bg-neutral-800 rounded-lg p-1">
            <button
              onClick={() => setViewMode('list')}
              class={`p-1.5 rounded-md transition-colors ${
                viewMode() === 'list'
                  ? 'bg-white dark:bg-neutral-700 shadow-sm'
                  : 'hover:bg-neutral-300 dark:hover:bg-neutral-600'
              }`}
              title="List view"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" />
              </svg>
            </button>
            <button
              onClick={() => setViewMode('grid')}
              class={`p-1.5 rounded-md transition-colors ${
                viewMode() === 'grid'
                  ? 'bg-white dark:bg-neutral-700 shadow-sm'
                  : 'hover:bg-neutral-300 dark:hover:bg-neutral-600'
              }`}
              title="Grid view"
            >
              <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                <path d="M5 3a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2V5a2 2 0 00-2-2H5zM5 11a2 2 0 00-2 2v2a2 2 0 002 2h2a2 2 0 002-2v-2a2 2 0 00-2-2H5zM11 5a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V5zM11 13a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
              </svg>
            </button>
          </div>
        </div>
      </header>

      {/* Search Bar */}
      <div class="px-6 py-3">
        <div class="relative">
          <svg
            class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-neutral-400"
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
          <input
            type="text"
            placeholder="Search groups..."
            value={searchQuery()}
            onInput={(e) => setSearchQuery(e.currentTarget.value)}
            class="w-full pl-10 pr-4 py-2.5 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl text-neutral-900 dark:text-white placeholder-neutral-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition-all"
          />
        </div>
      </div>

      {/* Content */}
      <div class="flex-1 overflow-y-auto px-6 pb-20">
        <Show when={loading()}>
          <div class="flex items-center justify-center h-64">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-guardyn-500" />
          </div>
        </Show>

        <Show when={!loading() && error()}>
          <div class="p-4 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-lg">
            {error()}
          </div>
        </Show>

        <Show when={!loading() && !error() && filteredGroups().length === 0}>
          <EmptyState
            icon={
              <svg class="w-16 h-16" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="1.5"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
            }
            title={searchQuery() ? 'No groups found' : 'No groups yet'}
            description={
              searchQuery()
                ? 'Try a different search term'
                : 'Create a new group to start chatting with multiple people'
            }
            actionLabel={!searchQuery() ? 'Create Group' : undefined}
            onAction={!searchQuery() ? createNewGroup : undefined}
          />
        </Show>

        <Show when={!loading() && filteredGroups().length > 0}>
          {/* List View */}
          <Show when={viewMode() === 'list'}>
            <div class="space-y-2">
              <For each={filteredGroups()}>
                {(group) => (
                  <button
                    onClick={() => openGroup(group.id)}
                    class="w-full flex items-center gap-4 p-4 bg-white dark:bg-neutral-800 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-750 transition-all group glass-card"
                  >
                    <Avatar
                      name={group.name}
                      src={group.avatar_url}
                      size="lg"
                      showPresence={false}
                    />
                    <div class="flex-1 min-w-0 text-left">
                      <div class="flex items-center justify-between">
                        <h3 class="font-semibold text-neutral-900 dark:text-white truncate">
                          {group.name}
                        </h3>
                        <Show when={group.last_message}>
                          <span class="text-xs text-neutral-400 flex-shrink-0">
                            {formatTimestamp(group.last_message!.timestamp)}
                          </span>
                        </Show>
                      </div>
                      <div class="flex items-center justify-between mt-1">
                        <p class="text-sm text-neutral-500 dark:text-neutral-400 truncate">
                          <Show when={group.last_message} fallback={`${group.member_count} members`}>
                            <span class="text-neutral-600 dark:text-neutral-300">
                              {group.last_message!.sender_name}:
                            </span>{' '}
                            {group.last_message!.content}
                          </Show>
                        </p>
                        <Show when={group.unread_count > 0}>
                          <Badge count={group.unread_count} />
                        </Show>
                      </div>
                    </div>
                  </button>
                )}
              </For>
            </div>
          </Show>

          {/* Grid View */}
          <Show when={viewMode() === 'grid'}>
            <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              <For each={filteredGroups()}>
                {(group) => (
                  <button
                    onClick={() => openGroup(group.id)}
                    class="flex flex-col items-center p-6 bg-white dark:bg-neutral-800 rounded-xl hover:bg-neutral-50 dark:hover:bg-neutral-750 transition-all glass-card"
                  >
                    <div class="relative">
                      <Avatar
                        name={group.name}
                        src={group.avatar_url}
                        size="xl"
                        showPresence={false}
                      />
                      <Show when={group.unread_count > 0}>
                        <div class="absolute -top-1 -right-1">
                          <Badge count={group.unread_count} />
                        </div>
                      </Show>
                    </div>
                    <h3 class="mt-3 font-semibold text-neutral-900 dark:text-white text-center truncate max-w-full">
                      {group.name}
                    </h3>
                    <p class="mt-1 text-sm text-neutral-500 dark:text-neutral-400">
                      {group.member_count} members
                    </p>
                  </button>
                )}
              </For>
            </div>
          </Show>
        </Show>
      </div>

      {/* Floating Action Button */}
      <button
        onClick={createNewGroup}
        class="fixed bottom-6 right-6 w-14 h-14 bg-guardyn-500 hover:bg-guardyn-600 text-white rounded-full shadow-lg hover:shadow-xl transition-all flex items-center justify-center neumorphic-btn"
        title="Create new group"
      >
        <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
        </svg>
      </button>
    </div>
  );
};

// Mock data for development
function getMockGroups(): Group[] {
  return [
    {
      id: 'group-1',
      name: 'Development Team',
      description: 'Team discussions and updates',
      member_count: 8,
      created_at: Date.now() - 86400000 * 30,
      updated_at: Date.now() - 3600000,
      created_by: 'user-1',
      is_muted: false,
      unread_count: 3,
      last_message: {
        id: 'msg-1',
        sender_id: 'user-2',
        sender_name: 'Alice',
        content: 'The new feature is ready for review',
        timestamp: Date.now() - 3600000,
      },
    },
    {
      id: 'group-2',
      name: 'Design Review',
      description: 'UI/UX discussions',
      member_count: 5,
      created_at: Date.now() - 86400000 * 15,
      updated_at: Date.now() - 7200000,
      created_by: 'user-3',
      is_muted: false,
      unread_count: 0,
      last_message: {
        id: 'msg-2',
        sender_id: 'user-4',
        sender_name: 'Bob',
        content: 'Updated the mockups',
        timestamp: Date.now() - 7200000,
      },
    },
    {
      id: 'group-3',
      name: 'Coffee Break ☕',
      description: 'Casual chat',
      member_count: 12,
      created_at: Date.now() - 86400000 * 60,
      updated_at: Date.now() - 86400000,
      created_by: 'user-1',
      is_muted: true,
      unread_count: 15,
      last_message: {
        id: 'msg-3',
        sender_id: 'user-5',
        sender_name: 'Carol',
        content: 'Anyone want to grab coffee?',
        timestamp: Date.now() - 86400000,
      },
    },
  ];
}

export default GroupList;
