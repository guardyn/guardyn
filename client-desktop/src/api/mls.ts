/**
 * MLS (Messaging Layer Security) API
 *
 * TypeScript wrappers for Tauri MLS commands.
 * Provides group chat encryption via OpenMLS library.
 *
 * @module api/mls
 */

import { invoke } from '@tauri-apps/api/core';

// =============================================================================
// TYPES
// =============================================================================

/**
 * MLS key package for group membership
 */
export interface MlsKeyPackage {
  /** Unique package identifier (hex) */
  packageId: string;
  /** Serialized key package (base64) */
  keyPackage: string;
  /** Creation timestamp (Unix seconds) */
  createdAt: number;
}

/**
 * MLS group information
 */
export interface MlsGroupInfo {
  /** Group ID (hex) */
  groupId: string;
  /** Group display name */
  name: string;
  /** Current MLS epoch */
  epoch: number;
  /** Number of members */
  memberCount: number;
  /** Messages sent in this group */
  messagesSent: number;
  /** Messages received in this group */
  messagesReceived: number;
  /** Last activity timestamp (Unix seconds) */
  lastActivity: number;
}

/**
 * Result of creating an MLS group
 */
export interface MlsGroupCreateResult {
  /** Group ID (hex) */
  groupId: string;
  /** Initial epoch (always 0) */
  epoch: number;
  /** Serialized group state (base64) */
  state: string;
}

/**
 * Result of adding a member to an MLS group
 */
export interface MlsAddMemberResult {
  /** Serialized commit message (base64) - send to existing members */
  commit: string;
  /** Serialized welcome message (base64) - send to new member */
  welcome: string;
  /** New epoch after adding member */
  epoch: number;
}

/**
 * Result of removing a member from an MLS group
 */
export interface MlsRemoveMemberResult {
  /** Serialized commit message (base64) - send to remaining members */
  commit: string;
  /** New epoch after removing member */
  epoch: number;
}

/**
 * Encrypted MLS group message
 */
export interface MlsEncryptedMessage {
  /** Serialized encrypted message (base64) */
  ciphertext: string;
  /** Group ID this message belongs to (hex) */
  groupId: string;
  /** Epoch at which message was encrypted */
  epoch: number;
}

/**
 * Decrypted MLS group message
 */
export interface MlsDecryptedMessage {
  /** Decrypted plaintext */
  plaintext: string;
  /** Sender identity (hex) */
  senderId: string;
  /** Epoch at which message was sent */
  epoch: number;
}

// =============================================================================
// INITIALIZATION
// =============================================================================

/**
 * Initialize MLS for the current user
 *
 * Must be called before any other MLS operations.
 * Generates a signature keypair for MLS protocol operations.
 *
 * @param userId - User ID
 * @param deviceId - Device ID
 * @returns True if initialization successful
 */
export async function init(userId: string, deviceId: string): Promise<boolean> {
  return invoke<boolean>('mls_init', { userId, deviceId });
}

/**
 * Check if MLS is initialized
 *
 * @returns True if MLS is initialized and ready
 */
export async function isInitialized(): Promise<boolean> {
  return invoke<boolean>('mls_is_initialized');
}

// =============================================================================
// KEY PACKAGE MANAGEMENT
// =============================================================================

/**
 * Generate a new MLS key package
 *
 * Key packages are pre-generated and uploaded to the server.
 * They are consumed when users are added to groups.
 *
 * @returns Generated key package data
 */
export async function generateKeyPackage(): Promise<MlsKeyPackage> {
  const result = await invoke<{
    package_id: string;
    key_package: string;
    created_at: number;
  }>('mls_generate_key_package');

  return {
    packageId: result.package_id,
    keyPackage: result.key_package,
    createdAt: result.created_at,
  };
}

/**
 * Generate multiple key packages at once
 *
 * @param count - Number of key packages to generate
 * @returns Array of generated key packages
 */
export async function generateKeyPackages(count: number): Promise<MlsKeyPackage[]> {
  const results = await invoke<
    Array<{
      package_id: string;
      key_package: string;
      created_at: number;
    }>
  >('mls_generate_key_packages', { count });

  return results.map((r) => ({
    packageId: r.package_id,
    keyPackage: r.key_package,
    createdAt: r.created_at,
  }));
}

// =============================================================================
// GROUP MANAGEMENT
// =============================================================================

/**
 * Create a new MLS group
 *
 * The caller becomes the initial group admin/creator.
 *
 * @param groupId - Unique group identifier
 * @param name - Display name for the group
 * @returns Group creation result with initial state
 */
export async function createGroup(
  groupId: string,
  name: string
): Promise<MlsGroupCreateResult> {
  const result = await invoke<{
    group_id: string;
    epoch: number;
    state: string;
  }>('mls_create_group', { groupId, name });

  return {
    groupId: result.group_id,
    epoch: result.epoch,
    state: result.state,
  };
}

/**
 * Get information about an MLS group
 *
 * @param groupId - Group ID
 * @returns Group info or null if not found
 */
export async function getGroup(groupId: string): Promise<MlsGroupInfo | null> {
  const result = await invoke<{
    group_id: string;
    name: string;
    epoch: number;
    member_count: number;
    messages_sent: number;
    messages_received: number;
    last_activity: number;
  } | null>('mls_get_group', { groupId });

  if (!result) return null;

  return {
    groupId: result.group_id,
    name: result.name,
    epoch: result.epoch,
    memberCount: result.member_count,
    messagesSent: result.messages_sent,
    messagesReceived: result.messages_received,
    lastActivity: result.last_activity,
  };
}

/**
 * List all MLS groups
 *
 * @returns Array of group info
 */
export async function listGroups(): Promise<MlsGroupInfo[]> {
  const results = await invoke<
    Array<{
      group_id: string;
      name: string;
      epoch: number;
      member_count: number;
      messages_sent: number;
      messages_received: number;
      last_activity: number;
    }>
  >('mls_list_groups');

  return results.map((r) => ({
    groupId: r.group_id,
    name: r.name,
    epoch: r.epoch,
    memberCount: r.member_count,
    messagesSent: r.messages_sent,
    messagesReceived: r.messages_received,
    lastActivity: r.last_activity,
  }));
}

/**
 * Delete an MLS group (leave and remove local state)
 *
 * @param groupId - Group ID to delete
 * @returns True if group was deleted
 */
export async function deleteGroup(groupId: string): Promise<boolean> {
  return invoke<boolean>('mls_delete_group', { groupId });
}

// =============================================================================
// MEMBER MANAGEMENT
// =============================================================================

/**
 * Add a member to an MLS group
 *
 * Requires the member's key package (obtained from server).
 *
 * @param groupId - Group ID
 * @param memberKeyPackage - Member's key package (base64)
 * @returns Commit and welcome messages
 */
export async function addMember(
  groupId: string,
  memberKeyPackage: string
): Promise<MlsAddMemberResult> {
  const result = await invoke<{
    commit: string;
    welcome: string;
    epoch: number;
  }>('mls_add_member', { groupId, memberKeyPackage });

  return {
    commit: result.commit,
    welcome: result.welcome,
    epoch: result.epoch,
  };
}

/**
 * Remove a member from an MLS group
 *
 * Only group admins can remove members.
 *
 * @param groupId - Group ID
 * @param memberIndex - Index of the member to remove (leaf node index)
 * @returns Commit message for remaining members
 */
export async function removeMember(
  groupId: string,
  memberIndex: number
): Promise<MlsRemoveMemberResult> {
  const result = await invoke<{
    commit: string;
    epoch: number;
  }>('mls_remove_member', { groupId, memberIndex });

  return {
    commit: result.commit,
    epoch: result.epoch,
  };
}

/**
 * Join an MLS group using a Welcome message
 *
 * @param welcome - Welcome message (base64)
 * @param groupName - Display name for the group
 * @returns Group info after joining
 */
export async function joinGroup(
  welcome: string,
  groupName: string
): Promise<MlsGroupInfo> {
  const result = await invoke<{
    group_id: string;
    name: string;
    epoch: number;
    member_count: number;
    messages_sent: number;
    messages_received: number;
    last_activity: number;
  }>('mls_join_group', { welcome, groupName });

  return {
    groupId: result.group_id,
    name: result.name,
    epoch: result.epoch,
    memberCount: result.member_count,
    messagesSent: result.messages_sent,
    messagesReceived: result.messages_received,
    lastActivity: result.last_activity,
  };
}

/**
 * Process an incoming commit message from another member
 *
 * @param groupId - Group ID
 * @param commit - Commit message (base64)
 * @returns New epoch after processing commit
 */
export async function processCommit(groupId: string, commit: string): Promise<number> {
  return invoke<number>('mls_process_commit', { groupId, commit });
}

// =============================================================================
// MESSAGE ENCRYPTION
// =============================================================================

/**
 * Encrypt a message for an MLS group
 *
 * @param groupId - Group ID
 * @param plaintext - Message to encrypt
 * @returns Encrypted message data
 */
export async function encryptMessage(
  groupId: string,
  plaintext: string
): Promise<MlsEncryptedMessage> {
  const result = await invoke<{
    ciphertext: string;
    group_id: string;
    epoch: number;
  }>('mls_encrypt_message', { groupId, plaintext });

  return {
    ciphertext: result.ciphertext,
    groupId: result.group_id,
    epoch: result.epoch,
  };
}

/**
 * Decrypt an MLS group message
 *
 * @param groupId - Group ID
 * @param ciphertext - Encrypted message (base64)
 * @returns Decrypted message data
 */
export async function decryptMessage(
  groupId: string,
  ciphertext: string
): Promise<MlsDecryptedMessage> {
  const result = await invoke<{
    plaintext: string;
    sender_id: string;
    epoch: number;
  }>('mls_decrypt_message', { groupId, ciphertext });

  return {
    plaintext: result.plaintext,
    senderId: result.sender_id,
    epoch: result.epoch,
  };
}

// =============================================================================
// UTILITY
// =============================================================================

/**
 * Clear all MLS state (logout/reset)
 */
export async function clearState(): Promise<void> {
  await invoke('mls_clear_state');
}

/**
 * Get MLS library version
 *
 * @returns Version string (e.g., "openmls 0.6.x")
 */
export async function getVersion(): Promise<string> {
  return invoke<string>('mls_get_version');
}

// =============================================================================
// NAMESPACE EXPORT
// =============================================================================

/**
 * MLS API namespace
 *
 * Usage:
 * ```typescript
 * import * as mls from './api/mls';
 *
 * // Initialize
 * await mls.init('user123', 'device456');
 *
 * // Create a group
 * const group = await mls.createGroup('group-id', 'Team Chat');
 *
 * // Encrypt a message
 * const encrypted = await mls.encryptMessage('group-id', 'Hello, team!');
 * ```
 */
export const mlsApi = {
  init,
  isInitialized,
  generateKeyPackage,
  generateKeyPackages,
  createGroup,
  getGroup,
  listGroups,
  deleteGroup,
  addMember,
  removeMember,
  joinGroup,
  processCommit,
  encryptMessage,
  decryptMessage,
  clearState,
  getVersion,
};

export default mlsApi;
