---
id: adr-0006
type: adr
status: accepted
owns: [docker-compose.dev.yml, infra/k8s/base/]
read_when: [considering a cache, observing latency]
tokens: 377
supersedes: []
---

# ADR-0006 · No Dragonfly/Redis L1 cache before launch

## Status

`accepted`

## Context

The obvious reflex when a read path looks slow is to put a cache in front of it. Guardyn
has no cache tier, and its absence is frequently read as an oversight.

There is no measured latency problem. TiKV serves key-by-id reads directly, and the largest
read volume — message history — is paged from ScyllaDB partitions that are already ordered
for it.

## Decision

No Dragonfly, Redis, or other cache layer before launch. Revisit only with production
measurements showing a specific hot path that a cache would fix.

## Consequences

One fewer component to deploy, secure, and keep consistent — and no cache-invalidation
class of bug in a system whose correctness is security-relevant. A self-hoster's footprint
stays smaller, which serves **I-4**.

If a genuine hot path emerges, the change is additive and this ADR is superseded rather
than quietly ignored.

Note `presence-service/src/db.rs` carries a "would use Redis" comment. That is a leftover,
not a plan; PR-29 replaces it with a TTL-correct TiKV implementation.

## Alternatives rejected

**Adding Redis now** — a cache added before a measurement is a guess with an uptime cost.
**Dragonfly** — same argument; a better Redis is still a component nothing currently needs.
