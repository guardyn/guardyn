/**
 * Login Page
 *
 * Modern authentication page with glassmorphism design.
 * Features smooth animations and enhanced UX.
 */

import { A, useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, onMount } from 'solid-js';

import {
    AuthLayout,
    ErrorAlert,
    FormInput,
    SubmitButton,
} from '../components/auth';
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
  const [formVisible, setFormVisible] = createSignal(false);

  // Animate form appearance on mount
  onMount(() => {
    setTimeout(() => setFormVisible(true), 100);
  });

  const validateForm = (): boolean => {
    if (!username().trim()) {
      setError('Username is required');
      return false;
    }
    if (!password()) {
      setError('Password is required');
      return false;
    }
    return true;
  };

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    setError('');

    if (!validateForm()) return;

    setLoading(true);

    try {
      const response = await invoke<AuthResponse>('login', {
        request: {
          username: username(),
          password: password(),
        },
      });

      if (response.success && response.user) {
        props.onLogin(response.user);
        navigate('/chat');
      } else {
        setError(response.error || 'Login failed. Please check your credentials.');
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Connection failed. Please try again.';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout title="Guardyn" subtitle="Secure Communication Platform">
      <form
        onSubmit={handleSubmit}
        class="space-y-5 transition-all duration-500"
        classList={{
          'opacity-0 translate-y-4': !formVisible(),
          'opacity-100 translate-y-0': formVisible(),
        }}
        data-testid="login-form"
      >
        {/* Error message */}
        <ErrorAlert message={error()} onDismiss={() => setError('')} />

        {/* Username field */}
        <FormInput
          id="username"
          name="username"
          label="Username"
          type="text"
          value={username()}
          placeholder="Enter your username"
          required
          onInput={setUsername}
          data-testid="username-input"
          icon={
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
              />
            </svg>
          }
        />

        {/* Password field */}
        <FormInput
          id="password"
          name="password"
          label="Password"
          type="password"
          value={password()}
          placeholder="Enter your password"
          required
          onInput={setPassword}
          data-testid="password-input"
          icon={
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
              />
            </svg>
          }
        />

        {/* Submit button */}
        <div class="pt-2">
          <SubmitButton loading={loading()} data-testid="login-button">
            Sign In
          </SubmitButton>
        </div>

        {/* Register link */}
        <p class="text-center text-sm text-gray-600 dark:text-gray-400">
          Don't have an account?{' '}
          <A
            href="/register"
            class="text-guardyn-500 dark:text-guardyn-400 hover:text-guardyn-400 dark:hover:text-guardyn-300 font-medium transition-colors hover:underline"
          >
            Create account
          </A>
        </p>
      </form>
    </AuthLayout>
  );
};

export default Login;
