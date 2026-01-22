/**
 * ProfileSection Component
 *
 * Displays and allows editing of user profile information.
 * Supports avatar upload, display name, and bio editing.
 */

import { invoke } from '@tauri-apps/api/core';
import { stat } from '@tauri-apps/plugin-fs';
import { Component, createEffect, createSignal, Show } from 'solid-js';
import { uploadMedia } from '../api/media';
import { MediaPicker, UploadProgress, type UploadItem } from './media';
import { Avatar, Button, TextInput } from './shared';

// =============================================================================
// TYPES
// =============================================================================

export interface UserProfile {
  id: string;
  username: string;
  display_name: string;
  bio?: string;
  avatar_url?: string;
  avatar_id?: string;
}

export interface ProfileSectionProps {
  /** Initial profile data */
  profile?: UserProfile;
  /** Whether the profile is editable */
  editable?: boolean;
  /** Callback when profile is updated */
  onProfileUpdate?: (profile: UserProfile) => void;
  /** Additional CSS classes */
  class?: string;
}

// =============================================================================
// CONSTANTS
// =============================================================================

const MAX_DISPLAY_NAME_LENGTH = 50;
const MAX_BIO_LENGTH = 160;

// =============================================================================
// COMPONENT
// =============================================================================

/**
 * ProfileSection displays user profile with optional editing capabilities.
 *
 * @example
 * ```tsx
 * <ProfileSection
 *   profile={currentUser}
 *   editable={true}
 *   onProfileUpdate={handleProfileUpdate}
 * />
 * ```
 */
export const ProfileSection: Component<ProfileSectionProps> = (props) => {
  // State
  const [isEditing, setIsEditing] = createSignal(false);
  const [displayName, setDisplayName] = createSignal('');
  const [bio, setBio] = createSignal('');
  const [avatarUrl, setAvatarUrl] = createSignal<string | undefined>(undefined);
  const [isSaving, setIsSaving] = createSignal(false);
  const [isUploadingAvatar, setIsUploadingAvatar] = createSignal(false);
  const [avatarUploadItem, setAvatarUploadItem] = createSignal<UploadItem | null>(null);
  const [hasChanges, setHasChanges] = createSignal(false);
  const [error, setError] = createSignal<string | null>(null);

  // Initialize from props
  createEffect(() => {
    if (props.profile) {
      setDisplayName(props.profile.display_name || '');
      setBio(props.profile.bio || '');
      setAvatarUrl(props.profile.avatar_url);
    }
  });

  // Track changes
  createEffect(() => {
    if (props.profile) {
      const nameChanged = displayName() !== (props.profile.display_name || '');
      const bioChanged = bio() !== (props.profile.bio || '');
      setHasChanges(nameChanged || bioChanged);
    }
  });

  // Handle avatar selection
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
      setError('Failed to read file');
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
    setError(null);
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
      setAvatarUploadItem((prev) =>
        prev ? { ...prev, status: 'completed', uploadedBytes: sizeBytes } : null
      );

      // Fetch updated avatar URL
      const profile = await invoke<UserProfile>('get_current_user');
      setAvatarUrl(profile.avatar_url);

      // Notify parent
      if (props.onProfileUpdate && props.profile) {
        props.onProfileUpdate({ ...props.profile, avatar_url: profile.avatar_url });
      }
    } catch (err) {
      console.error('Failed to upload avatar:', err);
      setError('Failed to upload avatar');
      setAvatarUploadItem((prev) =>
        prev ? { ...prev, status: 'failed', error: String(err) } : null
      );
    } finally {
      setIsUploadingAvatar(false);
      setTimeout(() => setAvatarUploadItem(null), 3000);
    }
  };

  // Handle remove avatar
  const handleRemoveAvatar = async () => {
    try {
      await invoke('remove_user_avatar');
      setAvatarUrl(undefined);

      if (props.onProfileUpdate && props.profile) {
        props.onProfileUpdate({ ...props.profile, avatar_url: undefined });
      }
    } catch (err) {
      console.error('Failed to remove avatar:', err);
      setError('Failed to remove avatar');
    }
  };

  // Handle save
  const handleSave = async () => {
    if (!hasChanges()) return;

    setIsSaving(true);
    setError(null);

    try {
      await invoke('update_user_profile', {
        displayName: displayName(),
        bio: bio(),
      });

      // Notify parent
      if (props.onProfileUpdate && props.profile) {
        props.onProfileUpdate({
          ...props.profile,
          display_name: displayName(),
          bio: bio(),
        });
      }

      setIsEditing(false);
      setHasChanges(false);
    } catch (err) {
      console.error('Failed to update profile:', err);
      setError('Failed to save profile');
    } finally {
      setIsSaving(false);
    }
  };

  // Handle cancel
  const handleCancel = () => {
    if (props.profile) {
      setDisplayName(props.profile.display_name || '');
      setBio(props.profile.bio || '');
    }
    setIsEditing(false);
    setHasChanges(false);
    setError(null);
  };

  return (
    <div class={`bg-white dark:bg-neutral-900 rounded-xl ${props.class ?? ''}`}>
      {/* Header */}
      <div class="flex items-center justify-between px-6 py-4 border-b border-neutral-200 dark:border-neutral-800">
        <h2 class="text-lg font-semibold text-neutral-900 dark:text-white">Profile</h2>
        <Show when={props.editable && !isEditing()}>
          <button
            onClick={() => setIsEditing(true)}
            class="text-sm text-guardyn-600 dark:text-guardyn-400 hover:underline"
          >
            Edit
          </button>
        </Show>
      </div>

      {/* Content */}
      <div class="p-6">
        {/* Avatar section */}
        <div class="flex items-start gap-6 mb-6">
          <div class="relative group flex-shrink-0">
            <Avatar name={displayName()} src={avatarUrl()} size="xl" />

            {/* Upload overlay */}
            <Show when={props.editable}>
              <div class="absolute inset-0 flex items-center justify-center bg-black/50 rounded-full opacity-0 group-hover:opacity-100 transition-opacity">
                <MediaPicker
                  mode="images"
                  multiple={false}
                  onSelect={handleAvatarSelect}
                  disabled={isUploadingAvatar()}
                >
                  <div class="flex flex-col items-center text-white cursor-pointer">
                    <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z"
                      />
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M15 13a3 3 0 11-6 0 3 3 0 016 0z"
                      />
                    </svg>
                    <span class="text-xs mt-1">Change</span>
                  </div>
                </MediaPicker>
              </div>
            </Show>

            {/* Loading indicator */}
            <Show when={isUploadingAvatar()}>
              <div class="absolute inset-0 flex items-center justify-center bg-black/70 rounded-full">
                <svg class="animate-spin h-8 w-8 text-white" viewBox="0 0 24 24">
                  <circle
                    class="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    stroke-width="4"
                    fill="none"
                  />
                  <path
                    class="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                  />
                </svg>
              </div>
            </Show>
          </div>

          <div class="flex-1 min-w-0">
            <Show when={avatarUrl() && props.editable}>
              <button
                onClick={handleRemoveAvatar}
                class="text-sm text-red-600 dark:text-red-400 hover:underline"
              >
                Remove photo
              </button>
            </Show>

            {/* Upload progress */}
            <Show when={avatarUploadItem()}>
              <div class="mt-2">
                <UploadProgress items={[avatarUploadItem()!]} onCancel={() => setAvatarUploadItem(null)} />
              </div>
            </Show>
          </div>
        </div>

        {/* Profile fields */}
        <div class="space-y-4">
          {/* Username (read-only) */}
          <div>
            <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-1">
              Username
            </label>
            <div class="text-neutral-900 dark:text-white">@{props.profile?.username || 'user'}</div>
          </div>

          {/* Display Name */}
          <div>
            <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-1">
              Display Name
            </label>
            <Show
              when={isEditing()}
              fallback={
                <div class="text-neutral-900 dark:text-white">{displayName() || 'Not set'}</div>
              }
            >
              <TextInput
                value={displayName()}
                onInput={(e) => setDisplayName(e.currentTarget.value)}
                placeholder="Your display name"
                maxLength={MAX_DISPLAY_NAME_LENGTH}
              />
              <div class="text-xs text-neutral-500 mt-1">
                {displayName().length}/{MAX_DISPLAY_NAME_LENGTH}
              </div>
            </Show>
          </div>

          {/* Bio */}
          <div>
            <label class="block text-sm font-medium text-neutral-700 dark:text-neutral-300 mb-1">
              Bio
            </label>
            <Show
              when={isEditing()}
              fallback={
                <div class="text-neutral-600 dark:text-neutral-400">
                  {bio() || 'No bio set'}
                </div>
              }
            >
              <textarea
                value={bio()}
                onInput={(e) => setBio(e.currentTarget.value)}
                placeholder="Tell us about yourself..."
                maxLength={MAX_BIO_LENGTH}
                rows={3}
                class="w-full px-4 py-2 bg-neutral-100 dark:bg-neutral-800 border border-neutral-300 dark:border-neutral-700 rounded-lg text-neutral-900 dark:text-white placeholder-neutral-500 focus:outline-none focus:ring-2 focus:ring-guardyn-500 resize-none"
              />
              <div class="text-xs text-neutral-500 mt-1">
                {bio().length}/{MAX_BIO_LENGTH}
              </div>
            </Show>
          </div>
        </div>

        {/* Error message */}
        <Show when={error()}>
          <div class="mt-4 p-3 bg-red-50 dark:bg-red-900/20 text-red-600 dark:text-red-400 text-sm rounded-lg">
            {error()}
          </div>
        </Show>

        {/* Action buttons */}
        <Show when={isEditing()}>
          <div class="flex gap-3 mt-6">
            <Button variant="secondary" onClick={handleCancel} disabled={isSaving()}>
              Cancel
            </Button>
            <Button onClick={handleSave} disabled={!hasChanges() || isSaving()}>
              {isSaving() ? 'Saving...' : 'Save Changes'}
            </Button>
          </div>
        </Show>
      </div>
    </div>
  );
};

export default ProfileSection;
