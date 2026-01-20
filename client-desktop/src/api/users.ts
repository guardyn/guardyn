/**
 * Users API
 *
 * API functions for user-related operations.
 * Includes user search, profile retrieval, and user management.
 *
 * @module api/users
 */

import { invoke } from '@tauri-apps/api/core';

// =============================================================================
// TYPES
// =============================================================================

/**
 * User profile information
 */
export interface UserProfile {
  /** Unique user ID */
  id: string;
  /** Display name */
  displayName: string;
  /** Username (handle) */
  username: string;
  /** Avatar URL */
  avatarUrl?: string;
  /** User bio/status message */
  bio?: string;
  /** Whether the user is verified */
  isVerified: boolean;
  /** Whether this user is in the current user's contacts */
  isContact: boolean;
  /** Whether this user is blocked */
  isBlocked: boolean;
  /** When the user was last seen (ISO 8601) */
  lastSeen?: string;
  /** Current presence status */
  presenceStatus?: 'online' | 'offline' | 'away' | 'do_not_disturb';
  /** When the user joined (ISO 8601) */
  createdAt: string;
}

/**
 * Search result for a user
 */
export interface UserSearchResult {
  /** User profile */
  user: UserProfile;
  /** Match score (0-1) for ranking */
  score: number;
  /** Which field matched (name, username, etc.) */
  matchField: 'displayName' | 'username' | 'bio';
  /** Highlighted match snippet */
  matchHighlight?: string;
}

/**
 * User search request parameters
 */
export interface UserSearchParams {
  /** Search query string */
  query: string;
  /** Maximum number of results */
  limit?: number;
  /** Offset for pagination */
  offset?: number;
  /** Filter to only show contacts */
  contactsOnly?: boolean;
  /** Exclude blocked users */
  excludeBlocked?: boolean;
}

/**
 * User search response
 */
export interface UserSearchResponse {
  /** Search results */
  results: UserSearchResult[];
  /** Total count (for pagination) */
  totalCount: number;
  /** Whether there are more results */
  hasMore: boolean;
  /** Query that was searched */
  query: string;
}

/**
 * Contact addition request
 */
export interface AddContactRequest {
  /** User ID to add as contact */
  userId: string;
  /** Optional nickname for the contact */
  nickname?: string;
}

/**
 * Contact list item
 */
export interface Contact {
  /** User profile */
  user: UserProfile;
  /** Custom nickname (if set) */
  nickname?: string;
  /** When added as contact (ISO 8601) */
  addedAt: string;
  /** Whether the contact is favorited */
  isFavorite: boolean;
}

// =============================================================================
// API FUNCTIONS
// =============================================================================

/**
 * Search for users by query string
 */
export async function searchUsers(params: UserSearchParams): Promise<UserSearchResponse> {
  try {
    const response = await invoke<UserSearchResponse>('search_users', {
      query: params.query,
      limit: params.limit ?? 20,
      offset: params.offset ?? 0,
      contactsOnly: params.contactsOnly ?? false,
      excludeBlocked: params.excludeBlocked ?? true,
    });
    return response;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Search failed:', error);
    throw error;
  }
}

/**
 * Get a user's profile by ID
 */
export async function getUserProfile(userId: string): Promise<UserProfile> {
  try {
    const profile = await invoke<UserProfile>('get_user_profile', { userId });
    return profile;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Get profile failed:', error);
    throw error;
  }
}

/**
 * Get a user's profile by username
 */
export async function getUserByUsername(username: string): Promise<UserProfile> {
  try {
    const profile = await invoke<UserProfile>('get_user_by_username', { username });
    return profile;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Get user by username failed:', error);
    throw error;
  }
}

/**
 * Get the current user's contact list
 */
export async function getContacts(): Promise<Contact[]> {
  try {
    const contacts = await invoke<Contact[]>('get_contacts');
    return contacts;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Get contacts failed:', error);
    throw error;
  }
}

/**
 * Add a user to contacts
 */
export async function addContact(request: AddContactRequest): Promise<Contact> {
  try {
    const contact = await invoke<Contact>('add_contact', {
      userId: request.userId,
      nickname: request.nickname,
    });
    return contact;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Add contact failed:', error);
    throw error;
  }
}

/**
 * Remove a user from contacts
 */
export async function removeContact(userId: string): Promise<void> {
  try {
    await invoke('remove_contact', { userId });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Remove contact failed:', error);
    throw error;
  }
}

/**
 * Block a user
 */
export async function blockUser(userId: string): Promise<void> {
  try {
    await invoke('block_user', { userId });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Block user failed:', error);
    throw error;
  }
}

/**
 * Unblock a user
 */
export async function unblockUser(userId: string): Promise<void> {
  try {
    await invoke('unblock_user', { userId });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Unblock user failed:', error);
    throw error;
  }
}

/**
 * Get list of blocked users
 */
export async function getBlockedUsers(): Promise<UserProfile[]> {
  try {
    const blocked = await invoke<UserProfile[]>('get_blocked_users');
    return blocked;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Get blocked users failed:', error);
    throw error;
  }
}

/**
 * Update contact nickname
 */
export async function updateContactNickname(
  userId: string,
  nickname: string | null
): Promise<void> {
  try {
    await invoke('update_contact_nickname', { userId, nickname });
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Update nickname failed:', error);
    throw error;
  }
}

/**
 * Toggle contact favorite status
 */
export async function toggleContactFavorite(userId: string): Promise<boolean> {
  try {
    const isFavorite = await invoke<boolean>('toggle_contact_favorite', { userId });
    return isFavorite;
  } catch (error) {
    // eslint-disable-next-line no-console
    console.error('[Users API] Toggle favorite failed:', error);
    throw error;
  }
}

// =============================================================================
// MOCK DATA FOR DEVELOPMENT
// =============================================================================

/**
 * Mock user data for development without backend
 */
const MOCK_USERS: UserProfile[] = [
  {
    id: 'user-1',
    displayName: 'Alice Johnson',
    username: 'alice',
    avatarUrl: undefined,
    bio: 'Security researcher and privacy advocate',
    isVerified: true,
    isContact: true,
    isBlocked: false,
    presenceStatus: 'online',
    createdAt: '2024-01-15T10:00:00Z',
  },
  {
    id: 'user-2',
    displayName: 'Bob Smith',
    username: 'bob',
    avatarUrl: undefined,
    bio: 'Software engineer',
    isVerified: false,
    isContact: true,
    isBlocked: false,
    presenceStatus: 'away',
    lastSeen: new Date(Date.now() - 3600000).toISOString(),
    createdAt: '2024-02-01T14:30:00Z',
  },
  {
    id: 'user-3',
    displayName: 'Charlie Brown',
    username: 'charlie',
    avatarUrl: undefined,
    bio: 'Designer',
    isVerified: false,
    isContact: false,
    isBlocked: false,
    presenceStatus: 'offline',
    lastSeen: new Date(Date.now() - 86400000).toISOString(),
    createdAt: '2024-03-10T09:15:00Z',
  },
  {
    id: 'user-4',
    displayName: 'Diana Prince',
    username: 'diana',
    avatarUrl: undefined,
    bio: 'Cybersecurity expert',
    isVerified: true,
    isContact: false,
    isBlocked: false,
    presenceStatus: 'do_not_disturb',
    createdAt: '2024-01-20T11:00:00Z',
  },
  {
    id: 'user-5',
    displayName: 'Edward Norton',
    username: 'edward',
    avatarUrl: undefined,
    bio: 'Cryptographer',
    isVerified: false,
    isContact: true,
    isBlocked: false,
    presenceStatus: 'online',
    createdAt: '2024-04-05T16:45:00Z',
  },
];

/**
 * Mock search implementation for development
 */
export async function searchUsersMock(
  params: UserSearchParams
): Promise<UserSearchResponse> {
  // Simulate network delay
  await new Promise((resolve) => setTimeout(resolve, 300));

  const query = params.query.toLowerCase();
  const limit = params.limit ?? 20;
  const offset = params.offset ?? 0;

  // Filter users based on query
  const filtered = MOCK_USERS.filter((user) => {
    if (params.contactsOnly && !user.isContact) return false;
    if (params.excludeBlocked && user.isBlocked) return false;

    return (
      user.displayName.toLowerCase().includes(query) ||
      user.username.toLowerCase().includes(query) ||
      user.bio?.toLowerCase().includes(query)
    );
  });

  // Map to search results
  const results: UserSearchResult[] = filtered.map((user) => {
    let matchField: UserSearchResult['matchField'] = 'displayName';
    let score = 0;

    if (user.username.toLowerCase().includes(query)) {
      matchField = 'username';
      score = 0.9;
    } else if (user.displayName.toLowerCase().includes(query)) {
      matchField = 'displayName';
      score = 0.8;
    } else if (user.bio?.toLowerCase().includes(query)) {
      matchField = 'bio';
      score = 0.5;
    }

    return { user, score, matchField };
  });

  // Sort by score
  results.sort((a, b) => b.score - a.score);

  // Paginate
  const paginated = results.slice(offset, offset + limit);

  return {
    results: paginated,
    totalCount: results.length,
    hasMore: offset + limit < results.length,
    query: params.query,
  };
}

/**
 * Mock get profile for development
 */
export async function getUserProfileMock(userId: string): Promise<UserProfile> {
  await new Promise((resolve) => setTimeout(resolve, 100));

  const user = MOCK_USERS.find((u) => u.id === userId);
  if (!user) {
    throw new Error('User not found');
  }

  return user;
}

/**
 * Mock get contacts for development
 */
export async function getContactsMock(): Promise<Contact[]> {
  await new Promise((resolve) => setTimeout(resolve, 200));

  return MOCK_USERS.filter((u) => u.isContact).map((user) => ({
    user,
    nickname: undefined,
    addedAt: new Date(Date.now() - Math.random() * 30 * 86400000).toISOString(),
    isFavorite: Math.random() > 0.7,
  }));
}
