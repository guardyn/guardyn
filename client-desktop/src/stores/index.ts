/**
 * Stores Index
 *
 * Central export for all SolidJS stores.
 * Uses namespace exports to avoid naming conflicts.
 */

export * as conversationStore from './conversationStore';
export * as messageStore from './messageStore';
export * as presenceStore from './presenceStore';

// Re-export commonly used types for convenience
export type { Conversation, ConversationFilter, ConversationParticipant } from './conversationStore';
export type { Message, MessageAttachment, MessageStatus, TypingUser } from './messageStore';
export type { PresenceEvent, TypingIndicator, UserPresence } from './presenceStore';

