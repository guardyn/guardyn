/// The caller-side associated data for a one-to-one message.
library;

import 'dart:convert';
import 'dart:typed_data';

/// Builds the caller-supplied associated data bound into a message's AEAD.
///
/// The full AAD is `messageAssociatedData(...) || header(40)`; the ratchet appends the header
/// itself (see `_aadWithHeader` in `double_ratchet.dart`). This function supplies only the
/// caller's half.
///
/// The convention is **`utf8("{senderUserId}|{recipientUserId}")`**, and it is canonical
/// across both clients — `client-desktop` builds the same bytes in
/// `src-tauri/src/commands/crypto.rs`. It is recorded in
/// `docs/adr/ADR-0011-ratchet-header-authentication.md`.
///
/// Two properties matter, and both were violated somewhere before this existed:
///
/// **It is directional, and therefore symmetric.** Both ends name the *originator* first and
/// the *destination* second, so a sender encrypting to Bob and Bob decrypting from that
/// sender compute identical bytes. Deriving the value from "me" and "the other party" instead
/// produces two different strings for the same message and the tag never verifies — which is
/// what the desktop client did, passing `recipient_id` on encrypt and `sender_id` on decrypt.
///
/// **It is UTF-8, not `String.codeUnits`.** `codeUnits` yields UTF-16 units, and
/// `Uint8List.fromList` then truncates anything above 0xFF, so any non-ASCII identifier would
/// silently produce different bytes on the two sides.
///
/// Binding both participants is what stops a ciphertext being replayed into a different
/// conversation that shares a session.
Uint8List messageAssociatedData({
  required String senderUserId,
  required String recipientUserId,
}) {
  return Uint8List.fromList(utf8.encode('$senderUserId|$recipientUserId'));
}
