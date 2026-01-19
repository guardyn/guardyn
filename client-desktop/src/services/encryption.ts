/**
 * Encryption Service
 * 
 * High-level orchestration of E2EE messaging.
 * Manages key exchange flows, session lifecycle, and message encryption.
 * 
 * @module services/encryption
 */

import {
  encryptionService,
  KeyBundle,
  EncryptedMessage,
  SessionInfo,
  generateKeyBundle,
  getSession,
  listSessions,
  isPqAvailable,
  getCryptoVersion,
} from '../api/crypto';

// =============================================================================
// TYPES
// =============================================================================

export type EncryptionStatus = 'none' | 'pending' | 'established' | 'error';

export interface PeerEncryptionState {
  peerId: string;
  status: EncryptionStatus;
  session?: SessionInfo;
  errorMessage?: string;
  lastUpdated: number;
}

export interface EncryptionMetrics {
  totalSessions: number;
  messagesSent: number;
  messagesReceived: number;
  isPqEnabled: boolean;
  cryptoVersion: string;
}

export type EncryptionEventType = 
  | 'session_established'
  | 'session_error'
  | 'session_ended'
  | 'keys_generated'
  | 'message_encrypted'
  | 'message_decrypted';

export interface EncryptionEvent {
  type: EncryptionEventType;
  peerId?: string;
  timestamp: number;
  data?: Record<string, unknown>;
}

type EncryptionEventHandler = (event: EncryptionEvent) => void;

// =============================================================================
// ENCRYPTION MANAGER
// =============================================================================

/**
 * Manages E2EE encryption for the application
 */
class EncryptionManager {
  private peerStates = new Map<string, PeerEncryptionState>();
  private eventHandlers = new Set<EncryptionEventHandler>();
  private keyBundle: KeyBundle | null = null;
  private initialized = false;

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /**
   * Initialize the encryption manager
   * Generates identity keys and prekeys if needed
   */
  async initialize(): Promise<void> {
    if (this.initialized) return;

    try {
      // Initialize the core encryption service
      await encryptionService.initialize();

      // Generate our key bundle for sharing with peers
      const isPq = await isPqAvailable();
      this.keyBundle = await generateKeyBundle(isPq);

      this.initialized = true;
      this.emit({ type: 'keys_generated', timestamp: Date.now() });

      // eslint-disable-next-line no-console
      console.log('[EncryptionManager] Initialized successfully');
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('[EncryptionManager] Initialization failed:', error);
      throw error;
    }
  }

  /**
   * Check if manager is initialized
   */
  isInitialized(): boolean {
    return this.initialized;
  }

  /**
   * Get our public key bundle for sharing with peers
   */
  getKeyBundle(): KeyBundle | null {
    return this.keyBundle;
  }

  // ---------------------------------------------------------------------------
  // Session Management
  // ---------------------------------------------------------------------------

  /**
   * Establish encrypted session with a peer
   */
  async establishSession(peerId: string, peerBundle: KeyBundle): Promise<SessionInfo> {
    if (!this.initialized) {
      throw new Error('EncryptionManager not initialized');
    }

    // Update peer state to pending
    this.updatePeerState(peerId, {
      peerId,
      status: 'pending',
      lastUpdated: Date.now(),
    });

    try {
      const session = await encryptionService.startSession(peerId, peerBundle);

      // Update peer state to established
      this.updatePeerState(peerId, {
        peerId,
        status: 'established',
        session,
        lastUpdated: Date.now(),
      });

      this.emit({ type: 'session_established', peerId, timestamp: Date.now() });

      return session;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);

      // Update peer state to error
      this.updatePeerState(peerId, {
        peerId,
        status: 'error',
        errorMessage,
        lastUpdated: Date.now(),
      });

      this.emit({ 
        type: 'session_error', 
        peerId, 
        timestamp: Date.now(),
        data: { error: errorMessage },
      });

      throw error;
    }
  }

  /**
   * Get encryption status for a peer
   */
  getPeerStatus(peerId: string): EncryptionStatus {
    return this.peerStates.get(peerId)?.status ?? 'none';
  }

  /**
   * Get peer encryption state
   */
  getPeerState(peerId: string): PeerEncryptionState | undefined {
    return this.peerStates.get(peerId);
  }

  /**
   * Check if we have an active session with a peer
   */
  async hasActiveSession(peerId: string): Promise<boolean> {
    const session = await getSession(peerId);
    return session !== null && session.isActive;
  }

  /**
   * End session with a peer
   */
  async endSession(peerId: string): Promise<void> {
    await encryptionService.endSession(peerId);

    this.updatePeerState(peerId, {
      peerId,
      status: 'none',
      lastUpdated: Date.now(),
    });

    this.emit({ type: 'session_ended', peerId, timestamp: Date.now() });
  }

  // ---------------------------------------------------------------------------
  // Message Encryption/Decryption
  // ---------------------------------------------------------------------------

  /**
   * Encrypt a message for a peer
   */
  async encryptMessage(peerId: string, plaintext: string): Promise<EncryptedMessage> {
    const state = this.peerStates.get(peerId);
    if (state?.status !== 'established') {
      throw new Error(`No established session with peer: ${peerId}`);
    }

    const encrypted = await encryptionService.sendMessage(peerId, plaintext);

    this.emit({
      type: 'message_encrypted',
      peerId,
      timestamp: Date.now(),
      data: { plaintextLength: plaintext.length },
    });

    return encrypted;
  }

  /**
   * Decrypt a message from a peer
   */
  async decryptMessage(senderId: string, encrypted: EncryptedMessage): Promise<string> {
    const state = this.peerStates.get(senderId);
    if (state?.status !== 'established') {
      throw new Error(`No established session with peer: ${senderId}`);
    }

    const plaintext = await encryptionService.receiveMessage(senderId, encrypted);

    this.emit({
      type: 'message_decrypted',
      peerId: senderId,
      timestamp: Date.now(),
      data: { plaintextLength: plaintext.length },
    });

    return plaintext;
  }

  // ---------------------------------------------------------------------------
  // Metrics & Info
  // ---------------------------------------------------------------------------

  /**
   * Get encryption metrics
   */
  async getMetrics(): Promise<EncryptionMetrics> {
    const sessions = await listSessions();
    const isPq = await isPqAvailable();
    const version = await getCryptoVersion();

    return {
      totalSessions: sessions.length,
      messagesSent: sessions.reduce((sum, s) => sum + s.messagesSent, 0),
      messagesReceived: sessions.reduce((sum, s) => sum + s.messagesReceived, 0),
      isPqEnabled: isPq,
      cryptoVersion: version,
    };
  }

  /**
   * Get all peer states
   */
  getAllPeerStates(): PeerEncryptionState[] {
    return Array.from(this.peerStates.values());
  }

  // ---------------------------------------------------------------------------
  // Event Handling
  // ---------------------------------------------------------------------------

  /**
   * Subscribe to encryption events
   */
  subscribe(handler: EncryptionEventHandler): () => void {
    this.eventHandlers.add(handler);
    return () => this.eventHandlers.delete(handler);
  }

  private emit(event: EncryptionEvent): void {
    this.eventHandlers.forEach(handler => {
      try {
        handler(event);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('[EncryptionManager] Event handler error:', error);
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Internal Helpers
  // ---------------------------------------------------------------------------

  private updatePeerState(peerId: string, state: PeerEncryptionState): void {
    this.peerStates.set(peerId, state);
  }

  /**
   * Reset all encryption state (logout)
   */
  async reset(): Promise<void> {
    await encryptionService.clear();
    this.peerStates.clear();
    this.keyBundle = null;
    this.initialized = false;
    // eslint-disable-next-line no-console
    console.log('[EncryptionManager] Reset complete');
  }
}

// =============================================================================
// EXPORTS
// =============================================================================

// Singleton instance
export const encryptionManager = new EncryptionManager();

// Re-export types from crypto API
export type { KeyBundle, EncryptedMessage, SessionInfo };
