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
| `ZK-PII` | I-1 | No log macro is passed a raw IP, email or phone number | PASS | `rules-verify` |
| `E2EE-FLAG` | I-2 | No configuration key can turn encryption off | PASS | `rules-verify` |
| `E2EE-DUP` | I-2 | No handler has a non-E2EE twin | PASS | `rules-verify` |
| `PQ-DEFAULT` | I-3 | The `pq` feature is on by default in the crypto crate | PASS | `rules-verify` |
| `PQ-WIRE` | I-3 | The wire contract carries ML-KEM key material | PASS | reviewer |
| `SOV-DOMAIN` | I-4 | Every hostname derives from `${DOMAIN}` | FAIL (1) | **none — tracked by #82** |
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

`E2EE-FLAG` passed with PR-32c. PR-32b removed the flags from the code, so `E2eeConfig` and
`MlsConfig` no longer exist and nothing in the backend reads an encryption switch; PR-32c then
deleted the variables that were still being set in `docker-compose.dev.yml` and the two k8s
manifests. Between those two steps the variables were inert - which is worth remembering, because
a deployment file that looks like a kill switch reads as one whether or not any code consults it,
and the prod overlay's `GUARDYN_E2EE_ENABLED: "true"` was actively misleading about where
encryption came from.

`PQ-WIRE` passed with PR-36, which added `ml_kem_public` and `ml_kem_public_signature` to
`common.KeyBundle` as tags 6 and 7. The predicate asks only whether the **wire contract** can
carry the material, and it now can. Nothing else changed: `crypto/src/pqxdh.rs` is still
unreached, nothing populates the fields, and `auth-service` still drops them on store. Read
this row as "the blocker is gone", not "the invariant holds" — I-3 is met when PR-40 closes,
not here.

**Its owner is `reviewer`, not `rules-verify`, and that is a real gap.** `PQ-WIRE` is written
out in the shell block above but has no counterpart in
[`rules-verify.sh`](../../infra/scripts/rules-verify.sh), so nothing in CI stops the fields
being removed again. Every other PASS row on this table is machine-defended; this one is
defended by somebody noticing. Automating it is unowned work.

`PQ-DEFAULT` passed with PR-38, which put `pq` in `guardyn-crypto`'s `default` set. It is
enforced by `rules-verify` from the same PR that fixed it, rather than being added to the
table as a second undefended PASS row beside `PQ-WIRE`.

**What that step actually changed is narrower and worse than the row suggests.** A
`cargo test --workspace` build already had `pq`, because `crypto-ffi` declares
`default = ["full"] = ["pq"]` and Cargo unifies features across a workspace build. So CI was
running `test_hybrid_key_exchange` and `test_hybrid_key_bundle_with_pq` the whole time, and the
hybrid path looked exercised.

Every service is deployed from `cargo build --release -p <service>`
(`backend/crates/*/Dockerfile`), and a single-package build unifies nothing. Before PR-38
`cargo tree -p guardyn-auth-service -i ml-kem` answered *"did not match any packages"*: the
shipped binaries contained no post-quantum code at all, while the test build proved it worked.
A green suite and an empty binary is the most expensive shape this class of defect takes, and
it is worth remembering that feature unification is what hid it.

**A known failure is not licence to patch it.** There is no failing predicate on this table
with an owning step left; `SOV-DOMAIN` remains the one failure, and it has **none**.

`ZK-PII` and `SOV-DOMAIN` were both found while writing this file, with no owning step. Each had
an issue opened before any fix. `ZK-PII` is now closed by #81 and enforced by `rules-verify`;
`SOV-DOMAIN` is tracked by #82 and still has **no roadmap step**.

## Detail

Logging rules: [`30-zk-logging.md`](30-zk-logging.md).
Datastore, proto and Rust rules: [`20-code-style.md`](20-code-style.md).
