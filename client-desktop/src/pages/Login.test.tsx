/**
 * Login Page Tests
 *
 * Comprehensive unit tests for the Login page component.
 */

import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import Login from './Login';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

// Helper to render with router
const renderWithRouter = (ui: () => ReturnType<typeof Login>) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('Login Page', () => {
  const mockOnLogin = vi.fn();

  beforeEach(() => {
    mockInvoke.mockClear();
    mockOnLogin.mockClear();
  });

  describe('Rendering', () => {
    it('renders the login form', () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      expect(screen.getByText('Guardyn')).toBeInTheDocument();
      expect(screen.getByText('Secure Communication Platform')).toBeInTheDocument();
      expect(screen.getByTestId('login-form')).toBeInTheDocument();
    });

    it('renders username and password inputs', () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      expect(screen.getByTestId('username-input')).toBeInTheDocument();
      expect(screen.getByTestId('password-input')).toBeInTheDocument();
    });

    it('renders login button', () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      expect(screen.getByTestId('login-button')).toBeInTheDocument();
      expect(screen.getByText('Sign In')).toBeInTheDocument();
    });

    it('renders link to registration page', () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      expect(screen.getByText("Don't have an account?")).toBeInTheDocument();
      expect(screen.getByText('Create account')).toBeInTheDocument();
    });

    it('shows E2EE security badges', () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      expect(screen.getByText('E2E Encrypted')).toBeInTheDocument();
      expect(screen.getByText('Post-Quantum Ready')).toBeInTheDocument();
    });
  });

  describe('Form Interactions', () => {
    it('updates input fields on user input', async () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input') as HTMLInputElement;
      const passwordInput = screen.getByTestId('password-input') as HTMLInputElement;

      await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
      await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });

      expect(usernameInput.value).toBe('testuser');
      expect(passwordInput.value).toBe('testpass123');
    });

    it('validates empty username', async () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const form = screen.getByTestId('login-form');
      const passwordInput = screen.getByTestId('password-input');

      await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
      await fireEvent.submit(form);

      await waitFor(() => {
        // Error is shown in ErrorAlert component with data-testid="error-message"
        const errorElement = screen.getByTestId('error-message');
        expect(errorElement).toBeInTheDocument();
        expect(errorElement.textContent).toContain('Username is required');
      }, { timeout: 2000 });
      expect(mockInvoke).not.toHaveBeenCalled();
    });

    it('validates empty password', async () => {
      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const form = screen.getByTestId('login-form');
      const usernameInput = screen.getByTestId('username-input');

      await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
      await fireEvent.submit(form);

      await waitFor(() => {
        // Error is shown in ErrorAlert component with data-testid="error-message"
        const errorElement = screen.getByTestId('error-message');
        expect(errorElement).toBeInTheDocument();
        expect(errorElement.textContent).toContain('Password is required');
      }, { timeout: 2000 });
      expect(mockInvoke).not.toHaveBeenCalled();
    });
  });

  describe('Authentication Flow', () => {
    it('calls invoke with login on form submit', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: true,
        user: { user_id: 'user-123', username: 'testuser' },
      });

      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input');
      const passwordInput = screen.getByTestId('password-input');
      const submitButton = screen.getByTestId('login-button');

      await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
      await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
      await fireEvent.click(submitButton);

      await waitFor(() => {
        expect(mockInvoke).toHaveBeenCalledWith('login', {
          request: {
            username: 'testuser',
            password: 'testpass123',
          },
        });
      });
    });

    it('calls onLogin callback on successful login', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: true,
        user: { user_id: 'user-123', username: 'testuser', display_name: 'Test User' },
      });

      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input');
      const passwordInput = screen.getByTestId('password-input');
      const submitButton = screen.getByTestId('login-button');

      await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
      await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
      await fireEvent.click(submitButton);

      await waitFor(() => {
        expect(mockOnLogin).toHaveBeenCalledWith({
          user_id: 'user-123',
          username: 'testuser',
          display_name: 'Test User',
        });
      });
    });

    it('displays error message on login failure', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: false,
        error: 'Invalid credentials',
      });

      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input');
      const passwordInput = screen.getByTestId('password-input');
      const submitButton = screen.getByTestId('login-button');

      await fireEvent.input(usernameInput, { target: { value: 'wronguser' } });
      await fireEvent.input(passwordInput, { target: { value: 'wrongpass' } });
      await fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Invalid credentials')).toBeInTheDocument();
      });
      expect(mockOnLogin).not.toHaveBeenCalled();
    });

    it('displays error message on network error', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Network error'));

      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input');
      const passwordInput = screen.getByTestId('password-input');
      const submitButton = screen.getByTestId('login-button');

      await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
      await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
      await fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByText('Network error')).toBeInTheDocument();
      });
    });
  });

  describe('Loading State', () => {
    it('shows loading state while submitting', async () => {
      // Use a promise that won't resolve immediately
      let resolveLogin: (value: unknown) => void;
      const loginPromise = new Promise((resolve) => {
        resolveLogin = resolve;
      });
      mockInvoke.mockReturnValueOnce(loginPromise);

      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input');
      const passwordInput = screen.getByTestId('password-input');
      const submitButton = screen.getByTestId('login-button');

      await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
      await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
      await fireEvent.click(submitButton);

      // Button should be disabled during loading
      expect(submitButton).toBeDisabled();

      // Resolve the promise
      resolveLogin!({ success: true, user: { user_id: '1', username: 'test' } });

      await waitFor(() => {
        expect(submitButton).not.toBeDisabled();
      });
    });
  });

  describe('Error Dismissal', () => {
    it('can dismiss error message', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: false,
        error: 'Test error',
      });

      renderWithRouter(() => <Login onLogin={mockOnLogin} />);

      const usernameInput = screen.getByTestId('username-input');
      const passwordInput = screen.getByTestId('password-input');
      const submitButton = screen.getByTestId('login-button');

      await fireEvent.input(usernameInput, { target: { value: 'test' } });
      await fireEvent.input(passwordInput, { target: { value: 'test123' } });
      await fireEvent.click(submitButton);

      await waitFor(() => {
        expect(screen.getByTestId('error-message')).toBeInTheDocument();
      });

      // Find and click dismiss button inside error message
      const errorMessage = screen.getByTestId('error-message');
      const dismissButton = errorMessage.querySelector('button');
      expect(dismissButton).toBeInTheDocument();
      await fireEvent.click(dismissButton!);

      await waitFor(() => {
        expect(screen.queryByTestId('error-message')).not.toBeInTheDocument();
      });
    });
  });
});
