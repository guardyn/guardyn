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

// Calls
export interface CallInfo {
  call_id: string;
  call_type: 'voice' | 'video';
  caller_id: string;
  caller_name: string;
  state: CallState;
  started_at?: number;
  duration_seconds: number;
  participants: CallParticipant[];
  is_screen_sharing: boolean;
}

export type CallState =
  | 'initiating'
  | 'ringing'
  | 'connecting'
  | 'connected'
  | 'reconnecting'
  | 'ended'
  | 'failed';

export interface CallParticipant {
  user_id: string;
  display_name: string;
  is_muted: boolean;
  has_video: boolean;
  is_screen_sharing: boolean;
  is_speaking: boolean;
}

export interface CallHistoryEntry {
  call_id: string;
  call_type: 'voice' | 'video';
  is_group_call: boolean;
  group_id?: string;
  other_user_id: string;
  other_user_name: string;
  is_outgoing: boolean;
  end_reason: CallEndReason;
  started_at: number;
  duration_seconds: number;
}

export type CallEndReason =
  | 'completed'
  | 'missed'
  | 'declined'
  | 'busy'
  | 'failed'
  | 'cancelled';

export interface IncomingCall {
  call_id: string;
  caller_id: string;
  caller_name: string;
  caller_avatar?: string;
  call_type: 'voice' | 'video';
}

// Settings
export interface Settings {
  theme: Theme;
  notifications_enabled: boolean;
  sound_enabled: boolean;
  show_message_preview: boolean;
  language: string;
  disappearing_messages_default?: number;
  // Call settings
  auto_answer_calls: boolean;
  default_camera?: string;
  default_microphone?: string;
  default_speaker?: string;
  video_quality: VideoQuality;
  // Privacy settings
  read_receipts_enabled: boolean;
  typing_indicators_enabled: boolean;
  // Desktop settings
  start_minimized: boolean;
  minimize_to_tray: boolean;
  launch_at_startup: boolean;
}

export type Theme = 'light' | 'dark' | 'system';
export type VideoQuality = 'low' | 'medium' | 'high' | 'auto';

// Simplified settings for Settings page (matches Rust UserSettings struct)
export interface UserSettings {
  theme: Theme;
  notifications_enabled: boolean;
  sound_enabled: boolean;
  show_message_preview: boolean;
  language: string;
  disappearing_messages_default?: number;
}
