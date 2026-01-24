/**
 * Profile Page
 *
 * User profile page with avatar, display name, and bio editing.
 */

import { useNavigate } from '@solidjs/router';
import { invoke } from '@tauri-apps/api/core';
import { Component, createSignal, onMount, Show } from 'solid-js';
import { ProfileSection, type UserProfile } from '../components';

const Profile: Component = () => {
  const navigate = useNavigate();
  const [profile, setProfile] = createSignal<UserProfile | null>(null);
  const [loading, setLoading] = createSignal(true);
  const [error, setError] = createSignal<string | null>(null);

  onMount(async () => {
    try {
      const userData = await invoke<UserProfile>('get_current_user');
      setProfile(userData);
    } catch (err) {
      console.error('Failed to load profile:', err);
      setError('Failed to load profile');
      // Use mock data for development
      setProfile({
        id: 'user-1',
        username: 'johndoe',
        display_name: 'John Doe',
        bio: 'Privacy enthusiast. Secure communication advocate.',
        avatar_url: undefined,
      });
    } finally {
      setLoading(false);
    }
  });

  const handleProfileUpdate = (updatedProfile: UserProfile) => {
    setProfile(updatedProfile);
  };

  const goBack = () => {
    navigate(-1);
  };

  return (
    <div class="flex flex-col h-full bg-neutral-50 dark:bg-neutral-950">
      {/* Header */}
      <header class="flex items-center gap-4 px-4 py-3 bg-white dark:bg-neutral-900 border-b border-neutral-200 dark:border-neutral-800">
        <button
          onClick={goBack}
          class="p-2 hover:bg-neutral-100 dark:hover:bg-neutral-800 rounded-lg transition-colors"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </button>
        <h1 class="text-lg font-semibold text-neutral-900 dark:text-white">Your Profile</h1>
      </header>

      {/* Content */}
      <div class="flex-1 overflow-y-auto p-4">
        <div class="max-w-2xl mx-auto">
          {/* Loading state */}
          <Show when={loading()}>
            <div class="flex items-center justify-center h-64">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-guardyn-500" />
            </div>
          </Show>

          {/* Error state */}
          <Show when={!loading() && error() && !profile()}>
            <div class="bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 p-4 rounded-xl text-center">
              {error()}
            </div>
          </Show>

          {/* Profile section */}
          <Show when={!loading() && profile()}>
            <ProfileSection
              profile={profile()!}
              editable={true}
              onProfileUpdate={handleProfileUpdate}
            />

            {/* Additional info */}
            <div class="mt-6 bg-white dark:bg-neutral-900 rounded-xl">
              <div class="px-6 py-4 border-b border-neutral-200 dark:border-neutral-800">
                <h2 class="text-lg font-semibold text-neutral-900 dark:text-white">Account</h2>
              </div>
              <div class="p-6 space-y-4">
                <div class="flex items-center justify-between">
                  <div>
                    <p class="text-neutral-900 dark:text-white">Security Settings</p>
                    <p class="text-sm text-neutral-500 dark:text-neutral-400">
                      Manage encryption keys and security options
                    </p>
                  </div>
                  <button
                    onClick={() => navigate('/settings')}
                    class="px-4 py-2 bg-neutral-100 dark:bg-neutral-800 hover:bg-neutral-200 dark:hover:bg-neutral-700 text-neutral-900 dark:text-white rounded-lg transition-colors"
                  >
                    Settings
                  </button>
                </div>

                <div class="flex items-center justify-between pt-4 border-t border-neutral-200 dark:border-neutral-800">
                  <div>
                    <p class="text-neutral-900 dark:text-white">Privacy</p>
                    <p class="text-sm text-neutral-500 dark:text-neutral-400">
                      Control who can see your profile
                    </p>
                  </div>
                  <span class="text-sm text-neutral-500 dark:text-neutral-400">
                    Contacts only
                  </span>
                </div>

                <div class="flex items-center justify-between pt-4 border-t border-neutral-200 dark:border-neutral-800">
                  <div>
                    <p class="text-neutral-900 dark:text-white">Account Created</p>
                    <p class="text-sm text-neutral-500 dark:text-neutral-400">
                      Your Guardyn account creation date
                    </p>
                  </div>
                  <span class="text-sm text-neutral-500 dark:text-neutral-400">
                    January 2026
                  </span>
                </div>
              </div>
            </div>
          </Show>
        </div>
      </div>
    </div>
  );
};

export default Profile;
