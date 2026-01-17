import { Navigate, Route, Routes } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, onMount } from 'solid-js';

// Pages
import Chat from './pages/Chat';
import Login from './pages/Login';
import Register from './pages/Register';
import Settings from './pages/Settings';

// Components
import Sidebar from './components/Sidebar';

// Types
import type { UserInfo } from './types';

const App: Component = () => {
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

  const handleLogin = (userInfo: UserInfo) => {
    setUser(userInfo);
  };

  const handleLogout = async () => {
    try {
      await invoke('logout');
      setUser(null);
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  if (loading()) {
    return (
      <div class="flex h-screen items-center justify-center bg-gray-900">
        <div class="text-white text-xl">Loading...</div>
      </div>
    );
  }

  return (
    <div class="h-screen bg-gray-900 text-white">
      {user() ? (
        <div class="flex h-full">
          <Sidebar user={user()!} onLogout={handleLogout} />
          <main class="flex-1">
            <Routes>
              <Route path="/" component={() => <Navigate href="/chat" />} />
              <Route path="/chat/:conversationId?" component={Chat} />
              <Route path="/settings" component={Settings} />
            </Routes>
          </main>
        </div>
      ) : (
        <Routes>
          <Route path="/" component={() => <Navigate href="/login" />} />
          <Route path="/login" component={() => <Login onLogin={handleLogin} />} />
          <Route path="/register" component={() => <Register onLogin={handleLogin} />} />
        </Routes>
      )}
    </div>
  );
};

export default App;
