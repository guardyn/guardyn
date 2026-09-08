---
id: rules-invariants
type: rules
status: accepted
owns: [backend/crates/crypto/, backend/proto/, docker-compose.dev.yml]
read_when: [starting any session, touching crypto, changing configuration]
---

# 00 · Invariants

Predicates for [`AGENTS.md`](../../AGENTS.md) §1. AGENTS.md states the law; this file
states how to **test** it. Where the two disagree, AGENTS.md wins.

**Read this first, every session.** Flipping a predicate from PASS to FAIL is forbidden.
If a task appears to require it, stop and ask the user.

**Convention: every check prints its violations. Empty output means PASS.**

| ID | Invariant | Predicate | Today | Owned by |
|---|---|---|---|---|
| `ZK-INIT` | I-1 | Tracing is initialised only via `guardyn_common::observability::init_tracing` | PASS | `rules-verify` |
| `ZK-PII` | I-1 | No log macro is passed a raw IP, email or phone number | FAIL (2) | **none — open an issue** |
| `E2EE-FLAG` | I-2 | No configuration key can turn encryption off | PASS | `rules-verify` |
| `E2EE-DUP` | I-2 | No handler has a non-E2EE twin | PASS | `rules-verify` |
| `PQ-DEFAULT` | I-3 | The `pq` feature is on by default in the crypto crate | FAIL | PR-38 |
| `PQ-WIRE` | I-3 | The wire contract carries ML-KEM key material | FAIL | PR-36 |
| `SOV-DOMAIN` | I-4 | Every hostname derives from `${DOMAIN}` | FAIL (1) | **none — open an issue** |
| `SOV-STORE` | I-4 | No datastore added, replaced or removed without an accepted ADR | PASS | reviewer |

Run from the repository root:

```sh
echo "ZK-INIT";    grep -rln --include='*.rs' -e FmtSubscriber -e 'tracing_subscriber::fmt()' backend/crates/*/src
echo "ZK-PII";     grep -rnE '(trace|debug|info|warn|error)!\(' --include='*.rs' backend/crates/*/src \
                     | grep -iE '"[^"]*\b(ip|email|phone)\b[^"]*"[^)]*,'
echo "E2EE-FLAG";  grep -rln 'GUARDYN_E2EE_ENABLED\|GUARDYN_MLS_ENABLED' backend infra docker-compose.dev.yml
echo "E2EE-DUP";   ls backend/crates/messaging-service/src/handlers/*_e2ee.rs 2>/dev/null
echo "PQ-DEFAULT"; grep -E '^default = ' backend/crates/crypto/Cargo.toml | grep -v '"pq"'
echo "PQ-WIRE";    grep -rL 'ml_kem' backend/proto/common.proto
echo "SOV-DOMAIN"; grep -rn 'host:' infra/k8s --include='*.yaml' | grep -v DOMAIN
```

## Reading the failures

`E2EE-DUP` passed as of PR-32a and is now enforced by `rules-verify` rather than tracked
here. It is inverted on purpose: a `*_e2ee.rs` file existing *proves* a non-E2EE original
still sits beside it, and one of the two paths has to be the wrong one.

**It was the `_e2ee` one.** [`AGENTS.md`](../../AGENTS.md) §1 directed PR-32 to collapse onto
those handlers, which is backwards: `send_message_e2ee.rs:129` encrypted the client's plaintext
*server-side* and `receive_messages_e2ee.rs:177` returned plaintext. The unsuffixed handler was
already the zero-knowledge relay. Collapsing the other way would have traded an I-2 violation for
an I-1 one. §1 also says four such pairs existed; the measured count was **two**
(`send_message`, `receive_messages`). PR-31d (#153) amends §1.

`PQ-WIRE` fails while `crypto/src/pqxdh.rs` is a complete hybrid X25519 + ML-KEM-768
implementation. It is unreached, not absent — no proto field can carry the public key.

**A known failure is not licence to patch it.** Four of these have an owned step; fixing one
outside that step breaks the micro-step contract. The two marked *none* were found while
writing this file and need an issue opened before any fix.

## Detail

Logging rules: [`30-zk-logging.md`](30-zk-logging.md).
Datastore, proto and Rust rules: [`20-code-style.md`](20-code-style.md).
