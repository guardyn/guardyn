/**
 * Settings API Integration Tests
 *
 * Tests for the settings API module with mocked Tauri invoke.
 */

import { beforeEach, describe, expect, it, vi } from 'vitest';
import type { Settings } from '../types';
import {
    exportSettings,
    getSettings,
    importSettings,
    resetSettings,
    updateSettings,
} from './settings';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

describe('Settings API', () => {
  beforeEach(() => {
    mockInvoke.mockClear();
  });

  const mockSettings: Settings = {
    theme: 'dark',
    language: 'en',
    notifications_enabled: true,
    sound_enabled: true,
    show_message_preview: true,
    auto_answer_calls: false,
    video_quality: 'high',
    read_receipts_enabled: true,
    typing_indicators_enabled: true,
    start_minimized: false,
    minimize_to_tray: true,
    launch_at_startup: false,
  };

  describe('getSettings', () => {
    it('returns current settings', async () => {
      mockInvoke.mockResolvedValueOnce(mockSettings);

      const settings = await getSettings();

      expect(mockInvoke).toHaveBeenCalledWith('get_settings');
      expect(settings.theme).toBe('dark');
      expect(settings.language).toBe('en');
      expect(settings.notifications_enabled).toBe(true);
    });

    it('returns privacy-related settings', async () => {
      mockInvoke.mockResolvedValueOnce(mockSettings);

      const settings = await getSettings();

      expect(settings.read_receipts_enabled).toBe(true);
      expect(settings.typing_indicators_enabled).toBe(true);
    });

    it('returns desktop-specific settings', async () => {
      mockInvoke.mockResolvedValueOnce(mockSettings);

      const settings = await getSettings();

      expect(settings.minimize_to_tray).toBe(true);
      expect(settings.start_minimized).toBe(false);
    });
  });

  describe('updateSettings', () => {
    it('updates theme setting', async () => {
      const updatedSettings = { ...mockSettings, theme: 'light' as const };
      mockInvoke.mockResolvedValueOnce(updatedSettings);

      const result = await updateSettings({ theme: 'light' });

      expect(mockInvoke).toHaveBeenCalledWith('update_settings', {
        settings: { theme: 'light' },
      });
      expect(result.theme).toBe('light');
    });

    it('updates language setting', async () => {
      const updatedSettings = { ...mockSettings, language: 'ru' };
      mockInvoke.mockResolvedValueOnce(updatedSettings);

      const result = await updateSettings({ language: 'ru' });

      expect(mockInvoke).toHaveBeenCalledWith('update_settings', {
        settings: { language: 'ru' },
      });
      expect(result.language).toBe('ru');
    });

    it('updates multiple settings at once', async () => {
      const updates = {
        theme: 'light' as const,
        notifications_enabled: false,
        sound_enabled: false,
      };
      const updatedSettings = { ...mockSettings, ...updates };
      mockInvoke.mockResolvedValueOnce(updatedSettings);

      const result = await updateSettings(updates);

      expect(mockInvoke).toHaveBeenCalledWith('update_settings', {
        settings: updates,
      });
      expect(result.theme).toBe('light');
      expect(result.notifications_enabled).toBe(false);
    });

    it('updates privacy settings', async () => {
      const privacyUpdate = {
        read_receipts_enabled: false,
        typing_indicators_enabled: false,
      };
      const updatedSettings = {
        ...mockSettings,
        ...privacyUpdate,
      };
      mockInvoke.mockResolvedValueOnce(updatedSettings);

      const result = await updateSettings(privacyUpdate);

      expect(result.read_receipts_enabled).toBe(false);
    });

    it('handles empty update', async () => {
      mockInvoke.mockResolvedValueOnce(mockSettings);

      await updateSettings({});

      expect(mockInvoke).toHaveBeenCalledWith('update_settings', {
        settings: {},
      });
    });
  });

  describe('resetSettings', () => {
    it('resets settings to defaults', async () => {
      const defaultSettings: Settings = {
        theme: 'system',
        language: 'en',
        notifications_enabled: true,
        sound_enabled: true,
        show_message_preview: true,
        auto_answer_calls: false,
        video_quality: 'medium',
        read_receipts_enabled: true,
        typing_indicators_enabled: true,
        start_minimized: false,
        minimize_to_tray: false,
        launch_at_startup: false,
      };
      mockInvoke.mockResolvedValueOnce(defaultSettings);

      const result = await resetSettings();

      expect(mockInvoke).toHaveBeenCalledWith('reset_settings');
      expect(result.theme).toBe('system');
      expect(result.video_quality).toBe('medium');
    });
  });

  describe('exportSettings', () => {
    it('exports settings to specified path', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await exportSettings('/path/to/settings.json');

      expect(mockInvoke).toHaveBeenCalledWith('export_settings', {
        path: '/path/to/settings.json',
      });
    });

    it('handles export error', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Permission denied'));

      await expect(exportSettings('/protected/path')).rejects.toThrow(
        'Permission denied'
      );
    });
  });

  describe('importSettings', () => {
    it('imports settings from file', async () => {
      mockInvoke.mockResolvedValueOnce(mockSettings);

      const result = await importSettings('/path/to/settings.json');

      expect(mockInvoke).toHaveBeenCalledWith('import_settings', {
        path: '/path/to/settings.json',
      });
      expect(result.theme).toBe('dark');
    });

    it('handles invalid file', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Invalid settings file'));

      await expect(importSettings('/path/to/invalid.json')).rejects.toThrow(
        'Invalid settings file'
      );
    });

    it('handles file not found', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('File not found'));

      await expect(importSettings('/nonexistent/path')).rejects.toThrow(
        'File not found'
      );
    });
  });
});
