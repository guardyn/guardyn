import { Router } from '@solidjs/router';
import { render, screen } from '@solidjs/testing-library';
import { describe, expect, it, vi } from 'vitest';
import type { UserInfo } from '../types';
import Sidebar from './Sidebar';

// Helper to render with router
const renderWithRouter = (ui: () => any) => {
  return render(() => <Router>{ui()}</Router>);
};

describe('Sidebar', () => {
  const mockUser: UserInfo = {
    user_id: 'user-123',
    username: 'testuser',
    display_name: 'Test User',
  };

  const mockLogout = vi.fn();

  it('renders the app name', () => {
    renderWithRouter(() => <Sidebar user={mockUser} onLogout={mockLogout} />);

    expect(screen.getByText('Guardyn')).toBeInTheDocument();
    expect(screen.getByText('Secure Messenger')).toBeInTheDocument();
  });

  it('renders navigation links', () => {
    renderWithRouter(() => <Sidebar user={mockUser} onLogout={mockLogout} />);

    expect(screen.getByText('Chats')).toBeInTheDocument();
    expect(screen.getByText('Calls')).toBeInTheDocument();
    expect(screen.getByText('Settings')).toBeInTheDocument();
  });

  it('displays user display name when available', () => {
    renderWithRouter(() => <Sidebar user={mockUser} onLogout={mockLogout} />);

    expect(screen.getByText('Test User')).toBeInTheDocument();
  });

  it('displays username when display name is not available', () => {
    const userWithoutDisplayName: UserInfo = {
      user_id: 'user-456',
      username: 'plainuser',
    };

    renderWithRouter(() => (
      <Sidebar user={userWithoutDisplayName} onLogout={mockLogout} />
    ));

    expect(screen.getByText('plainuser')).toBeInTheDocument();
  });

  it('shows user avatar initial', () => {
    renderWithRouter(() => <Sidebar user={mockUser} onLogout={mockLogout} />);

    // The avatar should show 'T' from 'Test User'
    const avatars = screen.getAllByText('T');
    expect(avatars.length).toBeGreaterThan(0);
  });

  it('shows online status', () => {
    renderWithRouter(() => <Sidebar user={mockUser} onLogout={mockLogout} />);

    expect(screen.getByText('Online')).toBeInTheDocument();
  });

  it('calls onLogout when logout button is clicked', async () => {
    renderWithRouter(() => <Sidebar user={mockUser} onLogout={mockLogout} />);

    const logoutButton = screen.getByRole('button');
    await logoutButton.click();

    expect(mockLogout).toHaveBeenCalled();
  });
});
