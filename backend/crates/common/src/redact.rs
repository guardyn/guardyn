//! Redaction primitives for zero-knowledge logging (invariant I-1).
//!
//! Two independent mechanisms live here.
//!
//! [`Redacted<T>`] is a newtype whose `Debug` and `Display` impls emit
//! [`REDACTED`] whatever `T` is. Wrap a field in it and the containing struct
//! may keep `#[derive(Debug)]` without leaking that field.
//!
//! [`RedactingFormat`] is a `tracing` event formatter that replaces the value of
//! any field whose *name* appears in [`DENIED_FIELDS`], and records which names
//! were hit so the incident is alertable rather than merely suppressed.
//!
//! `Redacted<T>`'s `Serialize` and `Deserialize` impls are deliberately
//! **transparent**. Several crypto and messaging types derive `Serialize` for
//! *persistence*; a redacting serializer would write `[REDACTED]` into TiKV and
//! destroy the stored key material. This is safe because `tracing`'s JSON output
//! never routes through `serde::Serialize` on our types — `tracing_serde`
//! serializes whatever a [`tracing::field::Visit`] recorded, which is `Debug` or
//! `Display`. Redacting those two is exactly sufficient for I-1.

use std::fmt;
use std::time::{SystemTime, UNIX_EPOCH};

use serde::{Deserialize, Deserializer, Serialize, Serializer};
use serde_json::Value;
use tracing::field::{Field, Visit};
use tracing::{Event, Subscriber};
use tracing_subscriber::fmt::format::Writer;
use tracing_subscriber::fmt::{FmtContext, FormatEvent, FormatFields};
use tracing_subscriber::registry::LookupSpan;

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

// =============================================================================
// RedactingFormat
// =============================================================================

/// A `tracing` event formatter that redacts denied fields before they are written.
///
/// Wraps an inner [`FormatEvent`] (in this crate, the JSON formatter). Events
/// carrying no denied field are delegated to the inner formatter untouched, so
/// the common path is byte-for-byte identical to formatting without this wrapper.
///
/// This is a `FormatEvent` rather than a `Layer` because a `Layer` receives
/// `&Event` and cannot remove or rewrite a field — the `fmt` layer downstream
/// would re-read the original event regardless.
pub struct RedactingFormat<F> {
    inner: F,
}

impl<F> RedactingFormat<F> {
    /// Wrap `inner` so that denied fields are redacted before it sees them.
    pub const fn new(inner: F) -> Self {
        Self { inner }
    }
}

impl<S, N, F> FormatEvent<S, N> for RedactingFormat<F>
where
    S: Subscriber + for<'a> LookupSpan<'a>,
    N: for<'a> FormatFields<'a> + 'static,
    F: FormatEvent<S, N>,
{
    fn format_event(
        &self,
        ctx: &FmtContext<'_, S, N>,
        mut writer: Writer<'_>,
        event: &Event<'_>,
    ) -> fmt::Result {
        let metadata = event.metadata();

        // Fast path: the field set is `&'static` metadata, so this inspects names
        // only and never touches a value.
        if !metadata.fields().iter().any(|f| is_denied(f.name())) {
            return self.inner.format_event(ctx, writer, event);
        }

        let mut visitor = RedactingVisitor::default();
        event.record(&mut visitor);

        let mut out = serde_json::Map::new();
        out.insert("timestamp_ms".to_owned(), Value::from(unix_millis()));
        out.insert(
            "level".to_owned(),
            Value::String(metadata.level().to_string()),
        );
        out.insert(
            "target".to_owned(),
            Value::String(metadata.target().to_owned()),
        );
        if let Some(file) = metadata.file() {
            out.insert("filename".to_owned(), Value::String(file.to_owned()));
        }
        if let Some(line) = metadata.line() {
            out.insert("line_number".to_owned(), Value::from(line));
        }
        out.insert("fields".to_owned(), Value::Object(visitor.fields));
        out.insert(
            "redacted".to_owned(),
            Value::Array(visitor.redacted.into_iter().map(Value::String).collect()),
        );

        let rendered = serde_json::to_string(&out).map_err(|_| fmt::Error)?;
        writeln!(writer, "{}", rendered)
    }
}

/// Records event fields into a JSON map, substituting [`REDACTED`] for denied names.
#[derive(Default)]
struct RedactingVisitor {
    fields: serde_json::Map<String, Value>,
    redacted: Vec<String>,
}

impl RedactingVisitor {
    /// Insert `field`, calling `value` only when the field is permitted.
    fn record<V: FnOnce() -> Value>(&mut self, field: &Field, value: V) {
        let name = field.name();
        if is_denied(name) {
            self.redacted.push(name.to_owned());
            self.fields
                .insert(name.to_owned(), Value::String(REDACTED.to_owned()));
        } else {
            self.fields.insert(name.to_owned(), value());
        }
    }
}

impl Visit for RedactingVisitor {
    fn record_str(&mut self, field: &Field, value: &str) {
        self.record(field, || Value::String(value.to_owned()));
    }

    fn record_i64(&mut self, field: &Field, value: i64) {
        self.record(field, || Value::from(value));
    }

    fn record_u64(&mut self, field: &Field, value: u64) {
        self.record(field, || Value::from(value));
    }

    fn record_bool(&mut self, field: &Field, value: bool) {
        self.record(field, || Value::Bool(value));
    }

    fn record_f64(&mut self, field: &Field, value: f64) {
        self.record(field, || Value::from(value));
    }

    fn record_debug(&mut self, field: &Field, value: &dyn fmt::Debug) {
        self.record(field, || Value::String(format!("{:?}", value)));
    }
}

/// Milliseconds since the Unix epoch, or 0 if the clock is before it.
///
/// `common` has no `chrono` dependency and the redacting path is a bug detector
/// rather than the steady state, so it carries its own timestamp key.
fn unix_millis() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_millis() as u64)
        .unwrap_or(0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::{self, Write};
    use std::sync::{Arc, Mutex};
    use tracing_subscriber::fmt::MakeWriter;
    use tracing_subscriber::layer::SubscriberExt;

    #[derive(Clone, Default)]
    struct BufWriter(Arc<Mutex<Vec<u8>>>);

    impl Write for BufWriter {
        fn write(&mut self, buf: &[u8]) -> io::Result<usize> {
            let mut guard = self
                .0
                .lock()
                .map_err(|_| io::Error::other("buffer poisoned"))?;
            guard.extend_from_slice(buf);
            Ok(buf.len())
        }
        fn flush(&mut self) -> io::Result<()> {
            Ok(())
        }
    }

    impl<'a> MakeWriter<'a> for BufWriter {
        type Writer = BufWriter;
        fn make_writer(&'a self) -> Self::Writer {
            self.clone()
        }
    }

    /// Run `f` under a subscriber wired exactly as `init_tracing` wires it.
    fn capture(f: impl FnOnce()) -> String {
        let buf = BufWriter::default();
        let layer = tracing_subscriber::fmt::layer()
            .fmt_fields(tracing_subscriber::fmt::format::JsonFields::new())
            .event_format(RedactingFormat::new(
                tracing_subscriber::fmt::format()
                    .json()
                    .with_file(true)
                    .with_line_number(true)
                    .with_target(true),
            ))
            .with_writer(buf.clone());
        tracing::subscriber::with_default(tracing_subscriber::registry().with(layer), f);
        let bytes = buf.0.lock().expect("buffer poisoned").clone();
        String::from_utf8(bytes).expect("formatter emitted invalid UTF-8")
    }

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

    #[test]
    fn test_denied_field_value_never_reaches_the_writer() {
        let output = capture(|| {
            tracing::info!(user_id = "u1", ciphertext = "TOPSECRET", "message stored");
        });

        assert!(!output.contains("TOPSECRET"), "secret leaked: {output}");
        assert!(output.contains(REDACTED));
        assert!(output.contains("\"ciphertext\""), "the field name is kept");
        assert!(output.contains("u1"), "identifiers survive redaction");
        assert!(
            output.contains("\"redacted\":[\"ciphertext\"]"),
            "the hit must be alertable: {output}"
        );
        serde_json::from_str::<Value>(output.trim()).expect("redacting path must emit valid JSON");
    }

    #[test]
    fn test_clean_event_takes_the_fast_path_unchanged() {
        let output = capture(|| {
            tracing::info!(user_id = "u1", "message stored");
        });

        let parsed: Value = serde_json::from_str(output.trim()).expect("valid JSON");
        assert_eq!(parsed["fields"]["message"], "message stored");
        assert_eq!(parsed["fields"]["user_id"], "u1");
        assert!(
            parsed.get("redacted").is_none(),
            "clean events must not gain a redacted key: {output}"
        );
    }
}
