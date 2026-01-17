import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createContext, createSignal, JSX, onMount, Show, useContext } from 'solid-js';

// Components
import Sidebar from './components/Sidebar';

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

  const handleLogout = async () => {
    try {
      await invoke('logout');
      setUser(null);
      navigate('/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  return (
    <div class="h-screen bg-gray-900 text-white">
      <Show when={!loading()} fallback={
        <div class="flex h-screen items-center justify-center bg-gray-900">
          <div class="text-white text-xl">Loading...</div>
        </div>
      }>
        <Show when={user()} fallback={props.children}>
          <div class="flex h-full">
            <Sidebar user={user()!} onLogout={handleLogout} />
            <main class="flex-1">
              {props.children}
            </main>
          </div>
        </Show>
      </Show>
    </div>
  );
};

export default App;
