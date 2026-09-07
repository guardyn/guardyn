---
id: adr-0007
type: adr
status: accepted
owns: [backend/crates/common/src/observability.rs, backend/crates/common/src/redact.rs]
read_when: [adding a log line, touching observability, adding a metric]
tokens: 515
supersedes: []
---

# ADR-0007 · Zero-knowledge logging and mandatory redaction

## Status

`accepted`. Two known violations, both named below.

## Context

End-to-end encryption is undone by a log line. A server that cannot decrypt a message but
prints the plaintext during handling — or prints the key, or the user's IP — offers no more
protection than one that never encrypted anything. Logs are also the artefact most likely
to leave the trust boundary: shipped to aggregators, attached to tickets, seized.

**I-1** therefore has to be enforced structurally. A convention that says "be careful" fails
on the first debug statement written at 2 a.m.

## Decision

Tracing is initialised **only** through `guardyn_common::observability::init_tracing`, which
installs the redaction layer. Constructing a `tracing_subscriber` directly is forbidden.
Key- and payload-bearing types never `#[derive(Debug)]`; they implement `Debug` to emit
`[REDACTED]`, or are wrapped in `Redacted<T>`.

Two mechanisms, shipped in `common/src/redact.rs` (PR-24):

- **`Redacted<T>`** — `Debug` and `Display` emit `[REDACTED]` with **no bound on `T`**, so a
  containing struct may keep `#[derive(Debug)]`. `Serialize`/`Deserialize` are deliberately
  **transparent**: several crypto and messaging types derive `Serialize` for *persistence*, and
  a redacting serializer would write `[REDACTED]` into TiKV and destroy the stored key material.
  This is sound because `tracing` never routes through `serde::Serialize` on our types —
  `tracing_serde` serializes what a `Visit` recorded, which is `Debug` or `Display`.
- **`DENIED_FIELDS`** — the companion denylist of log field names whose values must never be
  emitted. Matching is exact and case-insensitive, never substring: a substring rule on `key`
  would fire on `key_id`, and identifiers are metadata, not key material.
- **`RedactingFormat`** — a `FormatEvent` that replaces the value of any event field named on
  that denylist, and emits a `redacted: [names]` array so a hit is alertable rather than
  silently swallowed. Events carrying no denied field are delegated untouched, so the common
  path is byte-identical.

It is a `FormatEvent` rather than a `Layer` because a `Layer` receives `&Event` and cannot
remove or rewrite a field — the `fmt` layer downstream re-reads the original event regardless.

## Consequences

Redaction cannot be forgotten, because it is not a per-call-site decision. Every service
must route through `common`, and a service that wants a bespoke subscriber cannot have one.

Debugging is harder by design: correlating an incident means using `user_id`/`device_id`
sparingly rather than dumping a request. That difficulty is the feature.

**Known violations.** `common/src/rate_limit.rs:241,256` log a raw client IP — PII under this
ADR — and have **no owned step**; note the denylist cannot reach them, because they
interpolate the IP positionally into `message` rather than naming a field.

**Span fields are not yet redacted.** `RedactingFormat` covers event fields only. `JsonFields`
overrides `add_fields` to re-parse and re-serialize, so a naive `FormatFields` emits malformed
JSON on the six live `Span::current().record` handlers in `messaging-service`. Unowned.

## Alternatives rejected

**Log-level discipline** — a `debug!` that never runs in production still gets enabled
during an incident, which is exactly when the data is most sensitive. **Scrubbing at the
aggregator** — too late; the data has already left the process.
