---
id: adr-index
type: index
status: accepted
owns: [docs/adr/]
read_when: [proposing a change to a decided thing, writing an ADR]
tokens: 618
supersedes: []
---

# Architectural decisions

An ADR records a decision **already embodied in the code**. It is a record, not a proposal:
if the code does not do it, the ADR says so explicitly rather than describing intent as
though it were fact.

Adding, replacing or removing a datastore, message bus, or major dependency requires an
accepted ADR **and** explicit user approval (`AGENTS.md` §5.3).

| ADR | Decision | Status |
|---|---|---|
| [0001](ADR-0001-tikv-metadata-store.md) | TiKV as the metadata, auth and MLS-state store — deliberately not PostgreSQL | accepted |
| [0002](ADR-0002-scylladb-history.md) | ScyllaDB for message, call and notification history | accepted |
| [0003](ADR-0003-dual-bus.md) | Dual bus — NATS for signalling, Redpanda for the durable log | accepted |
| [0004](ADR-0004-openmls-group-e2ee.md) | OpenMLS 0.6 for groups; own X3DH and Double Ratchet rather than libsignal | accepted |
| [0005](ADR-0005-hybrid-pqxdh.md) | Hybrid PQXDH (X25519 + ML-KEM-768) | accepted — **target, not met** |
| [0006](ADR-0006-no-cache-layer.md) | No Dragonfly/Redis cache layer before launch | accepted |
| [0007](ADR-0007-zero-knowledge-logging.md) | Zero-knowledge logging and mandatory redaction | accepted — **2 known violations** |
| [0008](ADR-0008-protobuf-codegen.md) | Generated protobuf in `OUT_DIR`, not committed | accepted — **3 strategies coexist** |
| [0009](ADR-0009-micro-step-budget.md) | Micro-step PR budget and branch isolation | accepted |

[`ADR-0000-template.md`](ADR-0000-template.md) is the shape. Copy it and take the next free
number.

## Decisions that are not yet met

Three ADRs are accepted as the target while the code does something else. This is recorded
deliberately — the alternative is an ADR set that reads as a description of the system and
is quietly wrong.

| ADR | Gap | Owned by |
|---|---|---|
| 0005 | `pq` feature off by default; **no ML-KEM field in any proto**, so no PQ key can be published | PR-36…PR-40 |
| 0007 | `call-service` and `notification-service` build a `FmtSubscriber` directly; `rate_limit.rs:241,256` log a raw IP | PR-26; the IP leak is **unowned** |
| 0008 | Committed generated protobuf in `backend/crates/*/src/generated/` **and** `client-desktop/src-tauri/src/proto/`, while `messaging-service` uses `include_proto!` | PR-23 |
