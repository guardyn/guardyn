/**
 * Tray API
 * 
 * Provides functions for interacting with the system tray from the frontend.
 */

import { invoke } from '@tauri-apps/api/core';
import { listen, UnlistenFn } from '@tauri-apps/api/event';

export interface RecentChat {
  conversationId: string;
  displayName: string;
  hasUnread: boolean;
}

/**
 * Update the tray badge with unread message count
 */
export async function updateTrayBadge(count: number): Promise<void> {
  await invoke('update_tray_badge', { count });
}

/**
 * Set the global mute status in tray
 */
export async function setTrayMuted(muted: boolean): Promise<void> {
  await invoke('set_tray_muted', { muted });
}

/**
 * Update the recent chats list in tray menu
 */
export async function updateTrayRecentChats(chats: RecentChat[]): Promise<void> {
  await invoke('update_tray_recent_chats', { chats });
}

/**
 * Listen for tray mute toggle events
 */
export function onTrayMuteToggled(callback: () => void): Promise<UnlistenFn> {
  return listen('tray:mute-toggled', callback);
}

/**
 * Listen for tray status change events
 */
export function onTrayStatusChanged(callback: (status: string) => void): Promise<UnlistenFn> {
  return listen<string>('tray:status-changed', (event) => callback(event.payload));
}

/**
 * Listen for tray chat open requests
 */
export function onTrayOpenChat(callback: (conversationId: string) => void): Promise<UnlistenFn> {
  return listen<string>('tray:open-chat', (event) => callback(event.payload));
}
