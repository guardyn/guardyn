import { describe, expect, it } from 'vitest';
import type {
    AuthResponse,
    Conversation,
    KeyBundle,
    Message,
    MessageStatus,
    Reaction,
    UserInfo,
} from './index';

describe('Type definitions', () => {
  describe('UserInfo', () => {
    it('should have required fields', () => {
      const user: UserInfo = {
        user_id: 'user-123',
        username: 'testuser',
      };

      expect(user.user_id).toBe('user-123');
      expect(user.username).toBe('testuser');
      expect(user.display_name).toBeUndefined();
      expect(user.avatar_url).toBeUndefined();
    });

    it('should support optional fields', () => {
      const user: UserInfo = {
        user_id: 'user-123',
        username: 'testuser',
        display_name: 'Test User',
        avatar_url: 'https://example.com/avatar.png',
      };

      expect(user.display_name).toBe('Test User');
      expect(user.avatar_url).toBe('https://example.com/avatar.png');
    });
  });

  describe('AuthResponse', () => {
    it('should handle successful auth', () => {
      const response: AuthResponse = {
        success: true,
        user: {
          user_id: 'user-123',
          username: 'testuser',
        },
        token: 'jwt-token-here',
      };

      expect(response.success).toBe(true);
      expect(response.user).toBeDefined();
      expect(response.token).toBe('jwt-token-here');
      expect(response.error).toBeUndefined();
    });

    it('should handle failed auth', () => {
      const response: AuthResponse = {
        success: false,
        error: 'Invalid credentials',
      };

      expect(response.success).toBe(false);
      expect(response.user).toBeUndefined();
      expect(response.token).toBeUndefined();
      expect(response.error).toBe('Invalid credentials');
    });
  });

  describe('Conversation', () => {
    it('should have correct structure for 1-on-1 chat', () => {
      const conversation: Conversation = {
        id: 'conv-123',
        name: 'Chat with Alice',
        is_group: false,
        participant_ids: ['user-1', 'user-2'],
        unread_count: 0,
        updated_at: Date.now(),
      };

      expect(conversation.is_group).toBe(false);
      expect(conversation.participant_ids).toHaveLength(2);
    });

    it('should have correct structure for group chat', () => {
      const conversation: Conversation = {
        id: 'conv-456',
        name: 'Team Chat',
        is_group: true,
        participant_ids: ['user-1', 'user-2', 'user-3'],
        unread_count: 5,
        updated_at: Date.now(),
        last_message: {
          id: 'msg-1',
          content: 'Hello everyone!',
          sender_id: 'user-1',
          timestamp: Date.now(),
        },
      };

      expect(conversation.is_group).toBe(true);
      expect(conversation.participant_ids).toHaveLength(3);
      expect(conversation.last_message).toBeDefined();
    });
  });

  describe('Message', () => {
    it('should support all message statuses', () => {
      const statuses: MessageStatus[] = ['Sending', 'Sent', 'Delivered', 'Read', 'Failed'];

      statuses.forEach((status) => {
        const message: Message = {
          id: 'msg-123',
          conversation_id: 'conv-123',
          sender_id: 'user-1',
          content: 'Test message',
          timestamp: Date.now(),
          status,
          reactions: [],
        };

        expect(message.status).toBe(status);
      });
    });

    it('should support reactions', () => {
      const reactions: Reaction[] = [
        { user_id: 'user-1', emoji: '👍', timestamp: Date.now() },
        { user_id: 'user-2', emoji: '❤️', timestamp: Date.now() },
      ];

      const message: Message = {
        id: 'msg-123',
        conversation_id: 'conv-123',
        sender_id: 'user-3',
        content: 'Great news!',
        timestamp: Date.now(),
        status: 'Read',
        reactions,
      };

      expect(message.reactions).toHaveLength(2);
      expect(message.reactions[0].emoji).toBe('👍');
    });

    it('should support reply_to', () => {
      const message: Message = {
        id: 'msg-456',
        conversation_id: 'conv-123',
        sender_id: 'user-1',
        content: 'Reply to your message',
        timestamp: Date.now(),
        status: 'Sent',
        reply_to: 'msg-123',
        reactions: [],
      };

      expect(message.reply_to).toBe('msg-123');
    });
  });

  describe('KeyBundle', () => {
    it('should have required crypto fields', () => {
      const bundle: KeyBundle = {
        identity_key: 'hex-encoded-identity-key',
        signed_prekey: 'hex-encoded-signed-prekey',
        prekey_signature: 'hex-encoded-signature',
      };

      expect(bundle.identity_key).toBeDefined();
      expect(bundle.signed_prekey).toBeDefined();
      expect(bundle.prekey_signature).toBeDefined();
    });

    it('should support post-quantum keys', () => {
      const bundle: KeyBundle = {
        identity_key: 'identity-key',
        signed_prekey: 'signed-prekey',
        prekey_signature: 'signature',
        one_time_prekey: 'one-time-key',
        pq_prekey: 'ml-kem-key',
      };

      expect(bundle.pq_prekey).toBe('ml-kem-key');
    });
  });
});
