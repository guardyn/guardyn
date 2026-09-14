/**
 * Crypto API IPC Contract Tests
 *
 * Pins the argument names every crypto command is invoked with.
 *
 * A Tauri command deserializes its arguments by name, so a wrapper that spells one wrongly
 * fails at runtime rather than at compile time - and TypeScript cannot see it, because
 * `invoke` takes a bare object. This repo has already paid for that once: `Chat.tsx` carried a
 * second `invoke('send_message')` alongside the socket send which "never actually
 * double-stored only because the invoke passed arguments the Rust signature could not
 * deserialize, so it threw every time".
 *
 * These tests exist so that adding `peerDeviceId` to eight commands cannot repeat it.
 */

import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  acceptSessionCommand,
  deleteSession,
  decryptMessage,
  encryptMessage,
  getKeyBundleForPeer,
  getSession,
  initSession,
  listSessions,
  performX3DH,
  type KeyBundle,
} from './crypto';

const mockInvoke = vi.fn();
vi.mock('@tauri-apps/api/core', () => ({
  invoke: (...args: unknown[]) => mockInvoke(...args),
}));

const peerBundle: KeyBundle = {
  identityKey: 'aa',
  signedPrekey: 'bb',
  prekeySignature: 'cc',
  oneTimePrekey: 'dd',
  deviceId: 'bob-phone',
};

const wireSession = {
  peer_id: 'bob',
  peer_device_id: 'bob-phone',
  established_at: 1,
  messages_sent: 0,
  messages_received: 0,
  is_active: true,
};

describe('Crypto API IPC contract', () => {
  beforeEach(() => mockInvoke.mockReset());

  it('names the peer device on every session command', async () => {
    mockInvoke.mockResolvedValue(wireSession);
    await initSession('bob', 'bob-phone', 'ff', true, 'pub');
    expect(mockInvoke).toHaveBeenCalledWith('init_session', {
      peerId: 'bob',
      peerDeviceId: 'bob-phone',
      sharedSecret: 'ff',
      isInitiator: true,
      peerPublicKey: 'pub',
    });

    mockInvoke.mockResolvedValue(undefined);
    await acceptSessionCommand('bob', 'bob-phone', 'prekey');
    expect(mockInvoke).toHaveBeenCalledWith('accept_session', {
      peerId: 'bob',
      peerDeviceId: 'bob-phone',
      x3dhPrekey: 'prekey',
    });

    mockInvoke.mockResolvedValue(wireSession);
    await getSession('bob', 'bob-phone');
    expect(mockInvoke).toHaveBeenCalledWith('get_session', {
      peerId: 'bob',
      peerDeviceId: 'bob-phone',
    });

    mockInvoke.mockResolvedValue(true);
    await deleteSession('bob', 'bob-phone');
    expect(mockInvoke).toHaveBeenCalledWith('delete_session', {
      peerId: 'bob',
      peerDeviceId: 'bob-phone',
    });
  });

  it('names the peer device on the message and key-agreement commands', async () => {
    mockInvoke.mockResolvedValue({ ciphertext: 'x', nonce: '', header: '' });
    await encryptMessage('hi', 'bob', 'bob-phone', 'alice');
    expect(mockInvoke).toHaveBeenCalledWith('encrypt_message', {
      plaintext: 'hi',
      recipientId: 'bob',
      recipientDeviceId: 'bob-phone',
      selfUserId: 'alice',
    });

    mockInvoke.mockResolvedValue('hi');
    await decryptMessage('x', '', 'bob', 'bob-phone', 'alice');
    expect(mockInvoke).toHaveBeenCalledWith('decrypt_message', {
      ciphertext: 'x',
      nonce: '',
      senderId: 'bob',
      senderDeviceId: 'bob-phone',
      selfUserId: 'alice',
    });

    mockInvoke.mockResolvedValue({ shared_secret: 's', ephemeral_key: 'e' });
    await performX3DH(peerBundle, 'bob', 'bob-phone');
    expect(mockInvoke).toHaveBeenCalledWith(
      'perform_x3dh',
      expect.objectContaining({ recipientId: 'bob', recipientDeviceId: 'bob-phone' })
    );
  });

  it('carries the ML-KEM pre-key and its signature in both directions', async () => {
    // This is the seam where a hybrid bundle would become a half pair. Both directions map
    // field by field, so a field left out of either one is silently dropped - and the Rust
    // side then refuses the bundle outright rather than downgrading it (SRS rule 4a), which
    // turns a one-line omission here into a peer nobody can start a session with.
    mockInvoke.mockResolvedValue({
      identity_key: 'aa',
      signed_prekey: 'bb',
      prekey_signature: 'cc',
      pq_prekey: 'ee',
      pq_prekey_signature: 'ff',
      device_id: 'bob-phone',
    });

    const bundle = await getKeyBundleForPeer('bob');
    expect(bundle.pqPrekey).toBe('ee');
    expect(bundle.pqPrekeySignature).toBe('ff');

    mockInvoke.mockResolvedValue({ shared_secret: '00', ephemeral_key: '11' });
    await performX3DH(bundle, 'bob', 'bob-phone');

    expect(mockInvoke).toHaveBeenLastCalledWith(
      'perform_x3dh',
      expect.objectContaining({
        recipientBundle: expect.objectContaining({
          pq_prekey: 'ee',
          pq_prekey_signature: 'ff',
        }),
      })
    );
  });

  it('reads the device off the flattened key bundle', async () => {
    // `PeerKeyBundle` flattens `device_id` alongside the bundle fields rather than nesting it,
    // which is what let the Rust side start returning it without changing this call site.
    mockInvoke.mockResolvedValue({
      identity_key: 'aa',
      signed_prekey: 'bb',
      prekey_signature: 'cc',
      device_id: 'bob-phone',
    });

    const bundle = await getKeyBundleForPeer('bob');

    expect(bundle.deviceId).toBe('bob-phone');
    expect(bundle.identityKey).toBe('aa');
  });

  it('reads a session written before devices as naming no device', async () => {
    // Rust skips `peer_device_id` when it is empty, so the field is absent rather than "".
    const legacy: Record<string, unknown> = { ...wireSession };
    delete legacy.peer_device_id;
    mockInvoke.mockResolvedValue(legacy);

    const session = await getSession('bob', '');

    expect(session?.peerDeviceId).toBe('');
  });

  it('carries the device through a session listing', async () => {
    mockInvoke.mockResolvedValue([wireSession]);

    const sessions = await listSessions();

    expect(sessions[0].peerDeviceId).toBe('bob-phone');
  });
});
