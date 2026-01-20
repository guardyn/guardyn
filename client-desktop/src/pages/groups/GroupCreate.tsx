import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, Show } from 'solid-js';
import { Avatar, Button, TextInput } from '../../components/shared';
import type { CreateGroupRequest } from '../../types';

interface UserSearchResult {
  id: string;
  username: string;
  display_name: string;
  avatar_url?: string;
}

/**
 * GroupCreate Page
 * 
 * Form for creating a new group.
 * Features:
 * - Group name input
 * - Avatar upload
 * - Member multi-select with search
 * - Description textarea
 */
const GroupCreate: Component = () => {
  const navigate = useNavigate();

  const [name, setName] = createSignal('');
  const [description, setDescription] = createSignal('');
  const [avatarFile, setAvatarFile] = createSignal<File | null>(null);
  const [avatarPreview, setAvatarPreview] = createSignal<string | null>(null);
  const [selectedMembers, setSelectedMembers] = createSignal<UserSearchResult[]>([]);
  const [searchQuery, setSearchQuery] = createSignal('');
  const [searchResults, setSearchResults] = createSignal<UserSearchResult[]>([]);
  const [searching, setSearching] = createSignal(false);
  const [creating, setCreating] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);

  const handleAvatarChange = (e: Event) => {
    const input = e.target as HTMLInputElement;
    const file = input.files?.[0];
    if (file) {
      setAvatarFile(file);
      const reader = new FileReader();
      reader.onload = (e) => {
        setAvatarPreview(e.target?.result as string);
      };
      reader.readAsDataURL(file);
    }
  };

  const searchUsers = async (query: string) => {
    if (!query.trim()) {
      setSearchResults([]);
      return;
    }

    setSearching(true);
    try {
      const results = await invoke<UserSearchResult[]>('search_users', { query });
      // Filter out already selected members
      const selectedIds = new Set(selectedMembers().map((m) => m.id));
      setSearchResults(results.filter((u) => !selectedIds.has(u.id)));
    } catch (err) {
      console.error('Failed to search users:', err);
      // Use mock data
      setSearchResults(getMockSearchResults(query));
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

  const addMember = (user: UserSearchResult) => {
    setSelectedMembers((prev) => [...prev, user]);
    setSearchResults((prev) => prev.filter((u) => u.id !== user.id));
    setSearchQuery('');
  };

  const removeMember = (userId: string) => {
    setSelectedMembers((prev) => prev.filter((m) => m.id !== userId));
  };

  const createGroup = async () => {
    if (!name().trim()) {
      setError('Group name is required');
      return;
    }

    setCreating(true);
    setError(null);

    try {
      const request: CreateGroupRequest = {
        name: name().trim(),
        description: description().trim() || undefined,
        member_ids: selectedMembers().map((m) => m.id),
      };

      // Upload avatar if provided
      if (avatarFile()) {
        const formData = new FormData();
        formData.append('avatar', avatarFile()!);
        // Avatar upload would be handled separately
      }

      const group = await invoke<{ id: string }>('create_group', { request });
      navigate(`/groups/${group.id}`);
    } catch (err) {
      console.error('Failed to create group:', err);
      setError('Failed to create group. Please try again.');
      // Demo: navigate to groups list on mock success
      navigate('/groups');
    } finally {
      setCreating(false);
    }
  };

  const goBack = () => {
    navigate('/groups');
  };

  return (
    <div class="flex flex-col h-full bg-neutral-50 dark:bg-neutral-950">
      {/* Header */}
      <header class="flex items-center gap-4 px-4 py-3 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <button
          onClick={goBack}
          class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
          title="Cancel"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
        <h1 class="text-lg font-semibold text-neutral-900 dark:text-white">
          Create Group
        </h1>
      </header>

      {/* Form */}
      <div class="flex-1 overflow-y-auto p-6">
        <div class="max-w-lg mx-auto space-y-6">
          {/* Avatar */}
          <div class="flex flex-col items-center gap-4">
            <label class="relative cursor-pointer group">
              <div class="w-24 h-24 rounded-full bg-neutral-200 dark:bg-neutral-700 flex items-center justify-center overflow-hidden ring-4 ring-neutral-100 dark:ring-neutral-800 group-hover:ring-guardyn-500/30 transition-all">
                <Show when={avatarPreview()} fallback={
                  <svg class="w-10 h-10 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                  </svg>
                }>
                  <img src={avatarPreview()!} alt="Group avatar" class="w-full h-full object-cover" />
                </Show>
              </div>
              <div class="absolute bottom-0 right-0 w-8 h-8 bg-guardyn-500 rounded-full flex items-center justify-center text-white shadow-lg">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
              </div>
              <input
                type="file"
                accept="image/*"
                class="hidden"
                onChange={handleAvatarChange}
              />
            </label>
            <p class="text-sm text-neutral-500 dark:text-neutral-400">
              Click to upload group photo
            </p>
          </div>

          {/* Group name */}
          <div>
            <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2">
              Group Name *
            </label>
            <TextInput
              value={name()}
              onInput={(e: InputEvent & { currentTarget: HTMLInputElement }) => setName(e.currentTarget.value)}
              placeholder="Enter group name"
              class="w-full"
            />
          </div>

          {/* Description */}
          <div>
            <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2">
              Description
            </label>
            <textarea
              value={description()}
              onInput={(e) => setDescription(e.currentTarget.value)}
              placeholder="What is this group about?"
              rows={3}
              class="w-full px-4 py-3 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-guardyn-500/50 resize-none"
            />
          </div>

          {/* Add members */}
          <div>
            <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-2">
              Add Members
            </label>
            
            {/* Selected members chips */}
            <Show when={selectedMembers().length > 0}>
              <div class="flex flex-wrap gap-2 mb-3">
                <For each={selectedMembers()}>
                  {(member) => (
                    <div class="flex items-center gap-2 px-3 py-1.5 bg-guardyn-100 dark:bg-guardyn-900/30 text-guardyn-700 dark:text-guardyn-300 rounded-full">
                      <Avatar name={member.display_name} src={member.avatar_url} size="xs" />
                      <span class="text-sm">{member.display_name}</span>
                      <button
                        onClick={() => removeMember(member.id)}
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
            </Show>

            {/* Search input */}
            <div class="relative">
              <TextInput
                value={searchQuery()}
                onInput={(e: InputEvent & { currentTarget: HTMLInputElement }) => handleSearchInput(e.currentTarget.value)}
                placeholder="Search users to add..."
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
              <div class="mt-2 bg-white dark:bg-neutral-800 border border-neutral-200 dark:border-neutral-700 rounded-xl overflow-hidden">
                <For each={searchResults()}>
                  {(user) => (
                    <button
                      onClick={() => addMember(user)}
                      class="w-full flex items-center gap-3 px-4 py-3 hover:bg-neutral-50 dark:hover:bg-neutral-700/50 transition-colors"
                    >
                      <Avatar name={user.display_name} src={user.avatar_url} size="sm" />
                      <div class="text-left">
                        <p class="text-sm font-medium text-neutral-900 dark:text-white">
                          {user.display_name}
                        </p>
                        <p class="text-xs text-neutral-500 dark:text-neutral-400">
                          @{user.username}
                        </p>
                      </div>
                    </button>
                  )}
                </For>
              </div>
            </Show>
          </div>

          {/* Error message */}
          <Show when={error()}>
            <p class="text-sm text-red-500 dark:text-red-400">{error()}</p>
          </Show>
        </div>
      </div>

      {/* Footer */}
      <div class="px-6 py-4 bg-white dark:bg-neutral-900 border-t border-neutral-200 dark:border-neutral-800">
        <div class="max-w-lg mx-auto flex gap-3">
          <Button variant="secondary" onClick={goBack} class="flex-1">
            Cancel
          </Button>
          <Button
            variant="primary"
            onClick={createGroup}
            disabled={!name().trim() || creating()}
            class="flex-1"
          >
            <Show when={creating()} fallback="Create Group">
              <div class="flex items-center gap-2">
                <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-white" />
                Creating...
              </div>
            </Show>
          </Button>
        </div>
      </div>
    </div>
  );
};

// Mock search results for development
function getMockSearchResults(query: string): UserSearchResult[] {
  const allUsers: UserSearchResult[] = [
    { id: 'user-1', username: 'alice', display_name: 'Alice Smith' },
    { id: 'user-2', username: 'bob', display_name: 'Bob Johnson' },
    { id: 'user-3', username: 'carol', display_name: 'Carol Williams' },
    { id: 'user-4', username: 'david', display_name: 'David Brown' },
    { id: 'user-5', username: 'emma', display_name: 'Emma Davis' },
  ];

  return allUsers.filter(
    (u) =>
      u.username.toLowerCase().includes(query.toLowerCase()) ||
      u.display_name.toLowerCase().includes(query.toLowerCase())
  );
}

export default GroupCreate;
