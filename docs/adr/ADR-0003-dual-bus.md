---
id: adr-0003
type: adr
status: accepted
owns: [backend/crates/common/src/kafka.rs, backend/crates/common/src/events.rs]
read_when: [adding an event, choosing a transport]
tokens: 367
supersedes: []
---

# ADR-0003 · Dual bus — NATS for signalling, Redpanda for the durable log

## Status

`accepted`

## Context

Two traffic classes with opposite requirements coexist. Presence beats, typing indicators
and call setup are worthless a second late and must never block. Message events must
survive a broker restart, replay in order, and drive downstream consumers such as push
notification delivery.

One bus tuned for both would be tuned for neither.

## Decision

NATS carries ephemeral signalling. Redpanda carries the durable event log, via
`EventEnvelope`. Both are intentional and neither is redundant.

## Consequences

Each transport is matched to its traffic, and a lost presence beat is correct behaviour
while a lost message event is data loss. The cost is two brokers to deploy, monitor and
understand, and a standing question at every new event: which bus?

The rule: if losing it is acceptable, NATS; if it must be replayable, Redpanda.

**Do not consolidate them.** A future reader will see two message buses and assume
redundancy.

## Alternatives rejected

**NATS JetStream for both** — durable, but the operational model for long retention is
weaker than Redpanda's. **Kafka** — same protocol as Redpanda, with a JVM a self-hoster
must then run.
