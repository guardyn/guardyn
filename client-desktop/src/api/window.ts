/**
 * Window State API
 * 
 * Provides functions for managing window state persistence.
 */

import { invoke } from '@tauri-apps/api/core';

export interface WindowState {
  x?: number;
  y?: number;
  width?: number;
  height?: number;
  maximized: boolean;
  fullscreen: boolean;
}

/**
 * Save the current window state to disk
 */
export async function saveWindowState(): Promise<void> {
  await invoke('save_window_state');
}

/**
 * Get the current window state
 */
export async function getWindowState(): Promise<WindowState> {
  return await invoke<WindowState>('get_window_state');
}
