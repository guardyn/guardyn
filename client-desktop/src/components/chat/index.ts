/**
 * Chat Components
 *
 * Re-exports all chat-related components for easy importing.
 */

export { ConversationActions, type ConversationActionsProps } from './ConversationActions';
export { ConversationItem, type ConversationItemProps } from './ConversationItem';
export { ConversationList, type Conversation, type ConversationListProps } from './ConversationList';
export { EmojiPicker, type EmojiPickerProps } from './EmojiPicker';
export { MessageBubble, type MessageBubbleProps, type MessageReaction } from './MessageBubble';
export { MessageInput, type MessageInputProps } from './MessageInput';
export { NewConversationModal, type NewConversationModalProps, type UserSearchResult } from './NewConversationModal';
export { QuotedMessage, type QuotedMessageProps } from './QuotedMessage';
export { ReactionMenu, type ReactionMenuProps } from './ReactionMenu';

// Re-export PresenceStatus from shared components (single source of truth)
// Use import from '../shared/PresenceIndicator' or from websocket.types
