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

  it('renders the login form', () => {
    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    expect(screen.getByText('Guardyn')).toBeInTheDocument();
    expect(screen.getByText('Secure Communication Platform')).toBeInTheDocument();
    expect(screen.getByLabelText('Username')).toBeInTheDocument();
    expect(screen.getByLabelText('Password')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /sign in/i })).toBeInTheDocument();
  });

  it('renders link to registration page', () => {
    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    expect(screen.getByText("Don't have an account?")).toBeInTheDocument();
    expect(screen.getByText('Create account')).toHaveAttribute('href', '/register');
  });

  it('shows E2EE security notice', () => {
    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    expect(screen.getByText('End-to-end encrypted')).toBeInTheDocument();
  });

  it('updates input fields on user input', async () => {
    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText('Username') as HTMLInputElement;
    const passwordInput = screen.getByLabelText('Password') as HTMLInputElement;

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });

    expect(usernameInput.value).toBe('testuser');
    expect(passwordInput.value).toBe('testpass123');
  });

  it('calls invoke with login on form submit', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: true,
      user: { user_id: 'user-123', username: 'testuser' },
    });

    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in/i });

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockInvoke).toHaveBeenCalledWith('login', {
        username: 'testuser',
        password: 'testpass123',
      });
    });
  });

  it('calls onLogin callback on successful login', async () => {
    mockInvoke.mockResolvedValueOnce({
      success: true,
      user: { user_id: 'user-123', username: 'testuser', display_name: 'Test User' },
    });

    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in/i });

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

    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in/i });

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

    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in/i });

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
    await fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Network error')).toBeInTheDocument();
    });
  });

  it('shows loading state while submitting', async () => {
    let resolveLogin: (value: unknown) => void;
    mockInvoke.mockImplementationOnce(() => new Promise((resolve) => {
      resolveLogin = resolve;
    }));

    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in/i });

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
    await fireEvent.click(submitButton);

    // Button should be disabled and show loading
    expect(submitButton).toBeDisabled();

    // Resolve the promise
    resolveLogin!({ success: true, user: { user_id: '1', username: 'testuser' } });

    await waitFor(() => {
      expect(submitButton).not.toBeDisabled();
    });
  });

  it('disables submit button while loading', async () => {
    mockInvoke.mockImplementationOnce(() => new Promise(() => {})); // Never resolves

    renderWithRouter(() => <Login onLogin={mockOnLogin} />);

    const usernameInput = screen.getByLabelText('Username');
    const passwordInput = screen.getByLabelText('Password');
    const submitButton = screen.getByRole('button', { name: /sign in/i });

    await fireEvent.input(usernameInput, { target: { value: 'testuser' } });
    await fireEvent.input(passwordInput, { target: { value: 'testpass123' } });
    await fireEvent.click(submitButton);

    expect(submitButton).toBeDisabled();
  });
});
