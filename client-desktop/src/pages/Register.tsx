import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal } from 'solid-js';
import type { AuthResponse } from '../types';

interface RegisterPageProps {
  onLogin: (user: { user_id: string; username: string; display_name?: string }) => void;
}

const Register: Component<RegisterPageProps> = (props) => {
  const navigate = useNavigate();
  const [username, setUsername] = createSignal('');
  const [displayName, setDisplayName] = createSignal('');
  const [password, setPassword] = createSignal('');
  const [confirmPassword, setConfirmPassword] = createSignal('');
  const [error, setError] = createSignal('');
  const [loading, setLoading] = createSignal(false);

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    setError('');

    // Validate passwords match
    if (password() !== confirmPassword()) {
      setError('Passwords do not match');
      return;
    }

    // Validate password strength
    if (password().length < 8) {
      setError('Password must be at least 8 characters');
      return;
    }

    setLoading(true);

    try {
      const response = await invoke<AuthResponse>('register', {
        username: username(),
        password: password(),
        displayName: displayName() || undefined,
      });

      if (response.success && response.user) {
        props.onLogin(response.user);
        navigate('/chat');
      } else {
        setError(response.error || 'Registration failed');
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
          <p class="mt-2 text-gray-400">Create your secure account</p>
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
                Username *
              </label>
              <input
                id="username"
                name="username"
                type="text"
                required
                value={username()}
                onInput={(e) => setUsername(e.currentTarget.value)}
                class="mt-1 block w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
                placeholder="Choose a username"
              />
            </div>

            <div>
              <label for="displayName" class="block text-sm font-medium text-gray-300">
                Display Name
              </label>
              <input
                id="displayName"
                name="displayName"
                type="text"
                value={displayName()}
                onInput={(e) => setDisplayName(e.currentTarget.value)}
                class="mt-1 block w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
                placeholder="Your display name (optional)"
              />
            </div>

            <div>
              <label for="password" class="block text-sm font-medium text-gray-300">
                Password *
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                value={password()}
                onInput={(e) => setPassword(e.currentTarget.value)}
                class="mt-1 block w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
                placeholder="Create a strong password"
              />
              <p class="mt-1 text-xs text-gray-500">Minimum 8 characters</p>
            </div>

            <div>
              <label for="confirmPassword" class="block text-sm font-medium text-gray-300">
                Confirm Password *
              </label>
              <input
                id="confirmPassword"
                name="confirmPassword"
                type="password"
                required
                value={confirmPassword()}
                onInput={(e) => setConfirmPassword(e.currentTarget.value)}
                class="mt-1 block w-full px-4 py-3 bg-gray-800 border border-gray-700 rounded-lg text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-guardyn-500 focus:border-transparent transition"
                placeholder="Confirm your password"
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
              'Create Account'
            )}
          </button>
        </form>

        {/* Footer */}
        <p class="text-center text-sm text-gray-400">
          Already have an account?{' '}
          <a href="/login" class="text-guardyn-500 hover:text-guardyn-400 font-medium">
            Sign in
          </a>
        </p>

        {/* Security notice */}
        <div class="flex items-center justify-center text-xs text-gray-500">
          <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" />
          </svg>
          Your keys are generated locally and never leave your device
        </div>
      </div>
    </div>
  );
};

export default Register;
