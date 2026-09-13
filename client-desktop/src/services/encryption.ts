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
  getKeyBundleForPeer,
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
  /** The peer device this state describes; empty when the server named none. */
  peerDeviceId: string;
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
  peerDeviceId?: string;
  timestamp: number;
  data?: Record<string, unknown>;
}

/**
 * The key `peerStates` is indexed by.
 *
 * A session belongs to a device, so the status of one belongs to a device too. Keyed by user
 * alone, a peer's second device overwrote the first's entry and `encryptMessage` then gated
 * every send on whichever one was written last. Byte-identical to the form `client-mobile`
 * uses for its session ids (`crypto_service.dart:627`) and to the key #286 gives the Rust
 * store, so the three indexes read the same.
 *
 * The separator is mandatory even when the device is empty: `"bob:"` is a peer whose device
 * the server did not name, and it must not collide with anything else.
 */
function peerStateKey(peerId: string, peerDeviceId: string): string {
  return `${peerId}:${peerDeviceId}`;
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
   * Establish encrypted session with a peer.
   *
   * `peerBundle` is optional: when omitted the peer's published bundle is fetched from
   * auth-service. That fetch is the piece that was missing - every other part of the initiator
   * path existed, so `startSession` was never reached and `peerStates` stayed permanently
   * empty.
   */
  async establishSession(peerId: string, peerBundle?: KeyBundle): Promise<SessionInfo> {
    if (!this.initialized) {
      throw new Error('EncryptionManager not initialized');
    }

    // Filed under an unknown device: which of the peer's devices answers is not known until
    // `getKeyBundleForPeer` returns, and that happens below.
    this.updatePeerState(peerId, '', {
      peerId,
      peerDeviceId: '',
      status: 'pending',
      lastUpdated: Date.now(),
    });

    try {
      const bundle = peerBundle ?? (await getKeyBundleForPeer(peerId));
      const session = await encryptionService.startSession(peerId, bundle);
      const peerDeviceId = bundle.deviceId ?? '';

      // The pending entry above was filed under an unknown device, because the device is not
      // known until the bundle has been fetched. Drop it rather than leave a second entry for
      // the same peer stuck at 'pending' for ever.
      if (peerDeviceId !== '') {
        this.peerStates.delete(peerStateKey(peerId, ''));
      }

      // Update peer state to established
      this.updatePeerState(peerId, peerDeviceId, {
        peerId,
        peerDeviceId,
        status: 'established',
        session,
        lastUpdated: Date.now(),
      });

      this.emit({ type: 'session_established', peerId, peerDeviceId, timestamp: Date.now() });

      return session;
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);

      // Under the unknown device, matching the pending entry this replaces: a failure can
      // happen before any device is known, so there is no better key available.
      this.updatePeerState(peerId, '', {
        peerId,
        peerDeviceId: '',
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
   * Answer a peer that opened a session with us, from the prekey message its first message
   * carried.
   *
   * The mirror of `establishSession`. A repeat is a no-op - the initiator keeps attaching the
   * prekey message until a send is accepted, so the same one arrives again on a retry or a
   * duplicate delivery, and acting on it twice would replace a ratchet that has already
   * advanced.
   */
  async acceptSession(peerId: string, peerDeviceId: string, x3dhPrekey: string): Promise<void> {
    if (!this.initialized) {
      throw new Error('EncryptionManager not initialized');
    }

    try {
      await encryptionService.acceptSession(peerId, peerDeviceId, x3dhPrekey);
      this.updatePeerState(peerId, peerDeviceId, {
        peerId,
        peerDeviceId,
        status: 'established',
        lastUpdated: Date.now(),
      });
      this.emit({ type: 'session_established', peerId, peerDeviceId, timestamp: Date.now() });
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : String(error);
      this.updatePeerState(peerId, peerDeviceId, {
        peerId,
        peerDeviceId,
        status: 'error',
        errorMessage,
        lastUpdated: Date.now(),
      });
      throw error;
    }
  }

  /**
   * Get encryption status for a peer
   */
  getPeerStatus(peerId: string, peerDeviceId: string): EncryptionStatus {
    return this.peerStates.get(peerStateKey(peerId, peerDeviceId))?.status ?? 'none';
  }

  /**
   * Get peer encryption state
   */
  getPeerState(peerId: string, peerDeviceId: string): PeerEncryptionState | undefined {
    return this.peerStates.get(peerStateKey(peerId, peerDeviceId));
  }

  /**
   * Check if we have an active session with a peer
   */
  async hasActiveSession(peerId: string, peerDeviceId: string): Promise<boolean> {
    const session = await getSession(peerId, peerDeviceId);
    return session !== null && session.isActive;
  }

  /**
   * End session with a peer
   */
  async endSession(peerId: string, peerDeviceId: string): Promise<void> {
    await encryptionService.endSession(peerId, peerDeviceId);

    this.updatePeerState(peerId, peerDeviceId, {
      peerId,
      peerDeviceId,
      status: 'none',
      lastUpdated: Date.now(),
    });

    this.emit({ type: 'session_ended', peerId, peerDeviceId, timestamp: Date.now() });
  }

  // ---------------------------------------------------------------------------
  // Message Encryption/Decryption
  // ---------------------------------------------------------------------------

  /**
   * Which of a peer's devices the next message is sent to.
   *
   * The send path is the one place the device cannot simply be passed in: a message is
   * addressed to a user, and the UI has no device to name. The most recently established
   * session wins, ties broken by device id so the choice is deterministic rather than
   * dependent on Map insertion order.
   *
   * **It picks one device rather than fanning out, and that is the current behaviour, not a
   * new limitation.** The desktop sends an empty `recipient_device_id` on the wire, so
   * `messaging-service` already fans out to every connection the recipient has; choosing one
   * session to encrypt under is what happens today with the peer collapsed into a single
   * entry. #286 moves the authoritative version of this rule into Rust, where the send path
   * actually reaches the store.
   */
  private resolveSendDevice(peerId: string): PeerEncryptionState | undefined {
    let best: PeerEncryptionState | undefined;
    for (const state of this.peerStates.values()) {
      if (state.peerId !== peerId || state.status !== 'established') continue;
      const better =
        best === undefined ||
        state.lastUpdated > best.lastUpdated ||
        (state.lastUpdated === best.lastUpdated && state.peerDeviceId > best.peerDeviceId);
      if (better) best = state;
    }
    return best;
  }

  /**
   * Encrypt a message for a peer
   */
  async encryptMessage(
    peerId: string,
    plaintext: string,
    selfUserId: string
  ): Promise<EncryptedMessage> {
    const state = this.resolveSendDevice(peerId);
    if (!state) {
      throw new Error(`No established session with peer: ${peerId}`);
    }

    const encrypted = await encryptionService.sendMessage(
      peerId,
      state.peerDeviceId,
      plaintext,
      selfUserId
    );

    this.emit({
      type: 'message_encrypted',
      peerId,
      peerDeviceId: state.peerDeviceId,
      timestamp: Date.now(),
      data: { plaintextLength: plaintext.length },
    });

    return encrypted;
  }

  /**
   * Decrypt a message from a peer
   */
  async decryptMessage(
    senderId: string,
    senderDeviceId: string,
    encrypted: EncryptedMessage,
    selfUserId: string
  ): Promise<string> {
    const state = this.peerStates.get(peerStateKey(senderId, senderDeviceId));
    if (state?.status !== 'established') {
      throw new Error(`No established session with peer: ${senderId}`);
    }

    const plaintext = await encryptionService.receiveMessage(
      senderId,
      senderDeviceId,
      encrypted,
      selfUserId
    );

    this.emit({
      type: 'message_decrypted',
      peerId: senderId,
      peerDeviceId: senderDeviceId,
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

  private updatePeerState(
    peerId: string,
    peerDeviceId: string,
    state: PeerEncryptionState
  ): void {
    this.peerStates.set(peerStateKey(peerId, peerDeviceId), state);
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
