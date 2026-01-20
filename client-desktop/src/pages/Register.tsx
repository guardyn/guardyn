/**
 * Register Page
 *
 * Modern registration page with password strength indicator.
 * Features smooth animations and comprehensive validation.
 */

import { A, useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createMemo, createSignal, onMount, Show } from 'solid-js';

import {
    AuthLayout,
    ErrorAlert,
    FormInput,
    PasswordStrength,
    SubmitButton,
} from '../components/auth';
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
  const [formVisible, setFormVisible] = createSignal(false);
  const [touched, setTouched] = createSignal<Record<string, boolean>>({});
  const [showPasswordStrength, setShowPasswordStrength] = createSignal(false);

  // Animate form appearance on mount
  onMount(() => {
    setTimeout(() => setFormVisible(true), 100);
  });

  // Validation memos
  const usernameError = createMemo(() => {
    if (!touched().username) return '';
    if (!username().trim()) return 'Username is required';
    if (username().length < 3) return 'Username must be at least 3 characters';
    if (!/^[a-zA-Z0-9_]+$/.test(username())) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return '';
  });

  const passwordError = createMemo(() => {
    if (!touched().password) return '';
    if (!password()) return 'Password is required';
    if (password().length < 12) return 'Password must be at least 12 characters';
    return '';
  });

  const confirmError = createMemo(() => {
    if (!touched().confirmPassword) return '';
    if (!confirmPassword()) return 'Please confirm your password';
    if (password() !== confirmPassword()) return 'Passwords do not match';
    return '';
  });

  const isFormValid = createMemo(() => {
    return (
      username().trim().length >= 3 &&
      password().length >= 12 &&
      password() === confirmPassword() &&
      !usernameError() &&
      !passwordError() &&
      !confirmError()
    );
  });

  const markTouched = (field: string) => {
    setTouched((prev) => ({ ...prev, [field]: true }));
  };

  const handleSubmit = async (e: Event) => {
    e.preventDefault();
    setError('');

    // Mark all fields as touched
    setTouched({
      username: true,
      password: true,
      confirmPassword: true,
    });

    // Validate
    if (usernameError() || passwordError() || confirmError()) {
      setError(usernameError() || passwordError() || confirmError());
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
        setError(response.error || 'Registration failed. Please try again.');
      }
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Connection failed. Please try again.';
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <AuthLayout title="Guardyn" subtitle="Create your secure account">
      <form
        onSubmit={handleSubmit}
        class="space-y-4 transition-all duration-500"
        classList={{
          'opacity-0 translate-y-4': !formVisible(),
          'opacity-100 translate-y-0': formVisible(),
        }}
        data-testid="register-form"
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
          placeholder="Choose a username"
          required
          error={usernameError()}
          onInput={setUsername}
          onBlur={() => markTouched('username')}
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

        {/* Display Name field */}
        <FormInput
          id="displayName"
          name="displayName"
          label="Display Name"
          type="text"
          value={displayName()}
          placeholder="Your display name (optional)"
          hint="This is how others will see you"
          onInput={setDisplayName}
          data-testid="display-name-input"
          icon={
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M5.121 17.804A13.937 13.937 0 0112 16c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0zm6 2a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
          }
        />

        {/* Password field */}
        <div>
          <FormInput
            id="password"
            name="password"
            label="Password"
            type="password"
            value={password()}
            placeholder="Create a strong password"
            required
            error={passwordError()}
            onInput={(value) => {
              setPassword(value);
              setShowPasswordStrength(true);
            }}
            onBlur={() => markTouched('password')}
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
          <Show when={showPasswordStrength()}>
            <div class="mt-2">
              <PasswordStrength password={password()} showRequirements={password().length > 0} />
            </div>
          </Show>
        </div>

        {/* Confirm Password field */}
        <FormInput
          id="confirmPassword"
          name="confirmPassword"
          label="Confirm Password"
          type="password"
          value={confirmPassword()}
          placeholder="Confirm your password"
          required
          error={confirmError()}
          onInput={setConfirmPassword}
          onBlur={() => markTouched('confirmPassword')}
          data-testid="confirm-password-input"
          icon={
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
              />
            </svg>
          }
        />

        {/* Terms notice */}
        <p class="text-xs text-gray-500 text-center">
          By creating an account, you agree to our{' '}
          <a href="#" class="text-guardyn-400 hover:underline">
            Terms of Service
          </a>{' '}
          and{' '}
          <a href="#" class="text-guardyn-400 hover:underline">
            Privacy Policy
          </a>
        </p>

        {/* Submit button */}
        <div class="pt-2">
          <SubmitButton
            loading={loading()}
            disabled={!isFormValid() && Object.keys(touched()).length > 0}
            data-testid="register-button"
          >
            Create Account
          </SubmitButton>
        </div>

        {/* Login link */}
        <p class="text-center text-sm text-gray-600 dark:text-gray-400">
          Already have an account?{' '}
          <A
            href="/login"
            class="text-guardyn-500 dark:text-guardyn-400 hover:text-guardyn-400 dark:hover:text-guardyn-300 font-medium transition-colors hover:underline"
          >
            Sign in
          </A>
        </p>
      </form>
    </AuthLayout>
  );
};

export default Register;
