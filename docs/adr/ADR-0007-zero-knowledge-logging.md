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
`[REDACTED]`, or are wrapped in `Redacted<T>` (PR-24).

## Consequences

Redaction cannot be forgotten, because it is not a per-call-site decision. Every service
must route through `common`, and a service that wants a bespoke subscriber cannot have one.

Debugging is harder by design: correlating an incident means using `user_id`/`device_id`
sparingly rather than dumping a request. That difficulty is the feature.

**Known violations.** `call-service` and `notification-service` build a `FmtSubscriber`
directly (PR-26). `common/src/rate_limit.rs:241,256` log a raw client IP — PII under this
ADR — and have **no owned step**.

## Alternatives rejected

**Log-level discipline** — a `debug!` that never runs in production still gets enabled
during an incident, which is exactly when the data is most sensitive. **Scrubbing at the
aggregator** — too late; the data has already left the process.
