/**
 * Stores Index
 *
 * Central export for all SolidJS stores.
 * Uses namespace exports to avoid naming conflicts.
 */

export * as messageStore from './messageStore';
export * as conversationStore from './conversationStore';
export * as presenceStore from './presenceStore';

// Re-export commonly used types for convenience
export type { Message, MessageStatus, MessageAttachment, TypingUser } from './messageStore';
export type { Conversation, ConversationParticipant, ConversationFilter } from './conversationStore';
export type { UserPresence, TypingIndicator, PresenceEvent } from './presenceStore';
