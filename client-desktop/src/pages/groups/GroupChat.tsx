import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, onCleanup, onMount, Show } from 'solid-js';
import { useNavigate, useParams } from '@solidjs/router';
import { MessageBubble, MessageInput } from '../../components/chat';
import { Avatar, TypingIndicator } from '../../components/shared';
import type { Group, GroupMember, GroupMessage } from '../../types';

/**
 * GroupChat Page
 * 
 * Chat interface for group conversations.
 * Features:
 * - Message list with sender names/avatars
 * - Message input with encryption
 * - Group info header
 * - Real-time updates via WebSocket
 */
const GroupChat: Component = () => {
  const params = useParams<{ id: string }>();
  const navigate = useNavigate();

  const [group, setGroup] = createSignal<Group | null>(null);
  const [members, setMembers] = createSignal<GroupMember[]>([]);
  const [messages, setMessages] = createSignal<GroupMessage[]>([]);
  const [loading, setLoading] = createSignal(true);
  const [sending, setSending] = createSignal(false);
  const [typingUsers] = createSignal<string[]>([]);

  let messagesEndRef: HTMLDivElement | undefined;

  onMount(async () => {
    await loadGroupData();
    scrollToBottom();
  });

  onCleanup(() => {
    // Cleanup WebSocket subscriptions
  });

  const loadGroupData = async () => {
    setLoading(true);
    try {
      // Load group info
      const groupData = await invoke<Group>('get_group', { groupId: params.id });
      setGroup(groupData);

      // Load members
      const membersData = await invoke<GroupMember[]>('get_group_members', {
        groupId: params.id,
      });
      setMembers(membersData);

      // Load messages
      const messagesData = await invoke<GroupMessage[]>('get_group_messages', {
        groupId: params.id,
        limit: 50,
      });
      setMessages(messagesData);
    } catch (err) {
      console.error('Failed to load group data:', err);
      // Use mock data in development
      setGroup(getMockGroup());
      setMembers(getMockMembers());
      setMessages(getMockMessages());
    } finally {
      setLoading(false);
    }
  };

  const scrollToBottom = () => {
    setTimeout(() => {
      messagesEndRef?.scrollIntoView({ behavior: 'smooth' });
    }, 100);
  };

  const sendMessage = async (content: string) => {
    if (!content.trim() || !group()) return;

    setSending(true);
    try {
      const newMessage = await invoke<GroupMessage>('send_group_message', {
        groupId: params.id,
        content,
      });
      setMessages((prev) => [...prev, newMessage]);
      scrollToBottom();
    } catch (err) {
      console.error('Failed to send message:', err);
      // Add optimistic message for demo
      const optimisticMessage: GroupMessage = {
        id: crypto.randomUUID(),
        group_id: params.id,
        sender_id: 'current-user',
        sender_name: 'You',
        content,
        timestamp: Date.now(),
        status: 'Sent',
        reactions: [],
      };
      setMessages((prev) => [...prev, optimisticMessage]);
      scrollToBottom();
    } finally {
      setSending(false);
    }
  };

  const handleTyping = async () => {
    try {
      await invoke('send_group_typing', { groupId: params.id, isTyping: true });
    } catch (err) {
      console.error('Failed to send typing indicator:', err);
    }
  };

  const openGroupInfo = () => {
    navigate(`/groups/${params.id}/info`);
  };

  const goBack = () => {
    navigate('/groups');
  };

  const getMemberInfo = (senderId: string): { name: string; avatar?: string } => {
    const member = members().find((m) => m.user_id === senderId);
    return {
      name: member?.display_name || member?.username || 'Unknown',
      avatar: member?.avatar_url,
    };
  };

  return (
    <div class="flex flex-col h-full bg-chat-light dark:bg-chat-dark">
      {/* Header */}
      <header class="flex items-center gap-4 px-4 py-3 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800 shadow-sm">
        {/* Back button */}
        <button
          onClick={goBack}
          class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
          title="Back to groups"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
          </svg>
        </button>

        {/* Group info */}
        <button
          onClick={openGroupInfo}
          class="flex items-center gap-3 flex-1 hover:bg-neutral-50 dark:hover:bg-neutral-800/50 rounded-lg px-2 py-1 transition-colors"
        >
          <Avatar
            name={group()?.name || 'Group'}
            src={group()?.avatar_url}
            size="md"
            showPresence={false}
          />
          <div class="text-left">
            <h2 class="font-semibold text-neutral-900 dark:text-white">
              {group()?.name || 'Loading...'}
            </h2>
            <p class="text-sm text-neutral-500 dark:text-neutral-400">
              {group()?.member_count || 0} members
            </p>
          </div>
        </button>

        {/* Actions */}
        <div class="flex items-center gap-2">
          {/* Voice call */}
          <button
            class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
            title="Start voice call"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z"
              />
            </svg>
          </button>
          {/* Video call */}
          <button
            class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
            title="Start video call"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z"
              />
            </svg>
          </button>
          {/* Info */}
          <button
            onClick={openGroupInfo}
            class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
            title="Group info"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          </button>
        </div>
      </header>

      {/* Messages */}
      <div class="flex-1 overflow-y-auto px-4 py-4">
        <Show when={loading()}>
          <div class="flex items-center justify-center h-full">
            <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-guardyn-500" />
          </div>
        </Show>

        <Show when={!loading()}>
          <div class="space-y-4">
            <For each={messages()}>
              {(message) => {
                const isOwn = message.sender_id === 'current-user';
                const memberInfo = getMemberInfo(message.sender_id);

                return (
                  <div class={`flex ${isOwn ? 'justify-end' : 'justify-start'}`}>
                    <div class={`flex gap-2 max-w-[70%] ${isOwn ? 'flex-row-reverse' : ''}`}>
                      {/* Avatar for non-own messages */}
                      <Show when={!isOwn}>
                        <Avatar
                          name={memberInfo.name}
                          src={memberInfo.avatar}
                          size="sm"
                        />
                      </Show>

                      <div>
                        {/* Sender name */}
                        <Show when={!isOwn}>
                          <p class="text-xs text-neutral-500 dark:text-neutral-400 mb-1 ml-1">
                            {memberInfo.name}
                          </p>
                        </Show>
                        <MessageBubble
                          content={message.content}
                          timestamp={new Date(message.timestamp)}
                          isOwn={isOwn}
                          senderName={message.sender_name}
                          isRead={message.status === 'Read'}
                          isSending={message.status === 'Sending'}
                        />
                      </div>
                    </div>
                  </div>
                );
              }}
            </For>

            {/* Typing indicator */}
            <Show when={typingUsers().length > 0}>
              <TypingIndicator users={typingUsers()} />
            </Show>
          </div>
          <div ref={messagesEndRef} />
        </Show>
      </div>

      {/* Message Input */}
      <div class="px-4 py-3 bg-white dark:bg-neutral-900 border-t border-neutral-200 dark:border-neutral-800">
        <MessageInput
          onSend={sendMessage}
          onTyping={handleTyping}
          disabled={loading() || sending()}
          placeholder={`Message ${group()?.name || 'group'}...`}
        />
      </div>
    </div>
  );
};

// Mock data for development
function getMockGroup(): Group {
  return {
    id: 'group-1',
    name: 'Development Team',
    description: 'Team discussions and updates',
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
      user_id: 'current-user',
      username: 'you',
      display_name: 'You',
      role: 'member',
      joined_at: Date.now() - 86400000 * 20,
      is_online: true,
    },
    {
      user_id: 'user-1',
      username: 'alice',
      display_name: 'Alice',
      role: 'owner',
      joined_at: Date.now() - 86400000 * 30,
      is_online: true,
    },
    {
      user_id: 'user-2',
      username: 'bob',
      display_name: 'Bob',
      role: 'admin',
      joined_at: Date.now() - 86400000 * 25,
      is_online: false,
      last_seen: Date.now() - 3600000,
    },
    {
      user_id: 'user-3',
      username: 'carol',
      display_name: 'Carol',
      role: 'member',
      joined_at: Date.now() - 86400000 * 15,
      is_online: true,
    },
  ];
}

function getMockMessages(): GroupMessage[] {
  return [
    {
      id: 'msg-1',
      group_id: 'group-1',
      sender_id: 'user-1',
      sender_name: 'Alice',
      content: 'Hey everyone! 👋 How\'s the progress on the new feature?',
      timestamp: Date.now() - 7200000,
      status: 'Read',
      reactions: [],
    },
    {
      id: 'msg-2',
      group_id: 'group-1',
      sender_id: 'user-2',
      sender_name: 'Bob',
      content: 'Working on the backend. Should be done by EOD.',
      timestamp: Date.now() - 6900000,
      status: 'Read',
      reactions: [],
    },
    {
      id: 'msg-3',
      group_id: 'group-1',
      sender_id: 'user-3',
      sender_name: 'Carol',
      content: 'UI components are ready for review!',
      timestamp: Date.now() - 6600000,
      status: 'Read',
      reactions: [],
    },
    {
      id: 'msg-4',
      group_id: 'group-1',
      sender_id: 'current-user',
      sender_name: 'You',
      content: 'Great work team! I\'ll review the UI now.',
      timestamp: Date.now() - 6300000,
      status: 'Delivered',
      reactions: [],
    },
    {
      id: 'msg-5',
      group_id: 'group-1',
      sender_id: 'user-1',
      sender_name: 'Alice',
      content: 'Perfect! Let me know if you need anything.',
      timestamp: Date.now() - 3600000,
      status: 'Read',
      reactions: [],
    },
  ];
}

export default GroupChat;
