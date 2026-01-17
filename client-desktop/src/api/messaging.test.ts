/**
 * Messaging API Integration Tests
 *
 * Tests for the messaging API module with mocked Tauri invoke.
 */

import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Conversation, Message } from '../types';
import {
    addReaction,
    deleteMessage,
    getConversations,
    getMessages,
    markAsRead,
    removeReaction,
    sendMessage,
    startTyping,
    stopTyping,
} from './messaging';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

describe('Messaging API', () => {
  beforeEach(() => {
    mockInvoke.mockClear();
  });

  const mockConversation: Conversation = {
    id: 'conv-123',
    name: 'Test Chat',
    is_group: false,
    participant_ids: ['user-1', 'user-2'],
    last_message: {
      id: 'msg-1',
      content: 'Hello!',
      sender_id: 'user-2',
      timestamp: Date.now(),
    },
    unread_count: 2,
    updated_at: Date.now(),
  };

  const mockMessage: Message = {
    id: 'msg-456',
    conversation_id: 'conv-123',
    sender_id: 'user-1',
    content: 'Test message',
    timestamp: Date.now(),
    status: 'Sent',
    reactions: [],
  };

  describe('getConversations', () => {
    it('returns list of conversations', async () => {
      mockInvoke.mockResolvedValueOnce([mockConversation]);

      const conversations = await getConversations();

      expect(mockInvoke).toHaveBeenCalledWith('get_conversations');
      expect(conversations).toHaveLength(1);
      expect(conversations[0].id).toBe('conv-123');
    });

    it('returns empty array when no conversations', async () => {
      mockInvoke.mockResolvedValueOnce([]);

      const conversations = await getConversations();

      expect(conversations).toHaveLength(0);
    });

    it('handles error gracefully', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Failed to fetch'));

      await expect(getConversations()).rejects.toThrow('Failed to fetch');
    });
  });

  describe('getMessages', () => {
    it('fetches messages for conversation', async () => {
      mockInvoke.mockResolvedValueOnce([mockMessage]);

      const messages = await getMessages({ conversation_id: 'conv-123' });

      expect(mockInvoke).toHaveBeenCalledWith('get_messages', {
        request: { conversation_id: 'conv-123' },
      });
      expect(messages).toHaveLength(1);
      expect(messages[0].content).toBe('Test message');
    });

    it('supports pagination with limit', async () => {
      mockInvoke.mockResolvedValueOnce([mockMessage]);

      await getMessages({ conversation_id: 'conv-123', limit: 50 });

      expect(mockInvoke).toHaveBeenCalledWith('get_messages', {
        request: { conversation_id: 'conv-123', limit: 50 },
      });
    });

    it('supports pagination with before cursor', async () => {
      mockInvoke.mockResolvedValueOnce([mockMessage]);

      await getMessages({
        conversation_id: 'conv-123',
        before: 'msg-100',
      });

      expect(mockInvoke).toHaveBeenCalledWith('get_messages', {
        request: { conversation_id: 'conv-123', before: 'msg-100' },
      });
    });

    it('returns empty array for new conversations', async () => {
      mockInvoke.mockResolvedValueOnce([]);

      const messages = await getMessages({ conversation_id: 'conv-new' });

      expect(messages).toHaveLength(0);
    });
  });

  describe('sendMessage', () => {
    it('sends message and returns sent message', async () => {
      mockInvoke.mockResolvedValueOnce(mockMessage);

      const result = await sendMessage({
        conversation_id: 'conv-123',
        content: 'Test message',
      });

      expect(mockInvoke).toHaveBeenCalledWith('send_message', {
        request: { conversation_id: 'conv-123', content: 'Test message' },
      });
      expect(result.id).toBe('msg-456');
    });

    it('supports reply_to for replies', async () => {
      mockInvoke.mockResolvedValueOnce(mockMessage);

      await sendMessage({
        conversation_id: 'conv-123',
        content: 'Reply message',
        reply_to: 'msg-100',
      });

      expect(mockInvoke).toHaveBeenCalledWith('send_message', {
        request: {
          conversation_id: 'conv-123',
          content: 'Reply message',
          reply_to: 'msg-100',
        },
      });
    });

    it('throws on send failure', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Send failed'));

      await expect(
        sendMessage({ conversation_id: 'conv-123', content: 'Test' })
      ).rejects.toThrow('Send failed');
    });
  });

  describe('markAsRead', () => {
    it('marks message as read', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await markAsRead('conv-123', 'msg-456');

      expect(mockInvoke).toHaveBeenCalledWith('mark_as_read', {
        conversationId: 'conv-123',
        messageId: 'msg-456',
      });
    });
  });

  describe('addReaction', () => {
    it('adds reaction to message', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await addReaction('msg-456', '👍');

      expect(mockInvoke).toHaveBeenCalledWith('add_reaction', {
        messageId: 'msg-456',
        emoji: '👍',
      });
    });

    it('supports emoji reactions', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await addReaction('msg-456', '❤️');

      expect(mockInvoke).toHaveBeenCalledWith('add_reaction', {
        messageId: 'msg-456',
        emoji: '❤️',
      });
    });
  });

  describe('removeReaction', () => {
    it('removes reaction from message', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await removeReaction('msg-456', '👍');

      expect(mockInvoke).toHaveBeenCalledWith('remove_reaction', {
        messageId: 'msg-456',
        emoji: '👍',
      });
    });
  });

  describe('deleteMessage', () => {
    it('deletes message for self only', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await deleteMessage('msg-456', false);

      expect(mockInvoke).toHaveBeenCalledWith('delete_message', {
        messageId: 'msg-456',
        forEveryone: false,
      });
    });

    it('deletes message for everyone', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await deleteMessage('msg-456', true);

      expect(mockInvoke).toHaveBeenCalledWith('delete_message', {
        messageId: 'msg-456',
        forEveryone: true,
      });
    });
  });

  describe('typing indicators', () => {
    it('starts typing indicator', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await startTyping('conv-123');

      expect(mockInvoke).toHaveBeenCalledWith('start_typing', {
        conversationId: 'conv-123',
      });
    });

    it('stops typing indicator', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await stopTyping('conv-123');

      expect(mockInvoke).toHaveBeenCalledWith('stop_typing', {
        conversationId: 'conv-123',
      });
    });
  });
});
