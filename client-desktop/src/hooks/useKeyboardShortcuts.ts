/**
 * Keyboard Shortcuts Hook
 *
 * Provides global keyboard shortcuts for the desktop app.
 * Uses standard patterns: Ctrl/Cmd+Key for actions.
 */

import { useNavigate } from '@solidjs/router';
import { onCleanup, onMount } from 'solid-js';

export interface Shortcut {
  key: string;
  ctrl?: boolean;
  alt?: boolean;
  shift?: boolean;
  meta?: boolean;
  description: string;
  action: () => void;
}

/**
 * Hook to register global keyboard shortcuts
 */
export function useKeyboardShortcuts(shortcuts: Shortcut[]) {
  const handleKeydown = (event: KeyboardEvent) => {
    for (const shortcut of shortcuts) {
      const keyMatches = event.key.toLowerCase() === shortcut.key.toLowerCase();
      const ctrlMatches = (shortcut.ctrl ?? false) === (event.ctrlKey || event.metaKey);
      const altMatches = (shortcut.alt ?? false) === event.altKey;
      const shiftMatches = (shortcut.shift ?? false) === event.shiftKey;

      if (keyMatches && ctrlMatches && altMatches && shiftMatches) {
        event.preventDefault();
        shortcut.action();
        return;
      }
    }
  };

  onMount(() => {
    window.addEventListener('keydown', handleKeydown);
  });

  onCleanup(() => {
    window.removeEventListener('keydown', handleKeydown);
  });
}

/**
 * Default app-wide shortcuts
 */
export function useAppShortcuts() {
  const navigate = useNavigate();

  const shortcuts: Shortcut[] = [
    {
      key: 'n',
      ctrl: true,
      description: 'New conversation',
      action: () => {
        // TODO: Open new conversation modal
        console.log('New conversation shortcut');
      },
    },
    {
      key: 'k',
      ctrl: true,
      description: 'Search messages',
      action: () => {
        // TODO: Focus search input
        console.log('Search shortcut');
      },
    },
    {
      key: '1',
      ctrl: true,
      description: 'Go to Chats',
      action: () => navigate('/chat'),
    },
    {
      key: '2',
      ctrl: true,
      description: 'Go to Calls',
      action: () => navigate('/calls'),
    },
    {
      key: '3',
      ctrl: true,
      description: 'Go to Settings',
      action: () => navigate('/settings'),
    },
    {
      key: ',',
      ctrl: true,
      description: 'Open Settings',
      action: () => navigate('/settings'),
    },
    {
      key: 'Escape',
      description: 'Close modal / Go back',
      action: () => {
        // TODO: Close any open modal
        console.log('Escape pressed');
      },
    },
  ];

  useKeyboardShortcuts(shortcuts);

  return shortcuts;
}

/**
 * Get shortcut display string (e.g., "Ctrl+N" or "⌘N")
 */
export function formatShortcut(shortcut: Shortcut): string {
  const parts: string[] = [];

  // Use Mac-style symbols when on macOS
  const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0;

  if (shortcut.ctrl) {
    parts.push(isMac ? '⌘' : 'Ctrl');
  }
  if (shortcut.alt) {
    parts.push(isMac ? '⌥' : 'Alt');
  }
  if (shortcut.shift) {
    parts.push(isMac ? '⇧' : 'Shift');
  }

  parts.push(shortcut.key.toUpperCase());

  return isMac ? parts.join('') : parts.join('+');
}

/**
 * Get all available shortcuts for help display
 */
export function getAllShortcuts(): Shortcut[] {
  return [
    { key: 'n', ctrl: true, description: 'New conversation', action: () => {} },
    { key: 'k', ctrl: true, description: 'Search messages', action: () => {} },
    { key: '1', ctrl: true, description: 'Go to Chats', action: () => {} },
    { key: '2', ctrl: true, description: 'Go to Calls', action: () => {} },
    { key: '3', ctrl: true, description: 'Go to Settings', action: () => {} },
    { key: ',', ctrl: true, description: 'Open Settings', action: () => {} },
    { key: 'Escape', description: 'Close modal / Go back', action: () => {} },
    { key: 'Enter', ctrl: true, description: 'Send message', action: () => {} },
  ];
}
