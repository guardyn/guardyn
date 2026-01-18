/**
 * Window State API Tests
 */

import { invoke } from '@tauri-apps/api/core';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { getWindowState, saveWindowState, WindowState } from './window';

vi.mock('@tauri-apps/api/core', () => ({
  invoke: vi.fn(),
}));

describe('Window State API', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('saveWindowState', () => {
    it('should call invoke to save window state', async () => {
      vi.mocked(invoke).mockResolvedValue(undefined);

      await saveWindowState();

      expect(invoke).toHaveBeenCalledWith('save_window_state');
    });

    it('should propagate errors', async () => {
      const error = new Error('Failed to save');
      vi.mocked(invoke).mockRejectedValue(error);

      await expect(saveWindowState()).rejects.toThrow('Failed to save');
    });
  });

  describe('getWindowState', () => {
    it('should return window state from invoke', async () => {
      const mockState: WindowState = {
        x: 100,
        y: 200,
        width: 1200,
        height: 800,
        maximized: false,
        fullscreen: false,
      };

      vi.mocked(invoke).mockResolvedValue(mockState);

      const result = await getWindowState();

      expect(invoke).toHaveBeenCalledWith('get_window_state');
      expect(result).toEqual(mockState);
    });

    it('should handle maximized state', async () => {
      const mockState: WindowState = {
        maximized: true,
        fullscreen: false,
      };

      vi.mocked(invoke).mockResolvedValue(mockState);

      const result = await getWindowState();

      expect(result.maximized).toBe(true);
    });

    it('should handle fullscreen state', async () => {
      const mockState: WindowState = {
        maximized: false,
        fullscreen: true,
      };

      vi.mocked(invoke).mockResolvedValue(mockState);

      const result = await getWindowState();

      expect(result.fullscreen).toBe(true);
    });
  });
});
