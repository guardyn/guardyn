import { Component, createSignal, For, Show } from 'solid-js';

interface Conversation {
  id: string;
  name: string;
  avatarUrl?: string;
  lastMessage?: string;
}

interface ForwardModalProps {
  isOpen: boolean;
  messageContent: string;
  messageId: string;
  conversations: Conversation[];
  onForward: (conversationIds: string[], messageId: string) => void;
  onClose: () => void;
}

/**
 * ForwardModal - Modal for forwarding messages to other conversations
 * 
 * Features:
 * - Search/filter conversations
 * - Multi-select conversations
 * - Message preview
 * - Confirm/cancel actions
 */
export const ForwardModal: Component<ForwardModalProps> = (props) => {
  const [searchQuery, setSearchQuery] = createSignal('');
  const [selectedConversations, setSelectedConversations] = createSignal<string[]>([]);
  
  // Filter conversations based on search
  const filteredConversations = () => {
    const query = searchQuery().toLowerCase();
    if (!query) return props.conversations;
    return props.conversations.filter(conv => 
      conv.name.toLowerCase().includes(query)
    );
  };
  
  // Toggle conversation selection
  const toggleConversation = (id: string) => {
    setSelectedConversations(prev => {
      if (prev.includes(id)) {
        return prev.filter(cId => cId !== id);
      }
      return [...prev, id];
    });
  };
  
  // Check if conversation is selected
  const isSelected = (id: string) => selectedConversations().includes(id);
  
  // Handle forward action
  const handleForward = () => {
    if (selectedConversations().length === 0) return;
    props.onForward(selectedConversations(), props.messageId);
    setSelectedConversations([]);
    setSearchQuery('');
    props.onClose();
  };
  
  // Handle close
  const handleClose = () => {
    setSelectedConversations([]);
    setSearchQuery('');
    props.onClose();
  };
  
  // Get initials from name
  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map(n => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };
  
  return (
    <Show when={props.isOpen}>
      {/* Backdrop */}
      <div 
        class="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center"
        onClick={handleClose}
      >
        {/* Modal */}
        <div 
          class="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl w-full max-w-md mx-4 overflow-hidden"
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
            <div class="flex items-center justify-between">
              <h2 class="text-lg font-semibold text-gray-900 dark:text-white">
                Forward Message
              </h2>
              <button
                onClick={handleClose}
                class="p-1 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
                aria-label="Close"
              >
                <svg class="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
              </button>
            </div>
            
            {/* Message preview */}
            <div class="mt-3 p-3 bg-gray-100 dark:bg-gray-700/50 rounded-lg">
              <p class="text-sm text-gray-600 dark:text-gray-300 line-clamp-2">
                {props.messageContent}
              </p>
            </div>
          </div>
          
          {/* Search */}
          <div class="px-6 py-3 border-b border-gray-200 dark:border-gray-700">
            <div class="relative">
              <svg 
                class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
              <input
                type="text"
                value={searchQuery()}
                onInput={(e) => setSearchQuery(e.currentTarget.value)}
                placeholder="Search conversations..."
                class="w-full pl-10 pr-4 py-2 bg-gray-100 dark:bg-gray-700 border-0 rounded-lg text-gray-900 dark:text-white placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-guardyn-500"
              />
            </div>
          </div>
          
          {/* Conversation list */}
          <div class="max-h-64 overflow-y-auto">
            <For each={filteredConversations()}>
              {(conversation) => (
                <button
                  onClick={() => toggleConversation(conversation.id)}
                  class={`w-full px-6 py-3 flex items-center gap-3 hover:bg-gray-50 dark:hover:bg-gray-700/50 transition-colors ${
                    isSelected(conversation.id) ? 'bg-guardyn-50 dark:bg-guardyn-900/30' : ''
                  }`}
                >
                  {/* Checkbox */}
                  <div class={`w-5 h-5 rounded-full border-2 flex items-center justify-center transition-colors ${
                    isSelected(conversation.id) 
                      ? 'bg-guardyn-600 border-guardyn-600' 
                      : 'border-gray-300 dark:border-gray-600'
                  }`}>
                    <Show when={isSelected(conversation.id)}>
                      <svg class="w-3 h-3 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
                      </svg>
                    </Show>
                  </div>
                  
                  {/* Avatar */}
                  <div class="w-10 h-10 rounded-full bg-guardyn-600 flex items-center justify-center overflow-hidden">
                    <Show 
                      when={conversation.avatarUrl}
                      fallback={
                        <span class="text-white text-sm font-medium">
                          {getInitials(conversation.name)}
                        </span>
                      }
                    >
                      <img 
                        src={conversation.avatarUrl} 
                        alt={conversation.name}
                        class="w-full h-full object-cover"
                      />
                    </Show>
                  </div>
                  
                  {/* Name */}
                  <div class="flex-1 text-left">
                    <p class="font-medium text-gray-900 dark:text-white">
                      {conversation.name}
                    </p>
                    <Show when={conversation.lastMessage}>
                      <p class="text-sm text-gray-500 dark:text-gray-400 truncate">
                        {conversation.lastMessage}
                      </p>
                    </Show>
                  </div>
                </button>
              )}
            </For>
            
            {/* Empty state */}
            <Show when={filteredConversations().length === 0}>
              <div class="px-6 py-8 text-center">
                <p class="text-gray-500 dark:text-gray-400">
                  No conversations found
                </p>
              </div>
            </Show>
          </div>
          
          {/* Footer */}
          <div class="px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex items-center justify-between">
            <span class="text-sm text-gray-500 dark:text-gray-400">
              {selectedConversations().length} selected
            </span>
            <div class="flex gap-2">
              <button
                onClick={handleClose}
                class="px-4 py-2 text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleForward}
                disabled={selectedConversations().length === 0}
                class="px-4 py-2 bg-guardyn-600 text-white rounded-lg hover:bg-guardyn-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex items-center gap-2"
              >
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 5l7 7-7 7M5 5l7 7-7 7" />
                </svg>
                Forward
              </button>
            </div>
          </div>
        </div>
      </div>
    </Show>
  );
};

export default ForwardModal;
