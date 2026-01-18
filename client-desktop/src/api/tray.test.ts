/**
 * Tray API Tests
 */

import { invoke } from '@tauri-apps/api/core';
import { listen } from '@tauri-apps/api/event';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
    onTrayMuteToggled,
    onTrayOpenChat,
    onTrayStatusChanged,
    RecentChat,
    setTrayMuted,
    updateTrayBadge,
    updateTrayRecentChats,
} from './tray';

vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}));

vi.mock('@tauri-apps/api/event', () => ({
  listen: vi.fn(),
}));

describe('Tray API', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('updateTrayBadge', () => {
    it('should call invoke with correct parameters', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      await updateTrayBadge(5);

      expect(invoke).toHaveBeenCalledWith('update_tray_badge', { count: 5 });
    });

    it('should handle zero count', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      await updateTrayBadge(0);

      expect(invoke).toHaveBeenCalledWith('update_tray_badge', { count: 0 });
    });
  });

  describe('setTrayMuted', () => {
    it('should call invoke with muted true', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      await setTrayMuted(true);

      expect(invoke).toHaveBeenCalledWith('set_tray_muted', { muted: true });
    });

    it('should call invoke with muted false', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      await setTrayMuted(false);

      expect(invoke).toHaveBeenCalledWith('set_tray_muted', { muted: false });
    });
  });

  describe('updateTrayRecentChats', () => {
    it('should call invoke with recent chats', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      const chats: RecentChat[] = [
        { conversationId: '1', displayName: 'Alice', hasUnread: true },
        { conversationId: '2', displayName: 'Bob', hasUnread: false },
      ];

      await updateTrayRecentChats(chats);

      expect(invoke).toHaveBeenCalledWith('update_tray_recent_chats', { chats });
    });

    it('should handle empty chats array', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      await updateTrayRecentChats([]);

      expect(invoke).toHaveBeenCalledWith('update_tray_recent_chats', { chats: [] });
    });
  });

  describe('Event Listeners', () => {
    it('should setup mute toggle listener', async () => {
      const unlistenMock = vi.fn();
      vi.mocked(listen).mockResolvedValue(unlistenMock);

      const callback = vi.fn();
      const unlisten = await onTrayMuteToggled(callback);

      expect(listen).toHaveBeenCalledWith('tray:mute-toggled', callback);
      expect(unlisten).toBe(unlistenMock);
    });

    it('should setup status changed listener', async () => {
      const unlistenMock = vi.fn();
      vi.mocked(listen).mockResolvedValue(unlistenMock);

      const callback = vi.fn();
      await onTrayStatusChanged(callback);

      expect(listen).toHaveBeenCalledWith('tray:status-changed', expect.any(Function));
    });

    it('should setup open chat listener', async () => {
      const unlistenMock = vi.fn();
      vi.mocked(listen).mockResolvedValue(unlistenMock);

      const callback = vi.fn();
      await onTrayOpenChat(callback);

      expect(listen).toHaveBeenCalledWith('tray:open-chat', expect.any(Function));
    });
  });
});
