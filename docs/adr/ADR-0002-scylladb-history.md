---
id: adr-0002
type: adr
status: accepted
owns: [backend/crates/messaging-service/src/db.rs, backend/crates/call-service/src, backend/crates/notification-service/src]
read_when: [changing history storage, adding a time-series table]
tokens: 346
supersedes: []
---

# ADR-0002 · ScyllaDB for message, call and notification history

## Status

`accepted`

## Context

History is append-heavy, read in time order, partitioned naturally by conversation, and
never joined. It is also the largest data set in the system and grows without bound.

Message bodies are ciphertext the server cannot read, so the store needs no query
capability over content — only "give me this partition, newest first, paged".

## Decision

ScyllaDB stores message, call and notification history. TiKV (ADR-0001) keeps metadata.

## Consequences

Wide-column partitions match the access pattern exactly, and writes stay cheap as history
grows. Two datastores must be operated instead of one, and a write that spans both is not
atomic — services must tolerate partial failure rather than assume a transaction.

Content search must happen on the client (see `PRD.md`); no server-side index is possible
over ciphertext.

## Alternatives rejected

**TiKV for everything** — the range-scan pattern for long histories degrades. **Cassandra**
— same data model, heavier operational footprint for a self-hoster.
