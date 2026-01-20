/**
 * Group Encryption Service
 *
 * High-level orchestration of MLS group encryption.
 * Manages group creation, member management, and group message encryption.
 *
 * @module services/groupEncryption
 */

import * as mls from '../api/mls';

// =============================================================================
// TYPES
// =============================================================================

export type GroupEncryptionStatus =
  | 'none'
  | 'creating'
  | 'joining'
  | 'active'
  | 'error';

export interface GroupEncryptionState {
  groupId: string;
  name: string;
  status: GroupEncryptionStatus;
  epoch: number;
  memberCount: number;
  errorMessage?: string;
  lastUpdated: number;
}

export interface GroupMember {
  identity: string;
  displayName?: string;
  joinedAt: number;
  isAdmin: boolean;
}

export interface GroupEncryptionMetrics {
  totalGroups: number;
  totalMessagesSent: number;
  totalMessagesReceived: number;
  mlsVersion: string;
}

export type GroupEventType =
  | 'group_created'
  | 'group_joined'
  | 'group_left'
  | 'member_added'
  | 'member_removed'
  | 'message_encrypted'
  | 'message_decrypted'
  | 'epoch_changed'
  | 'error';

export interface GroupEvent {
  type: GroupEventType;
  groupId?: string;
  memberId?: string;
  timestamp: number;
  data?: Record<string, unknown>;
}

type GroupEventHandler = (event: GroupEvent) => void;

// =============================================================================
// GROUP ENCRYPTION MANAGER
// =============================================================================

/**
 * Manages MLS group encryption for the application
 */
class GroupEncryptionManager {
  private groupStates = new Map<string, GroupEncryptionState>();
  private eventHandlers = new Set<GroupEventHandler>();
  private initialized = false;
  private userId = '';
  private deviceId = '';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /**
   * Initialize the group encryption manager
   * @param userId - Current user ID
   * @param deviceId - Current device ID
   */
  async initialize(userId: string, deviceId: string): Promise<void> {
    if (this.initialized) return;

    this.userId = userId;
    this.deviceId = deviceId;

    try {
      // Initialize MLS subsystem
      await mls.init(userId, deviceId);

      // Load existing groups
      const groups = await mls.listGroups();
      for (const group of groups) {
        this.groupStates.set(group.groupId, {
          groupId: group.groupId,
          name: group.name,
          status: 'active',
          epoch: group.epoch,
          memberCount: group.memberCount,
          lastUpdated: group.lastActivity * 1000,
        });
      }

      this.initialized = true;
      // eslint-disable-next-line no-console
      console.log(
        '[GroupEncryptionManager] Initialized successfully with',
        groups.length,
        'groups'
      );
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('[GroupEncryptionManager] Initialization failed:', error);
      throw error;
    }
  }

  /**
   * Check if manager is initialized
   */
  isReady(): boolean {
    return this.initialized;
  }

  // ---------------------------------------------------------------------------
  // Group Management
  // ---------------------------------------------------------------------------

  /**
   * Create a new encrypted group
   * @param groupId - Unique group identifier
   * @param name - Display name for the group
   * @returns Created group state
   */
  async createGroup(groupId: string, name: string): Promise<GroupEncryptionState> {
    this.ensureInitialized();

    // Update state to creating
    const state: GroupEncryptionState = {
      groupId,
      name,
      status: 'creating',
      epoch: 0,
      memberCount: 1,
      lastUpdated: Date.now(),
    };
    this.groupStates.set(groupId, state);

    try {
      const result = await mls.createGroup(groupId, name);

      // Update state
      state.status = 'active';
      state.epoch = result.epoch;
      state.lastUpdated = Date.now();
      this.groupStates.set(groupId, state);

      this.emit({
        type: 'group_created',
        groupId,
        timestamp: Date.now(),
        data: { epoch: result.epoch },
      });

      // eslint-disable-next-line no-console
      console.log('[GroupEncryptionManager] Group created:', groupId);
      return state;
    } catch (error) {
      state.status = 'error';
      state.errorMessage = error instanceof Error ? error.message : String(error);
      this.groupStates.set(groupId, state);

      this.emit({
        type: 'error',
        groupId,
        timestamp: Date.now(),
        data: { error: state.errorMessage },
      });

      throw error;
    }
  }

  /**
   * Join an existing group using a Welcome message
   * @param welcome - Welcome message (base64)
   * @param groupName - Display name for the group
   * @returns Joined group state
   */
  async joinGroup(welcome: string, groupName: string): Promise<GroupEncryptionState> {
    this.ensureInitialized();

    try {
      const result = await mls.joinGroup(welcome, groupName);

      const state: GroupEncryptionState = {
        groupId: result.groupId,
        name: result.name,
        status: 'active',
        epoch: result.epoch,
        memberCount: result.memberCount,
        lastUpdated: Date.now(),
      };
      this.groupStates.set(result.groupId, state);

      this.emit({
        type: 'group_joined',
        groupId: result.groupId,
        timestamp: Date.now(),
        data: { epoch: result.epoch, memberCount: result.memberCount },
      });

      // eslint-disable-next-line no-console
      console.log('[GroupEncryptionManager] Joined group:', result.groupId);
      return state;
    } catch (error) {
      this.emit({
        type: 'error',
        timestamp: Date.now(),
        data: { error: error instanceof Error ? error.message : String(error) },
      });

      throw error;
    }
  }

  /**
   * Leave and delete a group
   * @param groupId - Group ID to leave
   */
  async leaveGroup(groupId: string): Promise<void> {
    this.ensureInitialized();

    await mls.deleteGroup(groupId);
    this.groupStates.delete(groupId);

    this.emit({
      type: 'group_left',
      groupId,
      timestamp: Date.now(),
    });

    // eslint-disable-next-line no-console
    console.log('[GroupEncryptionManager] Left group:', groupId);
  }

  /**
   * Get group state
   * @param groupId - Group ID
   * @returns Group state or undefined
   */
  getGroupState(groupId: string): GroupEncryptionState | undefined {
    return this.groupStates.get(groupId);
  }

  /**
   * Get all group states
   * @returns All group states
   */
  getAllGroups(): GroupEncryptionState[] {
    return Array.from(this.groupStates.values());
  }

  // ---------------------------------------------------------------------------
  // Member Management
  // ---------------------------------------------------------------------------

  /**
   * Add a member to a group
   * @param groupId - Group ID
   * @param memberKeyPackage - Member's key package (base64)
   * @returns Commit and Welcome messages to distribute
   */
  async addMember(
    groupId: string,
    memberKeyPackage: string
  ): Promise<mls.MlsAddMemberResult> {
    this.ensureInitialized();

    const result = await mls.addMember(groupId, memberKeyPackage);

    // Update local state
    const state = this.groupStates.get(groupId);
    if (state) {
      state.epoch = result.epoch;
      state.memberCount += 1;
      state.lastUpdated = Date.now();
    }

    this.emit({
      type: 'member_added',
      groupId,
      timestamp: Date.now(),
      data: { epoch: result.epoch },
    });

    // eslint-disable-next-line no-console
    console.log('[GroupEncryptionManager] Member added to group:', groupId);
    return result;
  }

  /**
   * Remove a member from a group
   * @param groupId - Group ID
   * @param memberIndex - Member's leaf node index
   * @returns Commit message to distribute
   */
  async removeMember(
    groupId: string,
    memberIndex: number
  ): Promise<mls.MlsRemoveMemberResult> {
    this.ensureInitialized();

    const result = await mls.removeMember(groupId, memberIndex);

    // Update local state
    const state = this.groupStates.get(groupId);
    if (state) {
      state.epoch = result.epoch;
      state.memberCount = Math.max(1, state.memberCount - 1);
      state.lastUpdated = Date.now();
    }

    this.emit({
      type: 'member_removed',
      groupId,
      timestamp: Date.now(),
      data: { memberIndex, epoch: result.epoch },
    });

    // eslint-disable-next-line no-console
    console.log('[GroupEncryptionManager] Member removed from group:', groupId);
    return result;
  }

  /**
   * Process an incoming commit (membership change from another member)
   * @param groupId - Group ID
   * @param commit - Commit message (base64)
   */
  async processCommit(groupId: string, commit: string): Promise<void> {
    this.ensureInitialized();

    const newEpoch = await mls.processCommit(groupId, commit);

    // Update local state
    const state = this.groupStates.get(groupId);
    if (state) {
      state.epoch = newEpoch;
      state.lastUpdated = Date.now();
    }

    this.emit({
      type: 'epoch_changed',
      groupId,
      timestamp: Date.now(),
      data: { epoch: newEpoch },
    });

    // eslint-disable-next-line no-console
    console.log('[GroupEncryptionManager] Commit processed for group:', groupId);
  }

  // ---------------------------------------------------------------------------
  // Message Encryption
  // ---------------------------------------------------------------------------

  /**
   * Encrypt a message for a group
   * @param groupId - Group ID
   * @param plaintext - Message to encrypt
   * @returns Encrypted message data
   */
  async encryptMessage(
    groupId: string,
    plaintext: string
  ): Promise<mls.MlsEncryptedMessage> {
    this.ensureInitialized();

    const result = await mls.encryptMessage(groupId, plaintext);

    this.emit({
      type: 'message_encrypted',
      groupId,
      timestamp: Date.now(),
      data: { epoch: result.epoch },
    });

    return result;
  }

  /**
   * Decrypt a group message
   * @param groupId - Group ID
   * @param ciphertext - Encrypted message (base64)
   * @returns Decrypted message data
   */
  async decryptMessage(
    groupId: string,
    ciphertext: string
  ): Promise<mls.MlsDecryptedMessage> {
    this.ensureInitialized();

    const result = await mls.decryptMessage(groupId, ciphertext);

    this.emit({
      type: 'message_decrypted',
      groupId,
      timestamp: Date.now(),
      data: { senderId: result.senderId, epoch: result.epoch },
    });

    return result;
  }

  // ---------------------------------------------------------------------------
  // Key Package Management
  // ---------------------------------------------------------------------------

  /**
   * Generate key packages for distribution
   * @param count - Number of key packages to generate
   * @returns Generated key packages
   */
  async generateKeyPackages(count = 10): Promise<mls.MlsKeyPackage[]> {
    this.ensureInitialized();
    return mls.generateKeyPackages(count);
  }

  // ---------------------------------------------------------------------------
  // Metrics & Status
  // ---------------------------------------------------------------------------

  /**
   * Get current user identity
   * @returns User ID and Device ID
   */
  getIdentity(): { userId: string; deviceId: string } {
    return { userId: this.userId, deviceId: this.deviceId };
  }

  /**
   * Get encryption metrics
   * @returns Group encryption metrics
   */
  async getMetrics(): Promise<GroupEncryptionMetrics> {
    const groups = Array.from(this.groupStates.values());
    const version = await mls.getVersion();

    return {
      totalGroups: groups.length,
      totalMessagesSent: groups.reduce(
        (sum, g) => sum + (this.groupStates.get(g.groupId)?.memberCount ?? 0),
        0
      ),
      totalMessagesReceived: 0, // Would need to aggregate from mls.getGroup
      mlsVersion: version,
    };
  }

  // ---------------------------------------------------------------------------
  // Event System
  // ---------------------------------------------------------------------------

  /**
   * Subscribe to group encryption events
   */
  on(handler: GroupEventHandler): () => void {
    this.eventHandlers.add(handler);
    return () => this.eventHandlers.delete(handler);
  }

  /**
   * Unsubscribe from group encryption events
   */
  off(handler: GroupEventHandler): void {
    this.eventHandlers.delete(handler);
  }

  private emit(event: GroupEvent): void {
    this.eventHandlers.forEach((handler) => {
      try {
        handler(event);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('[GroupEncryptionManager] Event handler error:', error);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  /**
   * Clear all group encryption state (logout)
   */
  async clear(): Promise<void> {
    await mls.clearState();
    this.groupStates.clear();
    this.initialized = false;
    this.userId = '';
    this.deviceId = '';

    // eslint-disable-next-line no-console
    console.log('[GroupEncryptionManager] State cleared');
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  private ensureInitialized(): void {
    if (!this.initialized) {
      throw new Error(
        'GroupEncryptionManager not initialized. Call initialize() first.'
      );
    }
  }
}

// =============================================================================
// SINGLETON EXPORT
// =============================================================================

/**
 * Global group encryption manager instance
 */
export const groupEncryptionManager = new GroupEncryptionManager();

export default groupEncryptionManager;
