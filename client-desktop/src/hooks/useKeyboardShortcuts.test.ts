import { describe, expect, it, vi } from 'vitest';
import { formatShortcut, getAllShortcuts, type Shortcut } from './useKeyboardShortcuts';

describe('useKeyboardShortcuts', () => {
  describe('formatShortcut', () => {
    it('formats simple key shortcut', () => {
      const shortcut: Shortcut = {
        key: 'Escape',
        description: 'Close',
        action: vi.fn(),
      };

      const result = formatShortcut(shortcut);
      expect(result).toBe('ESCAPE');
    });

    it('formats Ctrl+key shortcut (non-Mac)', () => {
      // Mock non-Mac platform
      Object.defineProperty(navigator, 'platform', {
        value: 'Win32',
        writable: true,
      });

      const shortcut: Shortcut = {
        key: 'n',
        ctrl: true,
        description: 'New',
        action: vi.fn(),
      };

      const result = formatShortcut(shortcut);
      expect(result).toBe('Ctrl+N');
    });

    it('formats multiple modifier shortcut', () => {
      Object.defineProperty(navigator, 'platform', {
        value: 'Win32',
        writable: true,
      });

      const shortcut: Shortcut = {
        key: 's',
        ctrl: true,
        shift: true,
        description: 'Save as',
        action: vi.fn(),
      };

      const result = formatShortcut(shortcut);
      expect(result).toBe('Ctrl+Shift+S');
    });
  });

  describe('getAllShortcuts', () => {
    it('returns list of shortcuts', () => {
      const shortcuts = getAllShortcuts();

      expect(shortcuts).toBeInstanceOf(Array);
      expect(shortcuts.length).toBeGreaterThan(0);
    });

    it('includes navigation shortcuts', () => {
      const shortcuts = getAllShortcuts();

      const chatShortcut = shortcuts.find((s) => s.key === '1' && s.ctrl);
      const callsShortcut = shortcuts.find((s) => s.key === '2' && s.ctrl);
      const settingsShortcut = shortcuts.find((s) => s.key === '3' && s.ctrl);

      expect(chatShortcut).toBeDefined();
      expect(callsShortcut).toBeDefined();
      expect(settingsShortcut).toBeDefined();
    });

    it('includes search shortcut', () => {
      const shortcuts = getAllShortcuts();

      const searchShortcut = shortcuts.find((s) => s.key === 'k' && s.ctrl);
      expect(searchShortcut).toBeDefined();
      expect(searchShortcut?.description).toContain('Search');
    });

    it('includes escape shortcut', () => {
      const shortcuts = getAllShortcuts();

      const escapeShortcut = shortcuts.find((s) => s.key === 'Escape');
      expect(escapeShortcut).toBeDefined();
    });
  });

  describe('Shortcut interface', () => {
    it('supports all modifier keys', () => {
      const shortcut: Shortcut = {
        key: 'a',
        ctrl: true,
        alt: true,
        shift: true,
        meta: true,
        description: 'All modifiers',
        action: vi.fn(),
      };

      expect(shortcut.ctrl).toBe(true);
      expect(shortcut.alt).toBe(true);
      expect(shortcut.shift).toBe(true);
      expect(shortcut.meta).toBe(true);
    });
  });
});
