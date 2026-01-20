/**
 * Guardyn Desktop API Module
 *
 * This module provides TypeScript wrappers for Tauri IPC commands,
 * exposing backend functionality to the frontend.
 */

export * from './auth';
export * from './calls';
export * from './messaging';
export * from './settings';

// Crypto modules - renamed exports to avoid conflicts
export * as crypto from './crypto';
export * as mls from './mls';
export * as websocket from './websocket';

// Named exports for individual functions (most common ones)
export {
  generateKeyBundle,
  hasIdentityKeys,
  isPqAvailable,
} from './crypto';

export {
  init as mlsInit,
  createGroup as mlsCreateGroup,
  listGroups as mlsListGroups,
  encryptMessage as mlsEncryptMessage,
  decryptMessage as mlsDecryptMessage,
} from './mls';

export type {
  WebSocketConfig,
} from './websocket';

