import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, onMount } from 'solid-js';
import type { Theme, UserSettings } from '../types';

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

  onMount(async () => {
    try {
      const userSettings = await invoke<UserSettings>('get_settings');
      setSettings(userSettings);
    } catch (err) {
      console.error('Failed to load settings:', err);
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

  return (
    <div class="p-8 max-w-2xl mx-auto">
      <h1 class="text-2xl font-bold text-white mb-8">Settings</h1>

      {/* Appearance */}
      <section class="mb-8">
        <h2 class="text-lg font-semibold text-white mb-4">Appearance</h2>
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div>
              <p class="text-white">Theme</p>
              <p class="text-sm text-gray-400">Choose your preferred color scheme</p>
            </div>
            <select
              value={settings().theme}
              onChange={(e) => updateSetting('theme', e.currentTarget.value as Theme)}
              class="px-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-guardyn-500"
            >
              <option value="light">Light</option>
              <option value="dark">Dark</option>
              <option value="system">System</option>
            </select>
          </div>

          <div class="flex items-center justify-between">
            <div>
              <p class="text-white">Language</p>
              <p class="text-sm text-gray-400">Select your language</p>
            </div>
            <select
              value={settings().language}
              onChange={(e) => updateSetting('language', e.currentTarget.value)}
              class="px-4 py-2 bg-gray-700 border border-gray-600 rounded-lg text-white focus:outline-none focus:ring-2 focus:ring-guardyn-500"
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
        <h2 class="text-lg font-semibold text-white mb-4">Notifications</h2>
        <div class="space-y-4">
          <label class="flex items-center justify-between cursor-pointer">
            <div>
              <p class="text-white">Enable notifications</p>
              <p class="text-sm text-gray-400">Receive desktop notifications</p>
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
                  settings().notifications_enabled ? 'bg-guardyn-600' : 'bg-gray-600'
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
              <p class="text-white">Sound</p>
              <p class="text-sm text-gray-400">Play sounds for notifications</p>
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
                  settings().sound_enabled ? 'bg-guardyn-600' : 'bg-gray-600'
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
              <p class="text-white">Show message preview</p>
              <p class="text-sm text-gray-400">Show message content in notifications</p>
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
                  settings().show_message_preview ? 'bg-guardyn-600' : 'bg-gray-600'
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
        <h2 class="text-lg font-semibold text-white mb-4">Security</h2>
        <div class="space-y-4">
          <div class="bg-gray-800 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-white">Export encryption keys</p>
                <p class="text-sm text-gray-400">
                  Back up your keys to restore conversations on another device
                </p>
              </div>
              <button
                onClick={handleExportKeys}
                class="px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg transition"
              >
                Export
              </button>
            </div>
          </div>

          <div class="bg-gray-800 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div>
                <p class="text-white">View identity key</p>
                <p class="text-sm text-gray-400">
                  Your unique cryptographic identity fingerprint
                </p>
              </div>
              <button class="px-4 py-2 bg-gray-700 hover:bg-gray-600 text-white rounded-lg transition">
                View
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Save indicator */}
      <div class="fixed bottom-4 right-4">
        {saving() && (
          <div class="bg-gray-800 text-white px-4 py-2 rounded-lg flex items-center">
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
