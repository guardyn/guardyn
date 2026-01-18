/**
 * useTray Hook
 * 
 * SolidJS hook for integrating with system tray functionality.
 */

import { createSignal, onCleanup, onMount } from 'solid-js';
import {
    onTrayMuteToggled,
    onTrayOpenChat,
    onTrayStatusChanged,
    RecentChat,
    setTrayMuted as setTrayMutedApi,
    updateTrayBadge,
    updateTrayRecentChats,
} from '../api/tray';

export type UserStatus = 'online' | 'away' | 'busy' | 'invisible';

export interface UseTrayOptions {
  /** Called when mute is toggled from tray */
  onMuteToggle?: () => void;
  /** Called when status is changed from tray */
  onStatusChange?: (status: UserStatus) => void;
  /** Called when a chat is opened from tray */
  onOpenChat?: (conversationId: string) => void;
}

export interface UseTrayReturn {
  /** Current mute status */
  isMuted: () => boolean;
  /** Toggle mute status */
  toggleMute: () => void;
  /** Set mute status */
  setMuted: (muted: boolean) => void;
  /** Current user status */
  status: () => UserStatus;
  /** Set user status */
  setStatus: (status: UserStatus) => void;
  /** Update unread badge count */
  updateBadge: (count: number) => void;
  /** Update recent chats in tray menu */
  updateRecentChats: (chats: RecentChat[]) => void;
}

export function useTray(options: UseTrayOptions = {}): UseTrayReturn {
  const [isMuted, setIsMuted] = createSignal(false);
  const [status, setStatusSignal] = createSignal<UserStatus>('online');

  onMount(async () => {
    // Setup event listeners
    const unlistenMute = await onTrayMuteToggled(() => {
      setIsMuted((prev) => !prev);
      setTrayMutedApi(!isMuted());
      options.onMuteToggle?.();
    });

    const unlistenStatus = await onTrayStatusChanged((newStatus) => {
      const validStatus = newStatus as UserStatus;
      setStatusSignal(validStatus);
      options.onStatusChange?.(validStatus);
    });

    const unlistenOpenChat = await onTrayOpenChat((conversationId) => {
      options.onOpenChat?.(conversationId);
    });

    onCleanup(() => {
      unlistenMute();
      unlistenStatus();
      unlistenOpenChat();
    });
  });

  const toggleMute = () => {
    const newMuted = !isMuted();
    setIsMuted(newMuted);
    setTrayMutedApi(newMuted);
    options.onMuteToggle?.();
  };

  const setMuted = (muted: boolean) => {
    setIsMuted(muted);
    setTrayMutedApi(muted);
  };

  const setStatus = (newStatus: UserStatus) => {
    setStatusSignal(newStatus);
  };

  const updateBadge = (count: number) => {
    updateTrayBadge(count).catch(console.error);
  };

  const updateChats = (chats: RecentChat[]) => {
    updateTrayRecentChats(chats).catch(console.error);
  };

  return {
    isMuted,
    toggleMute,
    setMuted,
    status,
    setStatus,
    updateBadge,
    updateRecentChats: updateChats,
  };
}
