//! Redaction primitives for zero-knowledge logging (invariant I-1).
//!
//! [`Redacted<T>`] is a newtype whose `Debug` and `Display` impls emit
//! [`REDACTED`] whatever `T` is. Wrap a field in it and the containing struct
//! may keep `#[derive(Debug)]` without leaking that field.
//!
//! [`DENIED_FIELDS`] is the companion denylist of log field names whose values
//! must never be emitted. The `tracing` formatter that enforces it consumes this
//! list; this module supplies the vocabulary.
//!
//! `Redacted<T>`'s `Serialize` and `Deserialize` impls are deliberately
//! **transparent**. Several crypto and messaging types derive `Serialize` for
//! *persistence*; a redacting serializer would write `[REDACTED]` into TiKV and
//! destroy the stored key material. This is safe because `tracing`'s JSON output
//! never routes through `serde::Serialize` on our types — `tracing_serde`
//! serializes whatever a `tracing::field::Visit` recorded, which is `Debug` or
//! `Display`. Redacting those two is exactly sufficient for I-1.

use std::fmt;

use serde::{Deserialize, Deserializer, Serialize, Serializer};

/// The placeholder substituted for every redacted value.
pub const REDACTED: &str = "[REDACTED]";

// =============================================================================
// Redacted<T>
// =============================================================================

/// A wrapper that makes its contents unprintable.
///
/// The `Debug` and `Display` impls carry **no bound on `T`**, which is the whole
/// point: there is no way to reach `T`'s own `Debug` through the wrapper, so a
/// `{:?}` on the containing struct cannot leak the value.
///
/// `Deref`, `AsRef` and `PartialEq` are deliberately **not** implemented —
/// `Deref` would resurrect `T`'s `Debug` by auto-deref at a `{:?}` site and
/// defeat the type entirely.
///
/// ```
/// use guardyn_common::redact::Redacted;
///
/// #[derive(Debug)]
/// struct Session {
///     user_id: String,
///     token: Redacted<String>,
/// }
///
/// let s = Session { user_id: "u1".into(), token: Redacted::new("hunter2".into()) };
/// assert!(!format!("{:?}", s).contains("hunter2"));
/// assert_eq!(s.token.expose(), "hunter2");
/// ```
pub struct Redacted<T>(T);

impl<T> Redacted<T> {
    /// Wrap `inner` so that it cannot be printed.
    pub const fn new(inner: T) -> Self {
        Self(inner)
    }

    /// Borrow the protected value.
    ///
    /// Named to be conspicuous and greppable: every call site is a place where
    /// secret material escapes the wrapper and deserves a reviewer's attention.
    pub fn expose(&self) -> &T {
        &self.0
    }

    /// Mutably borrow the protected value. See [`Redacted::expose`].
    pub fn expose_mut(&mut self) -> &mut T {
        &mut self.0
    }

    /// Consume the wrapper and return the protected value.
    pub fn into_inner(self) -> T {
        self.0
    }
}

impl<T> fmt::Debug for Redacted<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(REDACTED)
    }
}

impl<T> fmt::Display for Redacted<T> {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(REDACTED)
    }
}

impl<T: Clone> Clone for Redacted<T> {
    fn clone(&self) -> Self {
        Self(self.0.clone())
    }
}

impl<T: Default> Default for Redacted<T> {
    fn default() -> Self {
        Self(T::default())
    }
}

impl<T> From<T> for Redacted<T> {
    fn from(inner: T) -> Self {
        Self(inner)
    }
}

/// Transparent: delegates to `T`. See the module docs for why this must not redact.
impl<T: Serialize> Serialize for Redacted<T> {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        self.0.serialize(serializer)
    }
}

/// Transparent: delegates to `T`. See the module docs for why this must not redact.
impl<'de, T: Deserialize<'de>> Deserialize<'de> for Redacted<T> {
    fn deserialize<D: Deserializer<'de>>(deserializer: D) -> Result<Self, D::Error> {
        T::deserialize(deserializer).map(Redacted)
    }
}

// =============================================================================
// Field denylist
// =============================================================================

/// Log field names whose values must never be emitted.
///
/// Matching is **exact** (ASCII-case-insensitive), never substring: a substring
/// rule on `key` would fire on `key_id`, and identifiers are metadata rather
/// than key material. This mirrors the `_id` carve-out that
/// `.claude/rules/30-zk-logging.md` already grants the `ZK-PAYLOAD` predicate.
pub const DENIED_FIELDS: &[&str] = &[
    // Payload material
    "ciphertext",
    "plaintext",
    "payload",
    "content",
    "encrypted_content",
    // Key material
    "key",
    "private_key",
    "secret_key",
    "shared_secret",
    "secret",
    "identity_key",
    "signing_key",
    "pre_key",
    "prekey",
    "ratchet_state",
    "group_state",
    "mls_secret",
    "ml_kem_private",
    "x25519_private",
    // Credentials
    "token",
    "session_token",
    "access_token",
    "refresh_token",
    "password",
    "password_hash",
    "jwt_secret",
    // PII
    "email",
    "phone",
    "ip",
    "ip_address",
    "client_ip",
];

/// Whether a log field name is on the denylist.
pub fn is_denied(field_name: &str) -> bool {
    DENIED_FIELDS
        .iter()
        .any(|denied| denied.eq_ignore_ascii_case(field_name))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_redacted_debug_and_display_hide_the_value() {
        let secret = Redacted::new("hunter2");
        assert_eq!(format!("{:?}", secret), REDACTED);
        assert_eq!(format!("{}", secret), REDACTED);
    }

    #[test]
    fn test_derived_debug_on_containing_struct_leaks_nothing() {
        // Fields are read only through the derived `Debug`, which dead-code
        // analysis deliberately ignores.
        #[derive(Debug)]
        #[allow(dead_code)]
        struct Session {
            user_id: String,
            ratchet_state: Redacted<Vec<u8>>,
        }

        let s = Session {
            user_id: "u1".to_owned(),
            ratchet_state: Redacted::new(vec![0xDE, 0xAD, 0xBE, 0xEF]),
        };
        let rendered = format!("{:?}", s);
        assert!(rendered.contains("u1"), "identifiers stay visible");
        assert!(rendered.contains(REDACTED));
        assert!(!rendered.contains("222"), "byte 0xDE must not appear");
        assert!(!rendered.contains("173"), "byte 0xAD must not appear");
    }

    #[test]
    fn test_serde_is_transparent_so_persistence_is_not_corrupted() {
        let wrapped = Redacted::new("hunter2".to_owned());
        let json = serde_json::to_string(&wrapped).expect("serialize");
        assert_eq!(json, "\"hunter2\"");

        let back: Redacted<String> = serde_json::from_str(&json).expect("deserialize");
        assert_eq!(back.expose(), "hunter2");
    }

    #[test]
    fn test_is_denied_matches_exactly_and_spares_identifiers() {
        for denied in [
            "ciphertext",
            "jwt_secret",
            "ratchet_state",
            "key",
            "CipherText",
        ] {
            assert!(is_denied(denied), "{denied} must be denied");
        }
        for allowed in [
            "user_id",
            "key_id",
            "session_id",
            "device_id",
            "group_id",
            "message_id",
        ] {
            assert!(
                !is_denied(allowed),
                "{allowed} is metadata, not key material"
            );
        }
    }
}
