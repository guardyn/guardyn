import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, onCleanup, onMount, Show } from 'solid-js';
import type { Conversation } from '../types';
import { initWebSocket, destroyWebSocket, getWebSocket, MessageType } from '../api/websocket';
import { startMockGenerator, stopMockGenerator } from '../api/websocket.mock';
import {
  messageStore,
  addMessage,
  setActiveConversation,
  getActiveMessages,
  getTypingUsers,
  addTypingUser,
  removeTypingUser,
} from '../stores/messageStore';
import { TypingIndicator } from '../components/shared';

interface ChatPageProps {}

const Chat: Component<ChatPageProps> = () => {
  const [conversations, setConversations] = createSignal<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = createSignal<string | null>(null);
  const [newMessage, setNewMessage] = createSignal('');
  const [loading, setLoading] = createSignal(true);
  const [isConnected, setIsConnected] = createSignal(false);

  // Get messages from store for active conversation
  const messages = () => getActiveMessages();
  const typingUsers = () => getTypingUsers();

  onMount(async () => {
    try {
      // Initialize WebSocket in stub mode for development
      initWebSocket('wss://localhost:3000/ws', true);
      const ws = getWebSocket();
      
      if (ws) {
        // Listen for connection events
        ws.on('connected', () => setIsConnected(true));
        ws.on('disconnected', () => setIsConnected(false));
        
        // Listen for incoming messages
        ws.on(MessageType.TEXT_MESSAGE, (data) => {
          addMessage({
            id: data.id || crypto.randomUUID(),
            conversationId: data.conversationId || selectedConversation() || 'demo',
            senderId: data.senderId || 'other',
            senderName: data.senderName || 'User',
            content: data.content,
            timestamp: new Date(data.timestamp || Date.now()),
            status: 'delivered',
          });
        });
        
        // Listen for typing indicators
        ws.on(MessageType.TYPING_START, (data) => {
          addTypingUser(data.conversationId, data.userId, data.userName);
        });
        
        ws.on(MessageType.TYPING_STOP, (data) => {
          removeTypingUser(data.conversationId, data.userId);
        });
        
        // Connect WebSocket
        ws.connect();
        
        // Start mock generator in development
        startMockGenerator();
      }

      // Load conversations from Tauri backend
      const convs = await invoke<Conversation[]>('get_conversations');
      setConversations(convs);
    } catch (err) {
      console.error('Failed to load conversations:', err);
    } finally {
      setLoading(false);
    }
  });
  
  onCleanup(() => {
    stopMockGenerator();
    destroyWebSocket();
  });

  const selectConversation = async (id: string) => {
    setSelectedConversation(id);
    setActiveConversation(id);
    
    // Also load messages from Tauri backend if available
    try {
      const msgs = await invoke<Array<{
        id: string;
        sender_id: string;
        content: string;
        timestamp: string;
      }>>('get_messages', { conversationId: id });
      
      // Add backend messages to store
      msgs.forEach(msg => {
        addMessage({
          id: msg.id,
          conversationId: id,
          senderId: msg.sender_id,
          senderName: msg.sender_id === 'self' ? 'You' : 'User',
          content: msg.content,
          timestamp: new Date(msg.timestamp),
          status: 'delivered',
        });
      });
    } catch (err) {
      console.error('Failed to load messages from backend:', err);
    }
  };

  const sendMessage = async (e: Event) => {
    e.preventDefault();
    const content = newMessage().trim();
    const convId = selectedConversation();
    if (!content || !convId) return;

    // Create optimistic message
    const messageId = crypto.randomUUID();
    addMessage({
      id: messageId,
      conversationId: convId,
      senderId: 'self',
      senderName: 'You',
      content,
      timestamp: new Date(),
      status: 'sending',
    });
    
    setNewMessage('');

    try {
      // Send via WebSocket
      const ws = getWebSocket();
      if (ws && isConnected()) {
        ws.send({
          type: MessageType.TEXT_MESSAGE,
          conversationId: convId,
          content,
          timestamp: Date.now(),
        });
      }
      
      // Also send via Tauri backend
      await invoke('send_message', {
        conversationId: convId,
        content,
      });
    } catch (err) {
      console.error('Failed to send message:', err);
    }
  };

  // Handle typing indicator
  const handleTyping = () => {
    const ws = getWebSocket();
    const convId = selectedConversation();
    if (ws && convId && isConnected()) {
      ws.send({
        type: MessageType.TYPING_START,
        conversationId: convId,
      });
    }
  };

  return (
    <div class="flex h-full">
      {/* Conversations list */}
      <div class="w-80 bg-sidebar-light dark:bg-sidebar-dark border-r border-gray-200 dark:border-gray-700 flex flex-col transition-colors duration-200">
        <div class="p-4 border-b border-gray-200 dark:border-gray-700">
          <div class="flex items-center justify-between">
            <h2 class="text-lg font-semibold text-gray-900 dark:text-white">Messages</h2>
            <div class="flex items-center gap-2">
              <span 
                class={`w-2 h-2 rounded-full ${isConnected() ? 'bg-green-500 animate-pulse' : 'bg-gray-400'}`}
                title={isConnected() ? 'Connected' : 'Disconnected'}
              />
              <span class="text-xs text-gray-500 dark:text-gray-400">
                {isConnected() ? 'Live' : 'Offline'}
              </span>
            </div>
          </div>
        </div>

        <div class="flex-1 overflow-y-auto">
          <Show when={!loading()} fallback={<div class="p-4 text-gray-500 dark:text-gray-400">Loading...</div>}>
            <Show
              when={conversations() && conversations().length > 0}
              fallback={
                <div class="p-4 text-gray-500 dark:text-gray-400 text-center">
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
                    class={`w-full p-4 flex items-center hover:bg-gray-100 dark:hover:bg-gray-700 transition ${
                      selectedConversation() === conv.id ? 'bg-gray-100 dark:bg-gray-700' : ''
                    }`}
                  >
                    <div class="w-10 h-10 rounded-full bg-guardyn-600 flex items-center justify-center text-white font-medium">
                      {conv.name?.[0] || 'C'}
                    </div>
                    <div class="ml-3 flex-1 text-left">
                      <p class="text-gray-900 dark:text-white font-medium">{conv.name || 'Conversation'}</p>
                      <p class="text-sm text-gray-500 dark:text-gray-400 truncate">
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
      <div class="flex-1 flex flex-col bg-chat-light dark:bg-chat-dark chat-bg-gradient chat-pattern transition-colors duration-200">
        <Show
          when={selectedConversation()}
          fallback={
            <div class="flex-1 flex items-center justify-center text-gray-500 dark:text-gray-400">
              <div class="text-center">
                <svg class="w-16 h-16 mx-auto mb-4 text-gray-400 dark:text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
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
                <div class={`flex ${message.isOwn ? 'justify-end' : 'justify-start'}`}>
                  <div
                    class={`message-bubble ${
                      message.isOwn ? 'message-bubble-sent' : 'message-bubble-received'
                    }`}
                  >
                    <Show when={!message.isOwn}>
                      <p class="text-xs font-medium text-guardyn-600 dark:text-guardyn-400 mb-1">
                        {message.senderName}
                      </p>
                    </Show>
                    <p>{message.content}</p>
                    <div class="flex items-center justify-end gap-1 mt-1">
                      <p class="text-xs opacity-70">
                        {message.timestamp.toLocaleTimeString()}
                      </p>
                      <Show when={message.isOwn}>
                        <span class="text-xs opacity-70">
                          {message.status === 'sending' ? '◯' : message.status === 'delivered' ? '✓' : '✓✓'}
                        </span>
                      </Show>
                    </div>
                  </div>
                </div>
              )}
            </For>
            
            {/* Typing indicator */}
            <Show when={typingUsers().length > 0}>
              <TypingIndicator users={typingUsers()} />
            </Show>
          </div>

          {/* Message input */}
          <form onSubmit={sendMessage} class="p-4 border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 transition-colors duration-200">
            <div class="flex space-x-2">
              <input
                type="text"
                value={newMessage()}
                onInput={(e) => {
                  setNewMessage(e.currentTarget.value);
                  handleTyping();
                }}
                placeholder="Type a message..."
                class="flex-1 px-4 py-3 bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent"
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
