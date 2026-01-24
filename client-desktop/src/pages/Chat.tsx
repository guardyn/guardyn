import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, For, onCleanup, onMount, Show } from 'solid-js';
import { destroyWebSocket, getWebSocket, initWebSocket, type MessagePayload, type TypingPayload } from '../api/websocket';
import { startMockGenerator, stopMockGenerator } from '../api/websocket.mock';
import { ForwardModal, MessageInput, MessageStatusIndicator, QuotedMessage, ReactionMenu } from '../components/chat';
import { TypingIndicator } from '../components/shared';
import {
    addMessage,
    addTypingUser,
    clearReplyingTo,
    deleteMessage as deleteMessageFromStore,
    forwardMessage,
    getActiveMessages,
    getActiveTypingUsers,
    getMessageById,
    getReplyingTo,
    removeTypingUser,
    setActiveConversation,
    setReplyingTo,
    toggleReaction,
    type Message as StoreMessage
} from '../stores/messageStore';
import type { Conversation } from '../types';

interface ChatPageProps {}

const Chat: Component<ChatPageProps> = () => {
  const [conversations, setConversations] = createSignal<Conversation[]>([]);
  const [selectedConversation, setSelectedConversation] = createSignal<string | null>(null);
  const [loading, setLoading] = createSignal(true);
  const [isConnected, setIsConnected] = createSignal(false);

  // Reaction menu state
  const [reactionMenu, setReactionMenu] = createSignal<{
    isOpen: boolean;
    position: { x: number; y: number };
    messageId: string;
    isOwnMessage: boolean;
    messageContent: string;
  }>({
    isOpen: false,
    position: { x: 0, y: 0 },
    messageId: '',
    isOwnMessage: false,
    messageContent: '',
  });

  // Forward modal state
  const [forwardModal, setForwardModal] = createSignal<{
    isOpen: boolean;
    messageId: string;
    messageContent: string;
  }>({
    isOpen: false,
    messageId: '',
    messageContent: '',
  });

  // Get messages from store for active conversation
  const messages = () => getActiveMessages();
  const typingUsers = () => getActiveTypingUsers();
  const replyingTo = () => getReplyingTo();

  onMount(async () => {
    try {
      // Initialize WebSocket in stub mode for development
      const ws = initWebSocket({
        url: 'wss://localhost:3000/ws',
        stubMode: true,
        autoReconnect: true,
      });

      if (ws) {
        // Listen for connection state changes
        ws.onStateChange((state) => {
          setIsConnected(state === 'connected');
        });

        // Listen for incoming messages
        ws.onMessage((data: MessagePayload) => {
          addMessage({
            id: data.message_id || crypto.randomUUID(),
            conversationId: data.conversation_id || selectedConversation() || 'demo',
            senderId: data.sender_id || 'other',
            senderName: data.sender_id || 'User',
            content: data.content,
            timestamp: typeof data.timestamp === 'string' ? new Date(data.timestamp).getTime() : (data.timestamp || Date.now()),
            status: 'delivered',
          });
        });

        // Listen for typing indicators
        ws.onTyping((data: TypingPayload) => {
          if (data.is_typing) {
            addTypingUser(data.conversation_id, data.user_id, data.user_id);
          } else {
            removeTypingUser(data.conversation_id, data.user_id);
          }
        });

        // Connect WebSocket
        ws.connect();

        // Start mock generator in development
        startMockGenerator(ws);
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
          timestamp: new Date(msg.timestamp).getTime(),
          status: 'delivered',
        });
      });
    } catch (err) {
      console.error('Failed to load messages from backend:', err);
    }
  };

  // Handle send message from MessageInput component (with optional media)
  const handleSendMessage = async (content: string, mediaId?: string) => {
    const convId = selectedConversation();
    if (!convId) return;
    if (!content.trim() && !mediaId) return;

    // Get reply context if replying
    const replyContext = replyingTo();

    // Create optimistic message with optional replyTo and media
    const messageId = crypto.randomUUID();
    const messageData = {
      id: messageId,
      conversationId: convId,
      senderId: 'self',
      senderName: 'You',
      content,
      timestamp: Date.now(),
      status: 'sending' as const,
      mediaId,
      ...(replyContext && {
        replyTo: {
          id: replyContext.id,
          senderId: replyContext.senderId,
          senderName: replyContext.senderName,
          content: replyContext.preview,
          preview: replyContext.preview,
        },
      }),
    };

    addMessage(messageData);

    // Clear reply state
    if (replyContext) {
      clearReplyingTo();
    }

    try {
      // Send via WebSocket
      const ws = getWebSocket();
      if (ws && isConnected()) {
        ws.sendMessage(convId, content, {
          clientMessageId: messageId,
          mediaId,
        });
      }

      // Also send via Tauri backend
      await invoke('send_message', {
        conversationId: convId,
        content,
        mediaId,
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
      ws.sendTyping(convId, true);
    }
  };

  // Handle right-click / long-press on message
  const handleMessageContextMenu = (
    e: MouseEvent,
    message: StoreMessage
  ) => {
    e.preventDefault();
    setReactionMenu({
      isOpen: true,
      position: { x: e.clientX, y: e.clientY },
      messageId: message.id,
      isOwnMessage: message.isOwn,
      messageContent: message.content,
    });
  };

  // Handle reaction
  const handleReaction = (emoji: string) => {
    const convId = selectedConversation();
    const msgId = reactionMenu().messageId;
    if (convId && msgId) {
      toggleReaction(convId, msgId, emoji);

      // TODO: Send reaction to backend once implemented
      // const ws = getWebSocket();
      // if (ws && isConnected()) {
      //   ws.sendReaction(convId, msgId, emoji);
      // }
    }
  };

  // Handle copy message
  const handleCopy = () => {
    const content = reactionMenu().messageContent;
    if (content) {
      navigator.clipboard.writeText(content).catch(console.error);
    }
  };

  // Handle delete message
  const handleDelete = async () => {
    const convId = selectedConversation();
    const msgId = reactionMenu().messageId;
    if (convId && msgId) {
      deleteMessageFromStore(convId, msgId);

      try {
        await invoke('delete_message', {
          conversationId: convId,
          messageId: msgId,
        });
      } catch (err) {
        console.error('Failed to delete message:', err);
      }
    }
  };

  // Handle reply to message
  const handleReply = () => {
    const convId = selectedConversation();
    const msgId = reactionMenu().messageId;
    if (convId && msgId) {
      setReplyingTo(convId, msgId);
    }
  };

  // Handle forward message - open modal
  const handleForward = () => {
    const menu = reactionMenu();
    setForwardModal({
      isOpen: true,
      messageId: menu.messageId,
      messageContent: menu.messageContent,
    });
    closeReactionMenu();
  };

  // Handle forward confirm
  const handleForwardConfirm = (conversationIds: string[], messageId: string) => {
    const message = getMessageById(messageId);
    if (message) {
      forwardMessage(
        {
          id: message.id,
          content: message.content,
          senderId: message.senderId,
          senderName: message.senderName,
        },
        conversationIds
      );
    }
    setForwardModal({ isOpen: false, messageId: '', messageContent: '' });
  };

  // Close forward modal
  const closeForwardModal = () => {
    setForwardModal({ isOpen: false, messageId: '', messageContent: '' });
  };

  // Scroll to a specific message
  const scrollToMessage = (messageId: string) => {
    const element = document.getElementById(`message-${messageId}`);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth', block: 'center' });
      // Highlight the message briefly
      element.classList.add('ring-2', 'ring-guardyn-500');
      setTimeout(() => {
        element.classList.remove('ring-2', 'ring-guardyn-500');
      }, 2000);
    }
  };

  // Close reaction menu
  const closeReactionMenu = () => {
    setReactionMenu(prev => ({ ...prev, isOpen: false }));
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

        <div class="flex-1 overflow-y-auto conversations" data-testid="conversation-list">
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
                <div
                  id={`message-${message.id}`}
                  class={`flex ${message.isOwn ? 'justify-end' : 'justify-start'} transition-all duration-300`}
                  onContextMenu={(e) => handleMessageContextMenu(e, message)}
                >
                  <div class="max-w-[70%]">
                    <div
                      class={`message-bubble ${
                        message.isOwn ? 'message-bubble-sent' : 'message-bubble-received'
                      } cursor-pointer transition-transform hover:scale-[1.01]`}
                    >
                      {/* Quoted message (reply) */}
                      <Show when={message.replyTo}>
                        <QuotedMessage
                          senderName={message.replyTo!.senderName}
                          preview={message.replyTo!.preview}
                          isOwnMessage={message.replyTo!.senderId === 'self'}
                          onClick={() => scrollToMessage(message.replyTo!.id)}
                          variant="bubble"
                        />
                      </Show>

                      <Show when={!message.isOwn}>
                        <p class="text-xs font-medium text-guardyn-600 dark:text-guardyn-400 mb-1">
                          {message.senderName}
                        </p>
                      </Show>
                      <p>{message.content}</p>
                      <div class="flex items-center justify-end gap-1 mt-1">
                        <p class="text-xs opacity-70">
                          {new Date(message.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </p>
                        {/* Read receipt status icons */}
                        <Show when={message.isOwn}>
                          <MessageStatusIndicator status={message.status} class="w-4 h-4" />
                        </Show>
                      </div>
                    </div>

                    {/* Reactions display */}
                    <Show when={message.reactions && message.reactions.length > 0}>
                      <div class={`flex flex-wrap gap-1 mt-1 ${message.isOwn ? 'justify-end' : 'justify-start'}`}>
                        <For each={message.reactions}>
                          {(reaction) => (
                            <button
                              onClick={() => {
                                const convId = selectedConversation();
                                if (convId) {
                                  toggleReaction(convId, message.id, reaction.emoji);
                                }
                              }}
                              class={`
                                inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs
                                transition-all duration-200 hover:scale-105 active:scale-95
                                ${reaction.hasReacted
                                  ? 'bg-guardyn-100 dark:bg-guardyn-900/30 border border-guardyn-300 dark:border-guardyn-700'
                                  : 'bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600'
                                }
                              `}
                              title={`${reaction.count} reaction${reaction.count > 1 ? 's' : ''}`}
                            >
                              <span>{reaction.emoji}</span>
                              <span class="text-gray-600 dark:text-gray-300">{reaction.count}</span>
                            </button>
                          )}
                        </For>
                      </div>
                    </Show>
                  </div>
                </div>
              )}
            </For>

            {/* Typing indicator */}
            <Show when={typingUsers().length > 0}>
              <TypingIndicator users={typingUsers().map(u => u.userName)} />
            </Show>
          </div>

          {/* Reaction Menu */}
          <ReactionMenu
            isOpen={reactionMenu().isOpen}
            position={reactionMenu().position}
            messageId={reactionMenu().messageId}
            isOwnMessage={reactionMenu().isOwnMessage}
            onReaction={handleReaction}
            onReply={handleReply}
            onForward={handleForward}
            onCopy={handleCopy}
            onDelete={reactionMenu().isOwnMessage ? handleDelete : undefined}
            onClose={closeReactionMenu}
          />

          {/* Forward Modal */}
          <ForwardModal
            isOpen={forwardModal().isOpen}
            messageId={forwardModal().messageId}
            messageContent={forwardModal().messageContent}
            conversations={conversations().map(c => ({
              id: c.id,
              name: c.name || `Conversation ${c.id.slice(0, 8)}`,
              lastMessage: c.last_message?.content,
            }))}
            onForward={handleForwardConfirm}
            onClose={closeForwardModal}
          />

          {/* Message input */}
          <div class="border-t border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 transition-colors duration-200">
            {/* Reply composer preview */}
            <Show when={replyingTo()}>
              <div class="px-4 pt-3">
                <QuotedMessage
                  senderName={replyingTo()!.senderName}
                  preview={replyingTo()!.preview}
                  onDismiss={clearReplyingTo}
                  variant="input"
                />
              </div>
            </Show>

            <div class="p-4">
              <MessageInput
                onSend={handleSendMessage}
                onTyping={handleTyping}
                conversationId={selectedConversation() ?? undefined}
                placeholder="Type a message..."
              />
            </div>
          </div>
        </Show>
      </div>
    </div>
  );
};

export default Chat;
