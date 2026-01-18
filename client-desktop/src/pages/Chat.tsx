import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, onMount, Show } from 'solid-js';
import type { Conversation, Message } from '../types';

interface ChatPageProps {}

const Chat: Component<ChatPageProps> = () => {
  const [conversations, setConversations] = createSignal<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = createSignal<string | null>(null);
  const [messages, setMessages] = createSignal<Message[]>([]);
  const [newMessage, setNewMessage] = createSignal('');
  const [loading, setLoading] = createSignal(true);

  onMount(async () => {
    try {
      // Load conversations
      const convs = await invoke<Conversation[]>('get_conversations');
      setConversations(convs);
    } catch (err) {
      console.error('Failed to load conversations:', err);
    } finally {
      setLoading(false);
    }
  });

  const selectConversation = async (id: string) => {
    setSelectedConversation(id);
    try {
      const msgs = await invoke<Message[]>('get_messages', { conversationId: id });
      setMessages(msgs);
    } catch (err) {
      console.error('Failed to load messages:', err);
    }
  };

  const sendMessage = async (e: Event) => {
    e.preventDefault();
    const content = newMessage().trim();
    if (!content || !selectedConversation()) return;

    try {
      await invoke('send_message', {
        conversationId: selectedConversation(),
        content,
      });
      setNewMessage('');
      // Refresh messages
      const msgs = await invoke<Message[]>('get_messages', { conversationId: selectedConversation() });
      setMessages(msgs);
    } catch (err) {
      console.error('Failed to send message:', err);
    }
  };

  return (
    <div class="flex h-full">
      {/* Conversations list */}
      <div class="w-80 bg-gray-800 border-r border-gray-700 flex flex-col">
        <div class="p-4 border-b border-gray-700">
          <h2 class="text-lg font-semibold text-white">Messages</h2>
        </div>

        <div class="flex-1 overflow-y-auto">
          <Show when={!loading()} fallback={<div class="p-4 text-gray-400">Loading...</div>}>
            <Show
              when={conversations() && conversations().length > 0}
              fallback={
                <div class="p-4 text-gray-400 text-center">
                  <p>No conversations yet</p>
                  <button class="mt-2 text-guardyn-500 hover:text-guardyn-400">
                    Start a new chat
                  </button>
                </div>
              }
            >
              <For each={conversations()}>
                {(conv) => (
                  <button
                    onClick={() => selectConversation(conv.id)}
                    class={`w-full p-4 flex items-center hover:bg-gray-700 transition ${
                      selectedConversation() === conv.id ? 'bg-gray-700' : ''
                    }`}
                  >
                    <div class="w-10 h-10 rounded-full bg-guardyn-600 flex items-center justify-center text-white font-medium">
                      {conv.name?.[0] || 'C'}
                    </div>
                    <div class="ml-3 flex-1 text-left">
                      <p class="text-white font-medium">{conv.name || 'Conversation'}</p>
                      <p class="text-sm text-gray-400 truncate">
                        {conv.last_message?.content || 'No messages'}
                      </p>
                    </div>
                    <Show when={conv.unread_count > 0}>
                      <span class="bg-guardyn-500 text-white text-xs px-2 py-1 rounded-full">
                        {conv.unread_count}
                      </span>
                    </Show>
                  </button>
                )}
              </For>
            </Show>
          </Show>
        </div>
      </div>

      {/* Chat area */}
      <div class="flex-1 flex flex-col">
        <Show
          when={selectedConversation()}
          fallback={
            <div class="flex-1 flex items-center justify-center text-gray-400">
              <div class="text-center">
                <svg class="w-16 h-16 mx-auto mb-4 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
                </svg>
                <p>Select a conversation to start messaging</p>
              </div>
            </div>
          }
        >
          {/* Messages */}
          <div class="flex-1 overflow-y-auto p-4 space-y-4">
            <For each={messages()}>
              {(message) => (
                <div class={`flex ${message.sender_id === 'self' ? 'justify-end' : 'justify-start'}`}>
                  <div
                    class={`message-bubble ${
                      message.sender_id === 'self' ? 'message-bubble-sent' : 'message-bubble-received'
                    }`}
                  >
                    <p>{message.content}</p>
                    <p class="text-xs opacity-70 mt-1">
                      {new Date(message.timestamp).toLocaleTimeString()}
                    </p>
                  </div>
                </div>
              )}
            </For>
          </div>

          {/* Message input */}
          <form onSubmit={sendMessage} class="p-4 border-t border-gray-700">
            <div class="flex space-x-2">
              <input
                type="text"
                value={newMessage()}
                onInput={(e) => setNewMessage(e.currentTarget.value)}
                placeholder="Type a message..."
                class="flex-1 px-4 py-3 bg-gray-700 border border-gray-600 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent"
              />
              <button
                type="submit"
                disabled={!newMessage().trim()}
                aria-label="Send message"
                class="px-6 py-3 bg-guardyn-600 text-white rounded-lg hover:bg-guardyn-700 disabled:opacity-50 disabled:cursor-not-allowed transition"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                </svg>
              </button>
            </div>
          </form>
        </Show>
      </div>
    </div>
  );
};

export default Chat;
