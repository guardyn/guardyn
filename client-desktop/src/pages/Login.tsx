import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal } from 'solid-js';
import type { AuthResponse } from '../types';

interface LoginPageProps {
  onLogin: (user: { user_id: string; username: string; display_name?: string }) => void;
}

const Login: Component<LoginPageProps> = (props) => {
  const navigate = useNavigate();
  const [username, setUsername] = createSignal('');
  const [password, setPassword] = createSignal('');
  const [error, setError] = createSignal('');
  const [loading, setLoading] = createSignal(false);

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    setError('');
    setLoading(true);

    try {
      const response = await invoke<AuthResponse>('login', {
        username: username(),
        password: password(),
      });

      if (response.success && response.user) {
        props.onLogin(response.user);
        navigate('/chat');
      } else {
        setError(response.error || 'Login failed');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div class="min-h-screen flex items-center justify-center bg-gray-900 px-4">
      <div class="max-w-md w-full space-y-8">
        {/* Header */}
        <div class="text-center">
          <h1 class="text-4xl font-bold text-guardyn-500">Guardyn</h1>
          <p class="mt-2 text-gray-400">Secure Communication Platform</p>
        </div>

        {/* Form */}
        <form class="mt-8 space-y-6" onSubmit={handleSubmit}>
          {error() && (
            <div class="bg-red-500/10 border border-red-500/50 text-red-400 px-4 py-3 rounded-lg animate-fade-in">
              {error()}
            </div>
          )}

          <div class="space-y-4">
            <div>
              <label for="username" class="block text-sm font-medium text-gray-300">
                Username
              </label>
              <input
                id="username"
                name="username"
                type="text"
                required
                value={username()}
                onInput={(e) => setUsername(e.currentTarget.value)}
                class="mt-1 block w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
                placeholder="Enter your username"
              />
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-gray-300">
                Password
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={password()}
                onInput={(e) => setPassword(e.currentTarget.value)}
                class="mt-1 block w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
                placeholder="Enter your password"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={loading()}
            class="w-full flex justify-center py-3 px-4 border border-transparent rounded-lg text-white bg-guardyn-600 hover:bg-guardyn-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-guardyn-500 disabled:opacity-50 disabled:cursor-not-allowed transition font-medium"
          >
            {loading() ? (
              <svg class="animate-spin h-5 w-5" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
            ) : (
              'Sign In'
            )}
          </button>
        </form>

        {/* Footer */}
        <p class="text-center text-sm text-gray-400">
          Don't have an account?{' '}
          <a href="/register" class="text-guardyn-500 hover:text-guardyn-400 font-medium">
            Create account
          </a>
        </p>

        {/* Security notice */}
        <div class="flex items-center justify-center text-xs text-gray-500">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
          </svg>
          End-to-end encrypted
        </div>
      </div>
    </div>
  );
};

export default Login;
