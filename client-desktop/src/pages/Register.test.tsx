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
    expect(screen.getByText('Sign in')).toHaveAttribute('href', '/login');
  });

  it('validates password length', async () => {
    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'short' } });
    await fireEvent.input(confirmInput, { target: { value: 'short' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Password must be at least 8 characters')).toBeInTheDocument();
    });
    expect(mockInvoke).not.toHaveBeenCalled();
  });

  it('validates passwords match', async () => {
    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password456' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Passwords do not match')).toBeInTheDocument();
    });
    expect(mockInvoke).not.toHaveBeenCalled();
  });

  it('calls invoke with register on valid form submit', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: true,
      user: { user_id: 'user-123', username: 'newuser', display_name: 'New User' },
    });

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const displayNameInput = screen.getByLabelText(/display name/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(displayNameInput, { target: { value: 'New User' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('register', {
        username: 'newuser',
        password: 'password123',
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

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123' } });
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

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'existinguser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Username already exists')).toBeInTheDocument();
    });
    expect(mockOnLogin).not.toHaveBeenCalled();
  });

  it('displays error message on network error', async () => {
    mockInvoke.mockRejectedValueOnce(new Error('Connection failed'));

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Connection failed')).toBeInTheDocument();
    });
  });

  it('shows loading state while submitting', async () => {
    let resolveRegister: (value: unknown) => void;
    mockInvoke.mockImplementationOnce(() => new Promise((resolve) => {
      resolveRegister = resolve;
    }));

    renderWithRouter(() => <Register onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123' } });
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

    const usernameInput = screen.getByLabelText(/username/i);
    const passwordInput = screen.getByLabelText(/^password/i);
    const confirmInput = screen.getByLabelText(/confirm password/i);
    const submitButton = screen.getByRole('button', { name: /create account/i });

    await fireEvent.input(usernameInput, { target: { value: 'newuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'password123' } });
    await fireEvent.input(confirmInput, { target: { value: 'password123' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('register', {
        username: 'newuser',
        password: 'password123',
        displayName: undefined,
      });
    });
  });
});
