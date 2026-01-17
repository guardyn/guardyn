/**
 * Calls API
 *
 * Handles voice and video calls with WebRTC.
 */

import { invoke } from '@tauri-apps/api/core';
import type { CallHistoryEntry, CallInfo } from '../types';

export interface InitiateCallRequest {
  callee_user_id: string;
  call_type: 'voice' | 'video';
}

export interface CallResponse {
  success: boolean;
  call_id?: string;
  error?: string;
}

export interface ScreenShareOptions {
  audio: boolean;
  cursor: boolean;
}

/**
 * Initiate a voice or video call
 */
export async function initiateCall(request: InitiateCallRequest): Promise<CallResponse> {
  return invoke<CallResponse>('initiate_call', { request });
}

/**
 * Accept an incoming call
 */
export async function acceptCall(callId: string): Promise<CallResponse> {
  return invoke<CallResponse>('accept_call', { callId });
}

/**
 * Reject an incoming call
 */
export async function rejectCall(callId: string, reason?: string): Promise<void> {
  return invoke('reject_call', { callId, reason });
}

/**
 * End an active call
 */
export async function endCall(callId: string): Promise<void> {
  return invoke('end_call', { callId });
}

/**
 * Toggle mute state
 */
export async function toggleMute(callId: string, muted: boolean): Promise<void> {
  return invoke('toggle_mute', { callId, muted });
}

/**
 * Toggle video state
 */
export async function toggleVideo(callId: string, enabled: boolean): Promise<void> {
  return invoke('toggle_video', { callId, enabled });
}

/**
 * Start screen sharing
 */
export async function startScreenShare(callId: string, options?: ScreenShareOptions): Promise<void> {
  return invoke('start_screen_share', {
    callId,
    options: options ?? { audio: false, cursor: true }
  });
}

/**
 * Stop screen sharing
 */
export async function stopScreenShare(callId: string): Promise<void> {
  return invoke('stop_screen_share', { callId });
}

/**
 * Get available screen sources for sharing
 */
export async function getScreenSources(): Promise<ScreenSource[]> {
  return invoke<ScreenSource[]>('get_screen_sources');
}

/**
 * Get current call info
 */
export async function getCallInfo(callId: string): Promise<CallInfo | null> {
  return invoke<CallInfo | null>('get_call_info', { callId });
}

/**
 * Get call history
 */
export async function getCallHistory(limit?: number): Promise<CallHistoryEntry[]> {
  return invoke<CallHistoryEntry[]>('get_call_history', { limit: limit ?? 50 });
}

// Screen source types
export interface ScreenSource {
  id: string;
  name: string;
  thumbnail: string; // Base64 encoded
  source_type: 'screen' | 'window';
}
