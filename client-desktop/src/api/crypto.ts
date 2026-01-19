/**
 * Crypto API
 * 
 * TypeScript wrappers for Tauri crypto commands.
 * Provides E2EE functionality via guardyn-crypto library.
 * 
 * @module api/crypto
 */

import { invoke } from '@tauri-apps/api/core';

// =============================================================================
// TYPES
// =============================================================================

/**
 * Identity key data (Ed25519 for signing)
 */
export interface IdentityKeyData {
  /** Ed25519 public key (hex-encoded) */
  publicKey: string;
}

/**
 * Prekey data (X25519 for DH)
 */
export interface PreKeyData {
  keyId: number;
  /** X25519 public key (hex-encoded) */
  publicKey: string;
  /** Signature over public key (hex-encoded) */
  signature: string;
}

/**
 * Complete key bundle for E2EE key exchange
 */
export interface KeyBundle {
  identityKey: string;
  signedPrekey: string;
  prekeySignature: string;
  oneTimePrekey?: string;
  pqPrekey?: string;
}

/**
 * X3DH key agreement result
 */
export interface X3DHResult {
  /** Shared secret (hex-encoded) */
  sharedSecret: string;
  /** Our ephemeral public key (hex-encoded) */
  ephemeralKey: string;
  /** Used one-time prekey ID (if any) */
  usedPrekeyId?: number;
}

/**
 * Encrypted message with header
 */
export interface EncryptedMessage {
  /** Base64-encoded ciphertext */
  ciphertext: string;
  /** Base64-encoded nonce */
  nonce: string;
  /** Base64-encoded header (DH key + counters) */
  header: string;
}

/**
 * Session information
 */
export interface SessionInfo {
  peerId: string;
  establishedAt: number;
  messagesSent: number;
  messagesReceived: number;
  isActive: boolean;
}

// =============================================================================
// IDENTITY KEY MANAGEMENT
// =============================================================================

/**
 * Generate new identity keys (Ed25519)
 * These are long-term keys that identify the user
 */
export async function generateIdentityKeys(): Promise<IdentityKeyData> {
  const result = await invoke<{ public_key: string }>('generate_identity_keys');
  return {
    publicKey: result.public_key,
  };
}

/**
 * Get current identity public key
 */
export async function getIdentityKey(): Promise<string | null> {
  return invoke<string | null>('get_identity_key');
}

/**
 * Check if identity keys exist
 */
export async function hasIdentityKeys(): Promise<boolean> {
  return invoke<boolean>('has_identity_keys');
}

// =============================================================================
// PREKEY MANAGEMENT
// =============================================================================

/**
 * Generate signed prekey
 */
export async function generateSignedPrekey(): Promise<PreKeyData> {
  const result = await invoke<{
    key_id: number;
    public_key: string;
    signature: string;
  }>('generate_signed_prekey');
  return {
    keyId: result.key_id,
    publicKey: result.public_key,
    signature: result.signature,
  };
}

/**
 * Generate one-time prekeys (batch)
 */
export async function generateOneTimePrekeys(count: number): Promise<PreKeyData[]> {
  const results = await invoke<Array<{
    key_id: number;
    public_key: string;
    signature: string;
  }>>('generate_one_time_prekeys', { count });
  return results.map(r => ({
    keyId: r.key_id,
    publicKey: r.public_key,
    signature: r.signature,
  }));
}

// =============================================================================
// KEY BUNDLE
// =============================================================================

/**
 * Generate a complete key bundle for E2EE
 */
export async function generateKeyBundle(includePq: boolean = false): Promise<KeyBundle> {
  const result = await invoke<{
    identity_key: string;
    signed_prekey: string;
    prekey_signature: string;
    one_time_prekey?: string;
    pq_prekey?: string;
  }>('generate_key_bundle', { includePq });
  return {
    identityKey: result.identity_key,
    signedPrekey: result.signed_prekey,
    prekeySignature: result.prekey_signature,
    oneTimePrekey: result.one_time_prekey,
    pqPrekey: result.pq_prekey,
  };
}

// =============================================================================
// X3DH KEY AGREEMENT
// =============================================================================

/**
 * Perform X3DH key agreement as initiator
 * Returns shared secret for Double Ratchet initialization
 */
export async function performX3DH(
  recipientBundle: KeyBundle,
  recipientId: string
): Promise<X3DHResult> {
  const result = await invoke<{
    shared_secret: string;
    ephemeral_key: string;
    used_prekey_id?: number;
  }>('perform_x3dh', {
    recipientBundle: {
      identity_key: recipientBundle.identityKey,
      signed_prekey: recipientBundle.signedPrekey,
      prekey_signature: recipientBundle.prekeySignature,
      one_time_prekey: recipientBundle.oneTimePrekey,
      pq_prekey: recipientBundle.pqPrekey,
    },
    recipientId,
  });
  return {
    sharedSecret: result.shared_secret,
    ephemeralKey: result.ephemeral_key,
    usedPrekeyId: result.used_prekey_id,
  };
}

// =============================================================================
// SESSION MANAGEMENT
// =============================================================================

/**
 * Initialize a Double Ratchet session with a peer
 */
export async function initSession(
  peerId: string,
  sharedSecret: string,
  isInitiator: boolean
): Promise<SessionInfo> {
  const result = await invoke<{
    peer_id: string;
    established_at: number;
    messages_sent: number;
    messages_received: number;
    is_active: boolean;
  }>('init_session', { peerId, sharedSecret, isInitiator });
  return {
    peerId: result.peer_id,
    establishedAt: result.established_at,
    messagesSent: result.messages_sent,
    messagesReceived: result.messages_received,
    isActive: result.is_active,
  };
}

/**
 * Get session info for a peer
 */
export async function getSession(peerId: string): Promise<SessionInfo | null> {
  const result = await invoke<{
    peer_id: string;
    established_at: number;
    messages_sent: number;
    messages_received: number;
    is_active: boolean;
  } | null>('get_session', { peerId });
  if (!result) return null;
  return {
    peerId: result.peer_id,
    establishedAt: result.established_at,
    messagesSent: result.messages_sent,
    messagesReceived: result.messages_received,
    isActive: result.is_active,
  };
}

/**
 * List all active sessions
 */
export async function listSessions(): Promise<SessionInfo[]> {
  const results = await invoke<Array<{
    peer_id: string;
    established_at: number;
    messages_sent: number;
    messages_received: number;
    is_active: boolean;
  }>>('list_sessions');
  return results.map(r => ({
    peerId: r.peer_id,
    establishedAt: r.established_at,
    messagesSent: r.messages_sent,
    messagesReceived: r.messages_received,
    isActive: r.is_active,
  }));
}

/**
 * Delete a session with a peer
 */
export async function deleteSession(peerId: string): Promise<boolean> {
  return invoke<boolean>('delete_session', { peerId });
}

// =============================================================================
// MESSAGE ENCRYPTION/DECRYPTION
// =============================================================================

/**
 * Encrypt a message for a peer using Double Ratchet
 */
export async function encryptMessage(
  plaintext: string,
  recipientId: string
): Promise<EncryptedMessage> {
  const result = await invoke<{
    ciphertext: string;
    nonce: string;
    header: string;
  }>('encrypt_message', { plaintext, recipientId });
  return result;
}

/**
 * Decrypt a message from a peer using Double Ratchet
 */
export async function decryptMessage(
  ciphertext: string,
  nonce: string,
  senderId: string
): Promise<string> {
  return invoke<string>('decrypt_message', { ciphertext, nonce, senderId });
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/**
 * Check if post-quantum cryptography is available
 */
export async function isPqAvailable(): Promise<boolean> {
  return invoke<boolean>('is_pq_available');
}

/**
 * Get crypto library version
 */
export async function getCryptoVersion(): Promise<string> {
  return invoke<string>('get_crypto_version');
}

/**
 * Clear all crypto state (for logout/reset)
 */
export async function clearCryptoState(): Promise<void> {
  return invoke('clear_crypto_state');
}

// =============================================================================
// HIGH-LEVEL ENCRYPTION SERVICE
// =============================================================================

/**
 * Encryption service for managing E2EE messaging
 */
export class EncryptionService {
  private initialized = false;
  private identityKey: string | null = null;

  /**
   * Initialize the encryption service
   * Generates identity keys if not already present
   */
  async initialize(): Promise<void> {
    if (this.initialized) return;

    const hasKeys = await hasIdentityKeys();
    if (!hasKeys) {
      const keys = await generateIdentityKeys();
      this.identityKey = keys.publicKey;
    } else {
      this.identityKey = await getIdentityKey();
    }

    this.initialized = true;
  }

  /**
   * Get our identity public key
   */
  getIdentityKey(): string | null {
    return this.identityKey;
  }

  /**
   * Start a secure session with a peer
   */
  async startSession(peerId: string, peerBundle: KeyBundle): Promise<SessionInfo> {
    if (!this.initialized) {
      throw new Error('EncryptionService not initialized');
    }

    // Perform X3DH key agreement
    const x3dhResult = await performX3DH(peerBundle, peerId);

    // Initialize Double Ratchet session
    const session = await initSession(peerId, x3dhResult.sharedSecret, true);

    return session;
  }

  /**
   * Send an encrypted message
   */
  async sendMessage(peerId: string, plaintext: string): Promise<EncryptedMessage> {
    const session = await getSession(peerId);
    if (!session) {
      throw new Error(`No session with peer: ${peerId}`);
    }

    return encryptMessage(plaintext, peerId);
  }

  /**
   * Receive and decrypt a message
   */
  async receiveMessage(
    senderId: string,
    encrypted: EncryptedMessage
  ): Promise<string> {
    const session = await getSession(senderId);
    if (!session) {
      throw new Error(`No session with peer: ${senderId}`);
    }

    return decryptMessage(encrypted.ciphertext, encrypted.nonce, senderId);
  }

  /**
   * Check if we have a session with a peer
   */
  async hasSession(peerId: string): Promise<boolean> {
    const session = await getSession(peerId);
    return session !== null && session.isActive;
  }

  /**
   * End session with a peer
   */
  async endSession(peerId: string): Promise<void> {
    await deleteSession(peerId);
  }

  /**
   * Clear all encryption state (logout)
   */
  async clear(): Promise<void> {
    await clearCryptoState();
    this.initialized = false;
    this.identityKey = null;
  }
}

// Export singleton instance
export const encryptionService = new EncryptionService();
