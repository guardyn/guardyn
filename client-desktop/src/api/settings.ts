/**
 * Settings API
 *
 * Handles user preferences and application settings.
 */

import { invoke } from '@tauri-apps/api/core';
import type { Settings } from '../types';

/**
 * Get current settings
 */
export async function getSettings(): Promise<Settings> {
  return invoke<Settings>('get_settings');
}

/**
 * Update settings
 */
export async function updateSettings(settings: Partial<Settings>): Promise<Settings> {
  return invoke<Settings>('update_settings', { settings });
}

/**
 * Reset settings to defaults
 */
export async function resetSettings(): Promise<Settings> {
  return invoke<Settings>('reset_settings');
}

/**
 * Export settings to file
 */
export async function exportSettings(path: string): Promise<void> {
  return invoke('export_settings', { path });
}

/**
 * Import settings from file
 */
export async function importSettings(path: string): Promise<Settings> {
  return invoke<Settings>('import_settings', { path });
}
