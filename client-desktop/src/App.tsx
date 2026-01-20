import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createContext, createEffect, createSignal, JSX, onMount, Show, useContext } from 'solid-js';

// Components
import { ToastContainer } from './components/ErrorHandling';

// Theme
import { openShortcutsModal, ShortcutsModal } from './components/KeyboardShortcuts';
import { OfflineBanner } from './components/NetworkStatus';
import Sidebar from './components/Sidebar';
import { ThemeProvider } from './contexts/ThemeContext';

// Hooks
import { useAppShortcuts } from './hooks';

// Types
import type { UserInfo } from './types';

// Create auth context
interface AuthContextType {
  user: () => UserInfo | null;
  setUser: (user: UserInfo | null) => void;
  loading: () => boolean;
}

const AuthContext = createContext<AuthContextType>();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};

// Auth provider component
export const AuthProvider: Component<{ children: JSX.Element }> = (props) => {
  const [user, setUser] = createSignal<UserInfo | null>(null);
  const [loading, setLoading] = createSignal(true);

  onMount(async () => {
    try {
      const currentUser = await invoke<UserInfo | null>('get_current_user');
      setUser(currentUser);
    } catch (error) {
      console.error('Failed to get current user:', error);
    } finally {
      setLoading(false);
    }
  });

  return (
    <AuthContext.Provider value={{ user, setUser, loading }}>
      {props.children}
    </AuthContext.Provider>
  );
};

// Main App layout component
const App: Component<{ children?: JSX.Element }> = (props) => {
  const { user, setUser, loading } = useAuth();
  const navigate = useNavigate();

  // Initialize global keyboard shortcuts
  useAppShortcuts();

  // Register shortcut help modal (Ctrl/Cmd + ?)
  onMount(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === '?') {
        e.preventDefault();
        openShortcutsModal();
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  });

  const handleLogout = async () => {
    try {
      await invoke('logout');
      setUser(null);
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  // Check if current path is auth page
  const isAuthPage = () => {
    const path = window.location.pathname;
    return path === '/login' || path === '/register';
  };

  // Reactive effect: redirect to login when not authenticated
  // This runs whenever loading() or user() changes
  createEffect(() => {
    if (!loading() && !user() && !isAuthPage()) {
      navigate('/login');
    }
  });

  return (
    <div class="h-screen bg-white dark:bg-gray-900 text-gray-900 dark:text-white transition-colors duration-200">
      {/* Global overlays */}
      <OfflineBanner />
      <ShortcutsModal />
      <ToastContainer />

      <Show when={!loading()} fallback={
        <div class="flex h-screen items-center justify-center bg-white dark:bg-gray-900">
          <div class="text-gray-900 dark:text-white text-xl">Loading...</div>
        </div>
      }>
        <Show when={user()} fallback={props.children}>
          <div class="flex h-full">
            <Sidebar user={user()!} onLogout={handleLogout} />
            <main class="flex-1 bg-sidebar-light dark:bg-sidebar-dark">
              {props.children}
            </main>
          </div>
        </Show>
      </Show>
    </div>
  );
};

// Wrap App with ThemeProvider for theme management
const ThemedApp: Component<{ children?: JSX.Element }> = (props) => {
  return (
    <ThemeProvider>
      <App>{props.children}</App>
    </ThemeProvider>
  );
};

export default ThemedApp;
