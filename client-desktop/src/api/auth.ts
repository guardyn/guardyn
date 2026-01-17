/**
 * Authentication API
 *
 * Handles user authentication, registration, and session management.
 */

import { invoke } from '@tauri-apps/api/core';
import type { AuthResponse, UserInfo } from '../types';

export interface LoginRequest {
  username: string;
  password: string;
}

export interface RegisterRequest {
  username: string;
  password: string;
  display_name?: string;
}

/**
 * Login with username and password
 */
export async function login(request: LoginRequest): Promise<AuthResponse> {
  return invoke<AuthResponse>('login', { request });
}

/**
 * Register a new user
 */
export async function register(request: RegisterRequest): Promise<AuthResponse> {
  return invoke<AuthResponse>('register', { request });
}

/**
 * Logout the current user
 */
export async function logout(): Promise<void> {
  return invoke('logout');
}

/**
 * Get the current authenticated user
 */
export async function getCurrentUser(): Promise<UserInfo | null> {
  return invoke<UserInfo | null>('get_current_user');
}

/**
 * Search for users by query
 */
export async function searchUsers(query: string): Promise<UserInfo[]> {
  return invoke<UserInfo[]>('search_users', { query });
}
