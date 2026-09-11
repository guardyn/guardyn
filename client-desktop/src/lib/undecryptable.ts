/**
 * What a received message becomes when it cannot be decrypted.
 *
 * The receive path used to present whatever arrived as the message text - `data.content`
 * straight into the store on the WebSocket path, `String::from_utf8_lossy` on the gRPC one.
 * That is fail-open: a payload that could not be authenticated was displayed as though it had
 * been, and `from_utf8_lossy` cannot fail, so real ciphertext rendered as replacement
 * characters rather than as an error.
 *
 * Decryption fails for ordinary reasons as well as hostile ones - a peer whose session was
 * never established, a message that arrives after a reinstall, a wire format this build
 * predates (ADR-0011 versions the ratchet format precisely so that case is distinguishable).
 * The user is told, rather than shown noise that looks like content.
 *
 * Kept deliberately identical to `client-mobile/lib/core/crypto/undecryptable_message.dart`,
 * so the two clients say the same thing.
 */

/** Placeholder shown in place of content that could not be decrypted. */
export const UNDECRYPTABLE_PLACEHOLDER = 'Message cannot be decrypted';
