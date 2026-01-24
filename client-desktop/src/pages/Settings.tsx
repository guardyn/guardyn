import { invoke } from '@tauri-apps/api/core';
import { stat } from '@tauri-apps/plugin-fs';
import { Component, createSignal, onMount, Show } from 'solid-js';
import { uploadMedia } from '../api/media';
import { MediaPicker, UploadProgress, type UploadItem } from '../components/media';
import { Avatar } from '../components/shared';
import { ThemeSwitcher } from '../components/ThemeSwitcher';
import type { UserSettings } from '../types';

interface SettingsPageProps {}

const Settings: Component<SettingsPageProps> = () => {
  const [settings, setSettings] = createSignal<UserSettings>({
    theme: 'dark',
    notifications_enabled: true,
    sound_enabled: true,
    show_message_preview: true,
    language: 'en',
  });
  const [saving, setSaving] = createSignal(false);
  const [saved, setSaved] = createSignal(false);
  const [displayName, setDisplayName] = createSignal('');
  const [avatarUrl, setAvatarUrl] = createSignal<string | undefined>(undefined);
  const [isUploadingAvatar, setIsUploadingAvatar] = createSignal(false);
  const [avatarUploadItem, setAvatarUploadItem] = createSignal<UploadItem | null>(null);

  onMount(async () => {
    try {
      const userSettings = await invoke<UserSettings>('get_settings');
      setSettings(userSettings);
    } catch (err) {
      console.error('Failed to load settings:', err);
    }

    // Load user profile
    try {
      const profile = await invoke<{ display_name: string; avatar_url?: string }>('get_current_user');
      setDisplayName(profile.display_name || 'User');
      setAvatarUrl(profile.avatar_url);
    } catch (err) {
      console.error('Failed to load profile:', err);
      setDisplayName('User');
    }
  });

  const updateSetting = async <K extends keyof UserSettings>(key: K, value: UserSettings[K]) => {
    setSettings((prev) => ({ ...prev, [key]: value }));
    setSaving(true);
    setSaved(false);

    try {
      await invoke('update_settings', { key, value });
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err) {
      console.error('Failed to save settings:', err);
    } finally {
      setSaving(false);
    }
  };

  const handleExportKeys = async () => {
    try {
      await invoke('export_keys');
    } catch (err) {
      console.error('Failed to export keys:', err);
    }
  };

  const handleAvatarSelect = async (files: string[]) => {
    if (files.length === 0) return;

    const filePath = files[0];
    const filename = filePath.split('/').pop() || 'avatar';
    
    // Get file info
    let sizeBytes = 0;
    try {
      const fileInfo = await stat(filePath);
      sizeBytes = fileInfo.size;
    } catch (err) {
      console.error('Failed to get file info:', err);
      return;
    }

    // Determine MIME type
    const ext = filename.split('.').pop()?.toLowerCase() || '';
    const mimeTypes: Record<string, string> = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      gif: 'image/gif',
      webp: 'image/webp',
    };
    const mimeType = mimeTypes[ext] || 'image/jpeg';

    setIsUploadingAvatar(true);
    setAvatarUploadItem({
      id: 'avatar-upload',
      filename,
      status: 'uploading',
      totalBytes: sizeBytes,
      uploadedBytes: 0,
    });

    try {
      // Upload the avatar
      const mediaId = await uploadMedia(filePath, filename, mimeType, sizeBytes);

      // Update user profile with new avatar
      await invoke('update_user_avatar', { mediaId });

      // Update local state
      setAvatarUploadItem((prev) => prev ? { ...prev, status: 'completed', uploadedBytes: sizeBytes } : null);
      
      // Fetch updated avatar URL
      const profile = await invoke<{ display_name: string; avatar_url?: string }>('get_current_user');
      setAvatarUrl(profile.avatar_url);

      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err) {
      console.error('Failed to upload avatar:', err);
      setAvatarUploadItem((prev) => prev ? { ...prev, status: 'failed', error: String(err) } : null);
    } finally {
      setIsUploadingAvatar(false);
      setTimeout(() => setAvatarUploadItem(null), 3000);
    }
  };

  const handleRemoveAvatar = async () => {
    try {
      await invoke('remove_user_avatar');
      setAvatarUrl(undefined);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } catch (err) {
      console.error('Failed to remove avatar:', err);
    }
  };

  return (
    <div class="p-8 max-w-2xl mx-auto">
      <h1 class="text-2xl font-bold text-gray-900 dark:text-white mb-8">Settings</h1>

      {/* Profile */}
      <section class="mb-8">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Profile</h2>
        <div class="bg-gray-100 dark:bg-gray-800 rounded-lg p-6">
          <div class="flex items-center gap-6">
            {/* Avatar */}
            <div class="relative group">
              <Avatar
                name={displayName()}
                src={avatarUrl()}
                size="xl"
              />
              
              {/* Upload overlay */}
              <div class="absolute inset-0 flex items-center justify-center bg-black/50 rounded-full opacity-0 group-hover:opacity-100 transition-opacity">
                <MediaPicker
                  mode="images"
                  multiple={false}
                  onSelect={handleAvatarSelect}
                  disabled={isUploadingAvatar()}
                >
                  <div class="flex flex-col items-center text-white cursor-pointer">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
                    </svg>
                    <span class="text-xs mt-1">Change</span>
                  </div>
                </MediaPicker>
              </div>

              {/* Loading indicator */}
              <Show when={isUploadingAvatar()}>
                <div class="absolute inset-0 flex items-center justify-center bg-black/70 rounded-full">
                  <svg class="animate-spin h-8 w-8 text-white" viewBox="0 0 24 24">
                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
                  </svg>
                </div>
              </Show>
            </div>

            {/* Profile info */}
            <div class="flex-1">
              <h3 class="text-xl font-semibold text-gray-900 dark:text-white">
                {displayName()}
              </h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
                Click avatar to change your profile picture
              </p>
              
              <Show when={avatarUrl()}>
                <button
                  onClick={handleRemoveAvatar}
                  class="mt-3 text-sm text-red-600 dark:text-red-400 hover:underline"
                >
                  Remove avatar
                </button>
              </Show>
            </div>
          </div>

          {/* Upload progress */}
          <Show when={avatarUploadItem()}>
            <div class="mt-4">
              <UploadProgress
                items={[avatarUploadItem()!]}
                onCancel={() => setAvatarUploadItem(null)}
              />
            </div>
          </Show>
        </div>
      </section>

      {/* Appearance */}
      <section class="mb-8">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Appearance</h2>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-gray-900 dark:text-white">Theme</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">Choose your preferred color scheme</p>
            </div>
            <ThemeSwitcher />
          </div>

          <div class="flex items-center justify-between">
            <div>
              <p class="text-gray-900 dark:text-white">Language</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">Select your language</p>
            </div>
            <select
              value={settings().language}
              onChange={(e) => updateSetting('language', e.currentTarget.value)}
              class="px-4 py-2 bg-gray-100 dark:bg-gray-700 border border-gray-300 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-guardyn-500"
            >
              <option value="en">English</option>
              <option value="de">Deutsch</option>
              <option value="fr">Français</option>
              <option value="es">Español</option>
            </select>
          </div>
        </div>
      </section>

      {/* Notifications */}
      <section class="mb-8">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Notifications</h2>
        <div class="space-y-4">
          <label class="flex items-center justify-between cursor-pointer">
            <div>
              <p class="text-gray-900 dark:text-white">Enable notifications</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">Receive desktop notifications</p>
            </div>
            <div class="relative">
              <input
                type="checkbox"
                checked={settings().notifications_enabled}
                onChange={(e) => updateSetting('notifications_enabled', e.currentTarget.checked)}
                class="sr-only"
              />
              <div
                class={`w-11 h-6 rounded-full transition ${
                  settings().notifications_enabled ? 'bg-guardyn-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <div
                  class={`w-5 h-5 bg-white rounded-full transition transform ${
                    settings().notifications_enabled ? 'translate-x-5' : 'translate-x-0.5'
                  } mt-0.5`}
                />
              </div>
            </div>
          </label>

          <label class="flex items-center justify-between cursor-pointer">
            <div>
              <p class="text-gray-900 dark:text-white">Sound</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">Play sounds for notifications</p>
            </div>
            <div class="relative">
              <input
                type="checkbox"
                checked={settings().sound_enabled}
                onChange={(e) => updateSetting('sound_enabled', e.currentTarget.checked)}
                class="sr-only"
              />
              <div
                class={`w-11 h-6 rounded-full transition ${
                  settings().sound_enabled ? 'bg-guardyn-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <div
                  class={`w-5 h-5 bg-white rounded-full transition transform ${
                    settings().sound_enabled ? 'translate-x-5' : 'translate-x-0.5'
                  } mt-0.5`}
                />
              </div>
            </div>
          </label>

          <label class="flex items-center justify-between cursor-pointer">
            <div>
              <p class="text-gray-900 dark:text-white">Show message preview</p>
              <p class="text-sm text-gray-500 dark:text-gray-400">Show message content in notifications</p>
            </div>
            <div class="relative">
              <input
                type="checkbox"
                checked={settings().show_message_preview}
                onChange={(e) => updateSetting('show_message_preview', e.currentTarget.checked)}
                class="sr-only"
              />
              <div
                class={`w-11 h-6 rounded-full transition ${
                  settings().show_message_preview ? 'bg-guardyn-600' : 'bg-gray-300 dark:bg-gray-600'
                }`}
              >
                <div
                  class={`w-5 h-5 bg-white rounded-full transition transform ${
                    settings().show_message_preview ? 'translate-x-5' : 'translate-x-0.5'
                  } mt-0.5`}
                />
              </div>
            </div>
          </label>
        </div>
      </section>

      {/* Security */}
      <section class="mb-8">
        <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Security</h2>
        <div class="space-y-4">
          <div class="bg-gray-100 dark:bg-gray-800 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-gray-900 dark:text-white">Export encryption keys</p>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Back up your keys to restore conversations on another device
                </p>
              </div>
              <button
                onClick={handleExportKeys}
                class="px-4 py-2 bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 text-gray-900 dark:text-white rounded-lg transition"
              >
                Export
              </button>
            </div>
          </div>

          <div class="bg-gray-100 dark:bg-gray-800 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-gray-900 dark:text-white">View identity key</p>
                <p class="text-sm text-gray-500 dark:text-gray-400">
                  Your unique cryptographic identity fingerprint
                </p>
              </div>
              <button class="px-4 py-2 bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 text-gray-900 dark:text-white rounded-lg transition">
                View
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Save indicator */}
      <div class="fixed bottom-4 right-4">
        {saving() && (
          <div class="bg-gray-200 dark:bg-gray-800 text-gray-900 dark:text-white px-4 py-2 rounded-lg flex items-center shadow-lg">
            <svg class="animate-spin h-4 w-4 mr-2" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
            Saving...
          </div>
        )}
        {saved() && (
          <div class="bg-guardyn-600 text-white px-4 py-2 rounded-lg flex items-center animate-fade-in">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
            </svg>
            Saved
          </div>
        )}
      </div>
    </div>
  );
};

export default Settings;
