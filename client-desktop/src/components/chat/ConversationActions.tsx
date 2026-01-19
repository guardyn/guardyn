/**
 * Conversation Actions Menu
 * 
 * Dropdown menu for conversation actions like archive, mute, delete.
 * 
 * @module components/chat/ConversationActions
 */

import { Component, createSignal, Show, onMount, onCleanup } from 'solid-js';

// =============================================================================
// TYPES
// =============================================================================

export interface ConversationActionsProps {
  conversationId: string;
  conversationName: string;
  isMuted: boolean;
  isArchived: boolean;
  isPinned: boolean;
  onMute: (conversationId: string, muted: boolean) => void;
  onArchive: (conversationId: string) => void;
  onPin: (conversationId: string, pinned: boolean) => void;
  onDelete: (conversationId: string) => void;
  onBlock: (conversationId: string) => void;
}

// =============================================================================
// COMPONENT
// =============================================================================

export const ConversationActions: Component<ConversationActionsProps> = (props) => {
  const [isOpen, setIsOpen] = createSignal(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = createSignal(false);
  let menuRef: HTMLDivElement | undefined;

  // Close menu on click outside
  onMount(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (menuRef && !menuRef.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    onCleanup(() => document.removeEventListener('mousedown', handleClickOutside));
  });

  const handleMute = () => {
    props.onMute(props.conversationId, !props.isMuted);
    setIsOpen(false);
  };

  const handleArchive = () => {
    props.onArchive(props.conversationId);
    setIsOpen(false);
  };

  const handlePin = () => {
    props.onPin(props.conversationId, !props.isPinned);
    setIsOpen(false);
  };

  const handleDeleteClick = () => {
    setShowDeleteConfirm(true);
  };

  const handleDeleteConfirm = () => {
    props.onDelete(props.conversationId);
    setShowDeleteConfirm(false);
    setIsOpen(false);
  };

  const handleBlock = () => {
    props.onBlock(props.conversationId);
    setIsOpen(false);
  };

  return (
    <div class="relative" ref={menuRef}>
      {/* Trigger Button */}
      <button
        onClick={() => setIsOpen(!isOpen())}
        class="p-2 rounded-full hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
        aria-label="Conversation actions"
        aria-expanded={isOpen()}
      >
        <svg class="w-5 h-5 text-gray-500" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10 6a2 2 0 110-4 2 2 0 010 4zM10 12a2 2 0 110-4 2 2 0 010 4zM10 18a2 2 0 110-4 2 2 0 010 4z" />
        </svg>
      </button>

      {/* Dropdown Menu */}
      <Show when={isOpen()}>
        <div 
          class="absolute right-0 top-full mt-1 w-48 rounded-lg bg-white dark:bg-gray-800 
                 shadow-lg border border-gray-200 dark:border-gray-700 py-1 z-50"
          style={{ 'animation': 'fadeIn 0.15s ease-out' }}
        >
          {/* Pin/Unpin */}
          <button
            onClick={handlePin}
            class="w-full flex items-center gap-3 px-4 py-2 text-left text-sm
                   text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M5 5a2 2 0 012-2h10a2 2 0 012 2v16l-7-3.5L5 21V5z" />
            </svg>
            {props.isPinned ? 'Unpin' : 'Pin to top'}
          </button>

          {/* Mute/Unmute */}
          <button
            onClick={handleMute}
            class="w-full flex items-center gap-3 px-4 py-2 text-left text-sm
                   text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <Show 
              when={props.isMuted}
              fallback={
                <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                        d="M17 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2" />
                </svg>
              }
            >
              <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                      d="M15.536 8.464a5 5 0 010 7.072m2.828-9.9a9 9 0 010 12.728M5.586 15H4a1 1 0 01-1-1v-4a1 1 0 011-1h1.586l4.707-4.707C10.923 3.663 12 4.109 12 5v14c0 .891-1.077 1.337-1.707.707L5.586 15z" />
              </svg>
            </Show>
            {props.isMuted ? 'Unmute' : 'Mute'}
          </button>

          {/* Archive */}
          <button
            onClick={handleArchive}
            class="w-full flex items-center gap-3 px-4 py-2 text-left text-sm
                   text-gray-700 dark:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M5 8h14M5 8a2 2 0 110-4h14a2 2 0 110 4M5 8v10a2 2 0 002 2h10a2 2 0 002-2V8m-9 4h4" />
            </svg>
            {props.isArchived ? 'Unarchive' : 'Archive'}
          </button>

          {/* Divider */}
          <div class="my-1 border-t border-gray-200 dark:border-gray-700" />

          {/* Block */}
          <button
            onClick={handleBlock}
            class="w-full flex items-center gap-3 px-4 py-2 text-left text-sm
                   text-orange-600 dark:text-orange-400 hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M18.364 18.364A9 9 0 005.636 5.636m12.728 12.728A9 9 0 015.636 5.636m12.728 12.728L5.636 5.636" />
            </svg>
            Block user
          </button>

          {/* Delete */}
          <button
            onClick={handleDeleteClick}
            class="w-full flex items-center gap-3 px-4 py-2 text-left text-sm
                   text-red-600 dark:text-red-400 hover:bg-gray-100 dark:hover:bg-gray-700"
          >
            <svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" 
                    d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
            </svg>
            Delete
          </button>
        </div>
      </Show>

      {/* Delete Confirmation Dialog */}
      <Show when={showDeleteConfirm()}>
        <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
          <div class="w-full max-w-sm rounded-xl bg-white dark:bg-gray-800 shadow-2xl p-6">
            <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-2">
              Delete Conversation
            </h3>
            <p class="text-gray-600 dark:text-gray-400 mb-6">
              Are you sure you want to delete your conversation with{' '}
              <span class="font-medium">{props.conversationName}</span>? 
              This action cannot be undone.
            </p>
            <div class="flex justify-end gap-3">
              <button
                onClick={() => setShowDeleteConfirm(false)}
                class="px-4 py-2 rounded-lg text-gray-700 dark:text-gray-300
                       hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleDeleteConfirm}
                class="px-4 py-2 rounded-lg bg-red-500 text-white font-medium
                       hover:bg-red-600 transition-colors"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      </Show>
    </div>
  );
};

export default ConversationActions;
