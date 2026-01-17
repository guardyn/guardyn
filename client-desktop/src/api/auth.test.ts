/**
 * Authentication API Integration Tests
 *
 * Tests for the auth API module with mocked Tauri invoke.
 */

import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
    getCurrentUser,
    login,
    logout,
    register,
    searchUsers,
} from './auth';

// Mock Tauri invoke
const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

describe('Auth API', () => {
  beforeEach(() => {
    mockInvoke.mockClear();
  });

  describe('login', () => {
    it('calls invoke with correct parameters', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: true,
        user: { user_id: 'user-123', username: 'testuser' },
        token: 'jwt-token',
      });

      const result = await login({ username: 'testuser', password: 'password123' });

      expect(mockInvoke).toHaveBeenCalledWith('login', {
        request: { username: 'testuser', password: 'password123' },
      });
      expect(result.success).toBe(true);
      expect(result.user?.username).toBe('testuser');
    });

    it('returns error on failed login', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: false,
        error: 'Invalid credentials',
      });

      const result = await login({ username: 'wrong', password: 'wrong' });

      expect(result.success).toBe(false);
      expect(result.error).toBe('Invalid credentials');
    });

    it('throws on network error', async () => {
      mockInvoke.mockRejectedValueOnce(new Error('Network error'));

      await expect(login({ username: 'test', password: 'test' }))
        .rejects.toThrow('Network error');
    });
  });

  describe('register', () => {
    it('calls invoke with correct parameters', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: true,
        user: { user_id: 'user-456', username: 'newuser', display_name: 'New User' },
        token: 'jwt-token',
      });

      const result = await register({
        username: 'newuser',
        password: 'password123',
        display_name: 'New User',
      });

      expect(mockInvoke).toHaveBeenCalledWith('register', {
        request: {
          username: 'newuser',
          password: 'password123',
          display_name: 'New User',
        },
      });
      expect(result.success).toBe(true);
      expect(result.user?.display_name).toBe('New User');
    });

    it('registers without display name', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: true,
        user: { user_id: 'user-789', username: 'plainuser' },
      });

      await register({ username: 'plainuser', password: 'password123' });

      expect(mockInvoke).toHaveBeenCalledWith('register', {
        request: { username: 'plainuser', password: 'password123' },
      });
    });

    it('returns error when username exists', async () => {
      mockInvoke.mockResolvedValueOnce({
        success: false,
        error: 'Username already taken',
      });

      const result = await register({
        username: 'existinguser',
        password: 'password123',
      });

      expect(result.success).toBe(false);
      expect(result.error).toBe('Username already taken');
    });
  });

  describe('logout', () => {
    it('calls invoke to logout', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await logout();

      expect(mockInvoke).toHaveBeenCalledWith('logout');
    });

    it('completes even if not logged in', async () => {
      mockInvoke.mockResolvedValueOnce(undefined);

      await expect(logout()).resolves.toBeUndefined();
    });
  });

  describe('getCurrentUser', () => {
    it('returns current user when authenticated', async () => {
      mockInvoke.mockResolvedValueOnce({
        user_id: 'user-123',
        username: 'currentuser',
        display_name: 'Current User',
      });

      const user = await getCurrentUser();

      expect(mockInvoke).toHaveBeenCalledWith('get_current_user');
      expect(user?.user_id).toBe('user-123');
      expect(user?.username).toBe('currentuser');
    });

    it('returns null when not authenticated', async () => {
      mockInvoke.mockResolvedValueOnce(null);

      const user = await getCurrentUser();

      expect(user).toBeNull();
    });
  });

  describe('searchUsers', () => {
    it('returns matching users', async () => {
      mockInvoke.mockResolvedValueOnce([
        { user_id: 'user-1', username: 'alice', display_name: 'Alice' },
        { user_id: 'user-2', username: 'alex', display_name: 'Alex' },
      ]);

      const users = await searchUsers('al');

      expect(mockInvoke).toHaveBeenCalledWith('search_users', { query: 'al' });
      expect(users).toHaveLength(2);
      expect(users[0].username).toBe('alice');
    });

    it('returns empty array when no matches', async () => {
      mockInvoke.mockResolvedValueOnce([]);

      const users = await searchUsers('nonexistent');

      expect(users).toHaveLength(0);
    });

    it('handles empty query', async () => {
      mockInvoke.mockResolvedValueOnce([]);

      await searchUsers('');

      expect(mockInvoke).toHaveBeenCalledWith('search_users', { query: '' });
    });
  });
});
