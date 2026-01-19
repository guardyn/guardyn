import { A, useLocation } from '@solidjs/router';
import { Component } from 'solid-js';
import type { UserInfo } from '../types';

interface SidebarProps {
  user: UserInfo;
  onLogout: () => void;
}

const Sidebar: Component<SidebarProps> = (props) => {
  const location = useLocation();

  const isActive = (path: string) => location.pathname.startsWith(path);

  return (
    <aside class="w-64 bg-sidebar-light dark:bg-sidebar-dark flex flex-col h-full border-r border-gray-200 dark:border-gray-700 transition-colors duration-200">
      {/* Logo */}
      <div class="p-4 border-b border-gray-200 dark:border-gray-700">
        <h1 class="text-xl font-bold text-guardyn-500">Guardyn</h1>
        <p class="text-xs text-gray-500 dark:text-gray-400">Secure Messenger</p>
      </div>

      {/* Navigation */}
      <nav class="flex-1 p-2 space-y-1">
        <A
          href="/chat"
          class={`flex items-center px-3 py-2 rounded-lg transition-colors ${
            isActive('/chat')
              ? 'bg-guardyn-600 text-white'
              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
          }`}
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
          </svg>
          Chats
        </A>

        <A
          href="/calls"
          class={`flex items-center px-3 py-2 rounded-lg transition-colors ${
            isActive('/calls') || isActive('/call/')
              ? 'bg-guardyn-600 text-white'
              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
          }`}
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
          </svg>
          Calls
        </A>

        <A
          href="/settings"
          class={`flex items-center px-3 py-2 rounded-lg transition-colors ${
            isActive('/settings')
              ? 'bg-guardyn-600 text-white'
              : 'text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700'
          }`}
        >
          <svg class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z" />
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
          </svg>
          Settings
        </A>
      </nav>

      {/* User info */}
      <div class="p-4 border-t border-gray-200 dark:border-gray-700">
        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <div class="w-8 h-8 rounded-full bg-guardyn-600 flex items-center justify-center text-sm font-medium text-white">
              {props.user.display_name?.[0] || props.user.username[0]}
            </div>
            <div class="ml-2">
              <p class="text-sm font-medium text-gray-900 dark:text-white">
                {props.user.display_name || props.user.username}
              </p>
              <p class="text-xs text-gray-500 dark:text-gray-400">Online</p>
            </div>
          </div>
          <button
            onClick={props.onLogout}
            class="p-2 text-gray-500 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white rounded-lg hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors"
            title="Logout"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
          </button>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
