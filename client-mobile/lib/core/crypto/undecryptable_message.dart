/// What a received message becomes when it cannot be decrypted.
///
/// The receive path used to return the bytes it failed to decrypt, so ciphertext - or anything
/// else that happened to arrive - was rendered to the user as if it were the message. That is
/// fail-open: a message that could not be authenticated was presented as though it had been.
///
/// Decryption fails for ordinary reasons as well as hostile ones: a message from a device whose
/// session was never established, one that arrives after a reinstall, or one written in a wire
/// format this build predates ([ADR-0011] versions the ratchet format precisely so this case is
/// distinguishable). The user is told, rather than shown noise that looks like content.
///
/// [ADR-0011]: docs/adr/ADR-0011-ratchet-header-authentication.md
library;

/// Metadata key set on a message whose content could not be decrypted.
///
/// Namespaced so it cannot collide with a server-supplied key such as `x3dh_prekey`.
const String undecryptableMetadataKey = 'guardyn.undecryptable';

/// Placeholder shown in place of content that could not be decrypted.
///
/// The UI keys off [undecryptableMetadataKey] rather than matching this string, so a user who
/// types these exact words is not rendered as an undecryptable message.
const String undecryptableMessagePlaceholder = 'Message cannot be decrypted';

/// Whether [metadata] marks its message as undecryptable.
bool isUndecryptable(Map<String, String> metadata) =>
    metadata[undecryptableMetadataKey] == 'true';

/// Returns [metadata] with the undecryptable marker set.
Map<String, String> markUndecryptable(Map<String, String> metadata) => {
      ...metadata,
      undecryptableMetadataKey: 'true',
    };
