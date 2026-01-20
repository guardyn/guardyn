import { useNavigate, useParams } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, onMount, Show } from 'solid-js';
import { Avatar, Button } from '../../components/shared';
import type { Group, GroupMember, GroupRole } from '../../types';

/**
 * GroupInfo Page
 * 
 * Displays detailed information about a group.
 * Features:
 * - Group details (name, description, avatar)
 * - Member list with roles
 * - Add/remove members (for admins)
 * - Leave group option
 * - Edit group settings (for owner/admin)
 */
const GroupInfo: Component = () => {
  const params = useParams<{ id: string }>();
  const navigate = useNavigate();

  const [group, setGroup] = createSignal<Group | null>(null);
  const [members, setMembers] = createSignal<GroupMember[]>([]);
  const [loading, setLoading] = createSignal(true);
  const [currentUserRole, setCurrentUserRole] = createSignal<GroupRole>('member');
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const [_showAddMember, setShowAddMember] = createSignal(false);
  const [showLeaveConfirm, setShowLeaveConfirm] = createSignal(false);

  onMount(async () => {
    await loadGroupInfo();
  });

  const loadGroupInfo = async () => {
    setLoading(true);
    try {
      const groupData = await invoke<Group>('get_group', { groupId: params.id });
      setGroup(groupData);

      const membersData = await invoke<GroupMember[]>('get_group_members', {
        groupId: params.id,
      });
      setMembers(membersData);

      // Find current user's role
      const currentMember = membersData.find((m) => m.user_id === 'current-user');
      if (currentMember) {
        setCurrentUserRole(currentMember.role);
      }
    } catch (err) {
      console.error('Failed to load group info:', err);
      // Use mock data
      setGroup(getMockGroup());
      setMembers(getMockMembers());
      setCurrentUserRole('admin');
    } finally {
      setLoading(false);
    }
  };

  const canManageMembers = () => {
    return currentUserRole() === 'owner' || currentUserRole() === 'admin';
  };

  const removeMember = async (userId: string) => {
    if (!canManageMembers()) return;

    try {
      await invoke('remove_group_member', { groupId: params.id, userId });
      setMembers((prev) => prev.filter((m) => m.user_id !== userId));
    } catch (err) {
      console.error('Failed to remove member:', err);
    }
  };

  const promoteToAdmin = async (userId: string) => {
    if (currentUserRole() !== 'owner') return;

    try {
      await invoke('update_member_role', { groupId: params.id, userId, role: 'admin' });
      setMembers((prev) =>
        prev.map((m) => (m.user_id === userId ? { ...m, role: 'admin' as GroupRole } : m))
      );
    } catch (err) {
      console.error('Failed to promote member:', err);
    }
  };

  const demoteToMember = async (userId: string) => {
    if (currentUserRole() !== 'owner') return;

    try {
      await invoke('update_member_role', { groupId: params.id, userId, role: 'member' });
      setMembers((prev) =>
        prev.map((m) => (m.user_id === userId ? { ...m, role: 'member' as GroupRole } : m))
      );
    } catch (err) {
      console.error('Failed to demote member:', err);
    }
  };

  const leaveGroup = async () => {
    try {
      await invoke('leave_group', { groupId: params.id });
      navigate('/groups');
    } catch (err) {
      console.error('Failed to leave group:', err);
      navigate('/groups');
    }
  };

  const openEditGroup = () => {
    navigate(`/groups/${params.id}/edit`);
  };

  const goBack = () => {
    navigate(`/groups/${params.id}`);
  };

  const getRoleBadge = (role: GroupRole) => {
    switch (role) {
      case 'owner':
        return (
          <span class="px-2 py-0.5 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-400 text-xs rounded-full">
            Owner
          </span>
        );
      case 'admin':
        return (
          <span class="px-2 py-0.5 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-400 text-xs rounded-full">
            Admin
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div class="flex flex-col h-full bg-neutral-50 dark:bg-neutral-950">
      {/* Header */}
      <header class="flex items-center gap-4 px-4 py-3 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <button
          onClick={goBack}
          class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>
        <h1 class="text-lg font-semibold text-neutral-900 dark:text-white flex-1">
          Group Info
        </h1>
        <Show when={canManageMembers()}>
          <button
            onClick={openEditGroup}
            class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
            title="Edit group"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
            </svg>
          </button>
        </Show>
      </header>

      <Show when={loading()}>
        <div class="flex items-center justify-center h-64">
          <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-guardyn-500" />
        </div>
      </Show>

      <Show when={!loading() && group()}>
        <div class="flex-1 overflow-y-auto">
          {/* Group header */}
          <div class="bg-white dark:bg-neutral-900 px-6 py-8 border-b border-neutral-200 dark:border-neutral-800">
            <div class="flex flex-col items-center gap-4">
              <Avatar
                name={group()!.name}
                src={group()!.avatar_url}
                size="xl"
              />
              <div class="text-center">
                <h2 class="text-2xl font-bold text-neutral-900 dark:text-white">
                  {group()!.name}
                </h2>
                <p class="text-sm text-neutral-500 dark:text-neutral-400 mt-1">
                  {group()!.member_count} members
                </p>
              </div>
              <Show when={group()!.description}>
                <p class="text-neutral-600 dark:text-neutral-300 text-center max-w-md">
                  {group()!.description}
                </p>
              </Show>
            </div>
          </div>

          {/* Quick actions */}
          <div class="grid grid-cols-4 gap-4 p-4 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
            <button class="flex flex-col items-center gap-2 p-3 hover:bg-neutral-50 dark:hover:bg-neutral-800 rounded-xl transition-colors">
              <div class="w-10 h-10 bg-guardyn-100 dark:bg-guardyn-900/30 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-guardyn-600 dark:text-guardyn-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
                </svg>
              </div>
              <span class="text-xs text-neutral-600 dark:text-neutral-400">Voice</span>
            </button>
            <button class="flex flex-col items-center gap-2 p-3 hover:bg-neutral-50 dark:hover:bg-neutral-800 rounded-xl transition-colors">
              <div class="w-10 h-10 bg-blue-100 dark:bg-blue-900/30 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-blue-600 dark:text-blue-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
              </div>
              <span class="text-xs text-neutral-600 dark:text-neutral-400">Video</span>
            </button>
            <button class="flex flex-col items-center gap-2 p-3 hover:bg-neutral-50 dark:hover:bg-neutral-800 rounded-xl transition-colors">
              <div class="w-10 h-10 bg-purple-100 dark:bg-purple-900/30 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-purple-600 dark:text-purple-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
              </div>
              <span class="text-xs text-neutral-600 dark:text-neutral-400">Search</span>
            </button>
            <button class="flex flex-col items-center gap-2 p-3 hover:bg-neutral-50 dark:hover:bg-neutral-800 rounded-xl transition-colors">
              <div class="w-10 h-10 bg-orange-100 dark:bg-orange-900/30 rounded-full flex items-center justify-center">
                <svg class="w-5 h-5 text-orange-600 dark:text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.172 7l-6.586 6.586a2 2 0 102.828 2.828l6.414-6.586a4 4 0 00-5.656-5.656l-6.415 6.585a6 6 0 108.486 8.486L20.5 13" />
                </svg>
              </div>
              <span class="text-xs text-neutral-600 dark:text-neutral-400">Media</span>
            </button>
          </div>

          {/* Members section */}
          <div class="bg-white dark:bg-neutral-900 mt-4">
            <div class="flex items-center justify-between px-4 py-3 border-b border-neutral-200 dark:border-neutral-800">
              <h3 class="font-semibold text-neutral-900 dark:text-white">
                Members ({members().length})
              </h3>
              <Show when={canManageMembers()}>
                <button
                  onClick={() => setShowAddMember(true)}
                  class="text-sm text-guardyn-600 dark:text-guardyn-400 hover:underline"
                >
                  Add member
                </button>
              </Show>
            </div>

            <div class="divide-y divide-neutral-100 dark:divide-neutral-800">
              <For each={members()}>
                {(member) => (
                  <div class="flex items-center gap-3 px-4 py-3">
                    <Avatar
                      name={member.display_name || member.username}
                      src={member.avatar_url}
                      size="md"
                      showPresence
                      presence={member.is_online ? 'online' : 'offline'}
                    />
                    <div class="flex-1">
                      <div class="flex items-center gap-2">
                        <span class="font-medium text-neutral-900 dark:text-white">
                          {member.display_name || member.username}
                        </span>
                        {getRoleBadge(member.role)}
                      </div>
                      <p class="text-sm text-neutral-500 dark:text-neutral-400">
                        @{member.username}
                      </p>
                    </div>

                    {/* Member actions */}
                    <Show when={canManageMembers() && member.user_id !== 'current-user' && member.role !== 'owner'}>
                      <div class="relative group">
                        <button class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg">
                          <svg class="w-5 h-5 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z" />
                          </svg>
                        </button>
                        {/* Dropdown menu */}
                        <div class="absolute right-0 top-full mt-1 w-40 bg-white dark:bg-neutral-800 rounded-lg shadow-lg border border-neutral-200 dark:border-neutral-700 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all z-10">
                          <Show when={currentUserRole() === 'owner'}>
                            <Show when={member.role !== 'admin'}>
                              <button
                                onClick={() => promoteToAdmin(member.user_id)}
                                class="w-full text-left px-4 py-2 text-sm hover:bg-neutral-50 dark:hover:bg-neutral-700"
                              >
                                Make admin
                              </button>
                            </Show>
                            <Show when={member.role === 'admin'}>
                              <button
                                onClick={() => demoteToMember(member.user_id)}
                                class="w-full text-left px-4 py-2 text-sm hover:bg-neutral-50 dark:hover:bg-neutral-700"
                              >
                                Remove admin
                              </button>
                            </Show>
                          </Show>
                          <button
                            onClick={() => removeMember(member.user_id)}
                            class="w-full text-left px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-neutral-50 dark:hover:bg-neutral-700"
                          >
                            Remove from group
                          </button>
                        </div>
                      </div>
                    </Show>
                  </div>
                )}
              </For>
            </div>
          </div>

          {/* Danger zone */}
          <div class="bg-white dark:bg-neutral-900 mt-4 mb-8">
            <div class="px-4 py-3 border-b border-neutral-200 dark:border-neutral-800">
              <h3 class="font-semibold text-red-600 dark:text-red-400">
                Danger Zone
              </h3>
            </div>
            <div class="p-4">
              <Show when={currentUserRole() !== 'owner'}>
                <button
                  onClick={() => setShowLeaveConfirm(true)}
                  class="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 rounded-xl hover:bg-red-100 dark:hover:bg-red-900/30 transition-colors"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                  </svg>
                  Leave Group
                </button>
              </Show>
              <Show when={currentUserRole() === 'owner'}>
                <p class="text-sm text-neutral-500 dark:text-neutral-400 text-center">
                  As the owner, you must transfer ownership before leaving the group.
                </p>
              </Show>
            </div>
          </div>
        </div>
      </Show>

      {/* Leave confirmation modal */}
      <Show when={showLeaveConfirm()}>
        <div class="fixed inset-0 bg-black/50 flex items-center justify-center z-50">
          <div class="bg-white dark:bg-neutral-900 rounded-2xl p-6 max-w-sm mx-4 shadow-xl">
            <h3 class="text-lg font-semibold text-neutral-900 dark:text-white mb-2">
              Leave Group?
            </h3>
            <p class="text-neutral-600 dark:text-neutral-400 mb-6">
              Are you sure you want to leave "{group()?.name}"? You will need an invite to rejoin.
            </p>
            <div class="flex gap-3">
              <Button variant="secondary" onClick={() => setShowLeaveConfirm(false)} class="flex-1">
                Cancel
              </Button>
              <Button variant="danger" onClick={leaveGroup} class="flex-1">
                Leave
              </Button>
            </div>
          </div>
        </div>
      </Show>
    </div>
  );
};

// Mock data for development
function getMockGroup(): Group {
  return {
    id: 'group-1',
    name: 'Development Team',
    description: 'Team discussions about development, code reviews, and project updates.',
    member_count: 8,
    created_at: Date.now() - 86400000 * 30,
    updated_at: Date.now(),
    created_by: 'user-1',
    is_muted: false,
    unread_count: 0,
  };
}

function getMockMembers(): GroupMember[] {
  return [
    {
      user_id: 'user-1',
      username: 'alice',
      display_name: 'Alice Smith',
      role: 'owner',
      joined_at: Date.now() - 86400000 * 30,
      is_online: true,
    },
    {
      user_id: 'current-user',
      username: 'you',
      display_name: 'You',
      role: 'admin',
      joined_at: Date.now() - 86400000 * 25,
      is_online: true,
    },
    {
      user_id: 'user-2',
      username: 'bob',
      display_name: 'Bob Johnson',
      role: 'admin',
      joined_at: Date.now() - 86400000 * 25,
      is_online: false,
      last_seen: Date.now() - 3600000,
    },
    {
      user_id: 'user-3',
      username: 'carol',
      display_name: 'Carol Williams',
      role: 'member',
      joined_at: Date.now() - 86400000 * 15,
      is_online: true,
    },
    {
      user_id: 'user-4',
      username: 'david',
      display_name: 'David Brown',
      role: 'member',
      joined_at: Date.now() - 86400000 * 10,
      is_online: false,
      last_seen: Date.now() - 7200000,
    },
  ];
}

export default GroupInfo;
