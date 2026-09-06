---
id: adr-0001
type: adr
status: accepted
owns: [backend/crates/auth-service/src/db.rs, backend/crates/presence-service/src/db.rs]
read_when: [changing the metadata store, adding a table]
tokens: 368
supersedes: []
---

# ADR-0001 · TiKV as the metadata, auth and MLS-state store

## Status

`accepted`

## Context

The project brief specified PostgreSQL. The implementation uses TiKV, and every service
that stores metadata — auth records, device registry, contacts, key bundles, MLS group
state — talks to it. The divergence is deliberate and predates this documentation base.

Guardyn must be self-hostable on anything from one machine to a cluster (**I-4**), and the
access pattern is overwhelmingly key-by-id with occasional range scans, not relational
joins.

## Decision

TiKV is the metadata, auth and MLS-state store. PostgreSQL is not used.

## Consequences

Horizontal scaling and transactional key-value semantics without an operational relational
tier. No joins, no ad-hoc SQL, no migration tooling that assumes a schema — data shape is
enforced in Rust, not by the database. Range-scan design becomes a modelling concern rather
than an afterthought.

Anyone reading the brief will believe PostgreSQL is intended. **It is not.** Do not "fix"
this.

## Alternatives rejected

**PostgreSQL** — relational guarantees the workload does not need, and a scaling story that
would force sharding later. **etcd** — sized for configuration, not for user data.
