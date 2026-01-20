/**
 * Register Page Tests
 *
 * Comprehensive unit tests for the Register page component.
 */

import { Router } from '@solidjs/router';
import { fireEvent, render, screen, waitFor } from '@solidjs/testing-library';
import { beforeEach, describe, expect, it, vi } from 'vitest';
import Register from './Register';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

// Helper to render with router
const renderWithRouter = (ui: () => ReturnType<typeof Register>) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('Register Page', () => {
  const mockOnLogin = vi.fn();

  beforeEach(() => {
    mockInvoke.mockClear();
    mockOnLogin.mockClear();
  });

  it('renders the registration form', () => {
    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    expect(screen.getByText('Guardyn')).toBeInTheDocument();
    expect(screen.getByText('Create your secure account')).toBeInTheDocument();
    expect(screen.getByLabelText(/username/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/display name/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/^password/i)).toBeInTheDocument();
    expect(screen.getByLabelText(/confirm password/i)).toBeInTheDocument();
  });

  it('renders link to login page', () => {
    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    expect(screen.getByText('Already have an account?')).toBeInTheDocument();
    // The Sign in text should be present for navigation
    expect(screen.getByText('Sign in')).toBeInTheDocument();
  });

  it('validates password length', async () => {
    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'short' } });
    await fireEvent.input(confirmInput, { target: { value: 'short' } });
    
    // Submit triggers touched state for all fields
    await fireEvent.click(submitButton);

    await waitFor(() => {
      // Error shown in ErrorAlert component
      const errorMessage = screen.getByTestId('error-message');
      expect(errorMessage).toBeInTheDocument();
      expect(errorMessage.textContent).toMatch(/at least 12 characters/i);
    });
    expect(mockInvoke).not.toHaveBeenCalled();
  });

  it('validates passwords match', async () => {
    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'validpassword123456' } }); // Valid length password
    await fireEvent.input(confirmInput, { target: { value: 'differentpassword456' } }); // Different password
    
    // Submit triggers touched state for all fields
    await fireEvent.click(submitButton);

    await waitFor(() => {
      // Error shown in ErrorAlert component
      const errorMessage = screen.getByTestId('error-message');
      expect(errorMessage).toBeInTheDocument();
      expect(errorMessage.textContent).toMatch(/do not match/i);
    });
    expect(mockInvoke).not.toHaveBeenCalled();
  });

  it('calls invoke with register on valid form submit', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: true,
      user: { user_id: 'user-123', username: 'newuser', display_name: 'New User' },
    });

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const displayNameInput = screen.getByTestId('display-name-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(displayNameInput, { target: { value: 'New User' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123456' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123456' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('register', {
        username: 'newuser',
        password: 'password123456',
        displayName: 'New User',
      });
    });
  });

  it('calls onLogin callback on successful registration', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: true,
      user: { user_id: 'user-123', username: 'newuser', display_name: 'New User' },
    });

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123456' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123456' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockOnLogin).toHaveBeenCalledWith({
        user_id: 'user-123',
        username: 'newuser',
        display_name: 'New User',
      });
    });
  });

  it('displays error message on registration failure', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: false,
      error: 'Username already exists',
    });

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'existinguser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123456' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123456' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByTestId('error-message')).toHaveTextContent('Username already exists');
    });
    expect(mockOnLogin).not.toHaveBeenCalled();
  });

  it('displays error message on network error', async () => {
    mockInvoke.mockRejectedValueOnce(new Error('Connection failed'));

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123456' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123456' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByTestId('error-message')).toHaveTextContent('Connection failed');
    });
  });

  it('shows loading state while submitting', async () => {
    let resolveRegister: (value: unknown) => void;
    mockInvoke.mockImplementationOnce(() => new Promise((resolve) => {
      resolveRegister = resolve;
    }));

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123456' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123456' } });
    await fireEvent.click(submitButton);

    // Button should be disabled
    expect(submitButton).toBeDisabled();

    // Resolve the promise
    resolveRegister!({ success: true, user: { user_id: '1', username: 'newuser' } });

    await waitFor(() => {
      expect(submitButton).not.toBeDisabled();
    });
  });

  it('allows registration without display name', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: true,
      user: { user_id: 'user-123', username: 'newuser' },
    });

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByTestId('username-input');
    const passwordInput = screen.getByTestId('password-input');
    const confirmInput = screen.getByTestId('confirm-password-input');
    const submitButton = screen.getByTestId('register-button');

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123456' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123456' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('register', {
        username: 'newuser',
        password: 'password123456',
        displayName: undefined,
      });
    });
  });
});
