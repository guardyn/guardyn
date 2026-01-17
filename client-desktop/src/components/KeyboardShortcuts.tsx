/**
 * Keyboard Shortcuts Display Component
 *
 * Shows all available keyboard shortcuts in a modal dialog.
 * Accessible via Settings or Cmd/Ctrl+? shortcut.
 */

import { Component, createSignal, For, Show } from 'solid-js';

/**
 * Shortcut category definition
 */
interface ShortcutCategory {
  name: string;
  shortcuts: Shortcut[];
}

interface Shortcut {
  keys: string[];
  description: string;
  available?: boolean;
}

/**
 * All available keyboard shortcuts
 */
const shortcutCategories: ShortcutCategory[] = [
  {
    name: 'Navigation',
    shortcuts: [
      { keys: ['Ctrl/Cmd', 'K'], description: 'Open quick search / command palette' },
      { keys: ['Ctrl/Cmd', '1'], description: 'Go to Chats' },
      { keys: ['Ctrl/Cmd', '2'], description: 'Go to Calls' },
      { keys: ['Ctrl/Cmd', '3'], description: 'Go to Contacts' },
      { keys: ['Ctrl/Cmd', ','], description: 'Open Settings' },
      { keys: ['Escape'], description: 'Close modal / Go back' },
    ],
  },
  {
    name: 'Chat',
    shortcuts: [
      { keys: ['Ctrl/Cmd', 'N'], description: 'New message / conversation' },
      { keys: ['Ctrl/Cmd', 'Shift', 'F'], description: 'Search in conversation' },
      { keys: ['Ctrl/Cmd', 'Enter'], description: 'Send message' },
      { keys: ['Up'], description: 'Edit last message (when input empty)' },
      { keys: ['Ctrl/Cmd', 'Shift', 'E'], description: 'Insert emoji picker' },
    ],
  },
  {
    name: 'Calls',
    shortcuts: [
      { keys: ['Ctrl/Cmd', 'Shift', 'A'], description: 'Answer incoming call' },
      { keys: ['Ctrl/Cmd', 'Shift', 'D'], description: 'Decline incoming call' },
      { keys: ['M'], description: 'Toggle mute (during call)' },
      { keys: ['V'], description: 'Toggle video (during call)' },
      { keys: ['Ctrl/Cmd', 'Shift', 'H'], description: 'Hang up call' },
    ],
  },
  {
    name: 'General',
    shortcuts: [
      { keys: ['Ctrl/Cmd', '?'], description: 'Show keyboard shortcuts' },
      { keys: ['Ctrl/Cmd', 'L'], description: 'Lock app' },
      { keys: ['Ctrl/Cmd', 'Shift', 'D'], description: 'Toggle dark mode' },
      { keys: ['Ctrl/Cmd', 'Q'], description: 'Quit application' },
    ],
  },
];

/**
 * Signal for modal visibility
 */
const [showShortcutsModal, setShowShortcutsModal] = createSignal(false);

/**
 * Open shortcuts modal
 */
export function openShortcutsModal() {
  setShowShortcutsModal(true);
}

/**
 * Close shortcuts modal
 */
export function closeShortcutsModal() {
  setShowShortcutsModal(false);
}

/**
 * Key display component
 */
interface KeyBadgeProps {
  key: string;
}

const KeyBadge: Component<KeyBadgeProps> = (props) => {
  // Determine if we're on macOS
  const isMac = navigator.platform.toUpperCase().indexOf('MAC') >= 0;

  // Replace Ctrl/Cmd with platform-specific key
  const displayKey = () => {
    const key = props.key;
    if (key === 'Ctrl/Cmd') {
      return isMac ? '⌘' : 'Ctrl';
    }
    if (key === 'Shift') {
      return isMac ? '⇧' : 'Shift';
    }
    if (key === 'Alt') {
      return isMac ? '⌥' : 'Alt';
    }
    if (key === 'Escape') {
      return 'Esc';
    }
    if (key === 'Enter') {
      return '↵';
    }
    return key;
  };

  return (
    <kbd class="inline-flex items-center justify-center min-w-[28px] h-7 px-2 bg-gray-700 border border-gray-600 rounded text-sm font-mono text-gray-200 shadow-sm">
      {displayKey()}
    </kbd>
  );
};

/**
 * Shortcut row component
 */
interface ShortcutRowProps {
  shortcut: Shortcut;
}

const ShortcutRow: Component<ShortcutRowProps> = (props) => {
  return (
    <div class="flex items-center justify-between py-2">
      <span class="text-gray-300">{props.shortcut.description}</span>
      <div class="flex items-center gap-1">
        <For each={props.shortcut.keys}>
          {(key, index) => (
            <>
              <KeyBadge key={key} />
              <Show when={index() < props.shortcut.keys.length - 1}>
                <span class="text-gray-500 text-sm">+</span>
              </Show>
            </>
          )}
        </For>
      </div>
    </div>
  );
};

/**
 * Shortcuts modal component
 */
export const ShortcutsModal: Component = () => {
  const handleBackdropClick = (e: MouseEvent) => {
    if (e.target === e.currentTarget) {
      closeShortcutsModal();
    }
  };

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      closeShortcutsModal();
    }
  };

  return (
    <Show when={showShortcutsModal()}>
      <div
        class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm"
        onClick={handleBackdropClick}
        onKeyDown={handleKeyDown}
        role="dialog"
        aria-modal="true"
        aria-labelledby="shortcuts-title"
      >
        <div
          class="bg-gray-800 rounded-xl shadow-2xl w-full max-w-2xl max-h-[80vh] overflow-hidden flex flex-col"
          tabindex="-1"
        >
          {/* Header */}
          <div class="flex items-center justify-between px-6 py-4 border-b border-gray-700">
            <h2 id="shortcuts-title" class="text-xl font-semibold text-white">
              Keyboard Shortcuts
            </h2>
            <button
              onClick={closeShortcutsModal}
              class="p-2 text-gray-400 hover:text-white hover:bg-gray-700 rounded-lg transition-colors"
              aria-label="Close"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>

          {/* Content */}
          <div class="flex-1 overflow-y-auto px-6 py-4">
            <For each={shortcutCategories}>
              {(category) => (
                <div class="mb-6 last:mb-0">
                  <h3 class="text-sm font-semibold text-guardyn-400 uppercase tracking-wide mb-3">
                    {category.name}
                  </h3>
                  <div class="divide-y divide-gray-700/50">
                    <For each={category.shortcuts}>
                      {(shortcut) => <ShortcutRow shortcut={shortcut} />}
                    </For>
                  </div>
                </div>
              )}
            </For>
          </div>

          {/* Footer */}
          <div class="px-6 py-3 border-t border-gray-700 bg-gray-800/50">
            <p class="text-xs text-gray-500 text-center">
              Press <KeyBadge key="Escape" /> to close
            </p>
          </div>
        </div>
      </div>
    </Show>
  );
};

/**
 * Inline shortcuts help indicator
 */
interface ShortcutHintProps {
  keys: string[];
  class?: string;
}

export const ShortcutHint: Component<ShortcutHintProps> = (props) => {
  return (
    <div class={`flex items-center gap-0.5 ${props.class || ''}`}>
      <For each={props.keys}>
        {(key, index) => (
          <>
            <kbd class="inline-flex items-center justify-center min-w-[20px] h-5 px-1.5 bg-gray-700/50 border border-gray-600/50 rounded text-xs font-mono text-gray-400">
              {key}
            </kbd>
            <Show when={index() < props.keys.length - 1}>
              <span class="text-gray-600 text-xs">+</span>
            </Show>
          </>
        )}
      </For>
    </div>
  );
};

export default ShortcutsModal;
