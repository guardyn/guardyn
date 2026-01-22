/**
 * Guardyn Desktop API Module
 *
 * This module provides TypeScript wrappers for Tauri IPC commands,
 * exposing backend functionality to the frontend.
 */

export * from './auth';
export * from './calls';
export * from './media';
export * from './messaging';
export * from './settings';

// Crypto modules - renamed exports to avoid conflicts
export * as crypto from './crypto';
export * as mls from './mls';
export * as users from './users';
export * as websocket from './websocket';

// Named exports for individual functions (most common ones)
export {
    generateKeyBundle,
    hasIdentityKeys,
    isPqAvailable
} from './crypto';

export {
    createGroup as mlsCreateGroup, decryptMessage as mlsDecryptMessage, encryptMessage as mlsEncryptMessage, init as mlsInit, listGroups as mlsListGroups
} from './mls';

export {
    addContact, blockUser, getContacts,
    getContactsMock, getUserProfile,
    getUserProfileMock, removeContact, searchUsers,
    searchUsersMock, unblockUser
} from './users';

export type {
    Contact, UserProfile, UserSearchParams, UserSearchResult
} from './users';

export type {
    WebSocketConfig
} from './websocket';

// Media types
export type {
    DownloadUrlResult, GenerateThumbnailParams, GetUploadUrlParams, ListMediaParams, MediaListResult, MediaMetadata,
    MediaType, ThumbnailResult, UploadMediaFileParams, UploadStatus,
    UploadUrlResult
} from './media';

