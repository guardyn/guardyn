/**
 * Messaging API
 *
 * Handles encrypted messaging operations.
 */

import { invoke } from '@tauri-apps/api/core';
import type { Conversation, Message } from '../types';

export interface SendMessageRequest {
  conversation_id: string;
  content: string;
  reply_to?: string;
}

export interface GetMessagesRequest {
  conversation_id: string;
  limit?: number;
  before?: string;
}

/**
 * Get all conversations for the current user
 */
export async function getConversations(): Promise<Conversation[]> {
  return invoke<Conversation[]>('get_conversations');
}

/**
 * Get messages in a conversation
 */
export async function getMessages(request: GetMessagesRequest): Promise<Message[]> {
  return invoke<Message[]>('get_messages', { request });
}

/**
 * Send an encrypted message
 */
export async function sendMessage(request: SendMessageRequest): Promise<Message> {
  return invoke<Message>('send_message', { request });
}

/**
 * Mark a message as read
 */
export async function markAsRead(conversationId: string, messageId: string): Promise<void> {
  return invoke('mark_as_read', { conversationId, messageId });
}

/**
 * Add a reaction to a message
 */
export async function addReaction(messageId: string, emoji: string): Promise<void> {
  return invoke('add_reaction', { messageId, emoji });
}

/**
 * Remove a reaction from a message
 */
export async function removeReaction(messageId: string, emoji: string): Promise<void> {
  return invoke('remove_reaction', { messageId, emoji });
}

/**
 * Delete a message
 */
export async function deleteMessage(messageId: string, forEveryone: boolean): Promise<void> {
  return invoke('delete_message', { messageId, forEveryone });
}

/**
 * Start typing indicator
 */
export async function startTyping(conversationId: string): Promise<void> {
  return invoke('start_typing', { conversationId });
}

/**
 * Stop typing indicator
 */
export async function stopTyping(conversationId: string): Promise<void> {
  return invoke('stop_typing', { conversationId });
}
