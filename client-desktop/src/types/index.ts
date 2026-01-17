// User information
export interface UserInfo {
  user_id: string;
  username: string;
  display_name?: string;
  avatar_url?: string;
}

// Authentication
export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  password: string;
  display_name?: string;
}

export interface AuthResponse {
  success: boolean;
  user?: UserInfo;
  token?: string;
  error?: string;
}

// Conversations
export interface Conversation {
  id: string;
  name?: string;
  is_group: boolean;
  participant_ids: string[];
  last_message?: MessagePreview;
  unread_count: number;
  updated_at: number;
}

export interface MessagePreview {
  id: string;
  content: string;
  sender_id: string;
  timestamp: number;
}

// Messages
export interface Message {
  id: string;
  conversation_id: string;
  sender_id: string;
  content: string;
  timestamp: number;
  status: MessageStatus;
  reply_to?: string;
  reactions: Reaction[];
}

export type MessageStatus = 'Sending' | 'Sent' | 'Delivered' | 'Read' | 'Failed';

export interface Reaction {
  user_id: string;
  emoji: string;
  timestamp: number;
}

export interface SendMessageRequest {
  conversation_id: string;
  content: string;
  reply_to?: string;
}

// Crypto
export interface KeyBundle {
  identity_key: string;
  signed_prekey: string;
  prekey_signature: string;
  one_time_prekey?: string;
  pq_prekey?: string;
}

export interface EncryptedMessage {
  ciphertext: string;
  nonce: string;
  header: string;
}

// Settings
export interface UserSettings {
  theme: Theme;
  notifications_enabled: boolean;
  sound_enabled: boolean;
  show_message_preview: boolean;
  language: string;
  disappearing_messages_default?: number;
}

export type Theme = 'light' | 'dark' | 'system';
