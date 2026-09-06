---
id: rules-zk-logging
type: rules
status: accepted
owns: [backend/crates/common/src/observability.rs, backend/crates/common/src/redact.rs]
read_when: [adding a log line, touching observability, adding a metric or span]
---

# 30 · Zero-knowledge logging

Predicates for [`AGENTS.md`](../../AGENTS.md) §4, enforcing invariant **I-1**. This is the
invariant most easily broken by a one-line "helpful" debug statement, so it gets its own file.

**Convention: every check prints its violations. Empty output means PASS.**

| ID | Predicate | Today |
|---|---|---|
| `ZK-INIT` | Tracing is initialised only via `guardyn_common::observability::init_tracing` | FAIL — 2 services, PR-26 |
| `ZK-PII` | No log macro is passed a raw IP, email or phone number | FAIL — 2 sites, no owner |
| `ZK-PAYLOAD` | No log macro names ciphertext, plaintext, payload or key material | PASS |
| `ZK-STRUCT` | No whole request or response struct is interpolated | PASS |
| `ZK-DEBUG` | No `#[derive(Debug)]` on a crypto type that holds key material | review trigger |

```sh
echo "ZK-INIT";    grep -rln --include='*.rs' -e FmtSubscriber -e 'tracing_subscriber::fmt()' backend/crates/*/src
echo "ZK-PII";     grep -rnE '(trace|debug|info|warn|error)!\(' --include='*.rs' backend/crates/*/src \
                     | grep -iE '"[^"]*\b(ip|email|phone)\b[^"]*"[^)]*,'
echo "ZK-PAYLOAD"; grep -rnE '(trace|debug|info|warn|error)!\(' --include='*.rs' backend/crates/*/src \
                     | grep -v '/generated/' \
                     | grep -iE '\b(ciphertext|plaintext|payload|secret_key|private_key|shared_secret)\b' \
                     | grep -v '_id'
echo "ZK-STRUCT";  grep -rnE '(trace|debug|info|warn|error)!\([^)]*(req|request|resp|response)[a-z_]*\)' \
                     --include='*.rs' backend/crates/*/src | grep '{:?}'
echo "ZK-DEBUG";   grep -rn 'derive(.*Debug' --include='*.rs' backend/crates/crypto/src | grep -v frb_generated
```

## Never emit — in a log, a span, a metric label, or on stdout

Message, file or media **plaintext or ciphertext** · any key material (identity keys,
pre-keys, ratchet state, MLS secrets, ML-KEM private keys) · tokens, passwords, password
hashes, session secrets · PII: email, phone number, **IP address**, precise location.

When unsure whether a field is sensitive: **do not log it.**

## Why `ZK-DEBUG` is a review trigger, not a pass/fail

`derive(Debug)` is not itself a breach — it is a breach the moment such a value reaches a
`{:?}`. The crypto crate has 8 sites, several on types in `x3dh.rs`, `key_storage.rs` and
`sealed_sender.rs` that plausibly hold key material. Each needs a human read, not a grep
verdict. Implement `Debug` by hand to emit `[REDACTED]`, or wrap the field in `Redacted<T>`
from `guardyn-common` once PR-24 lands.

## Identifiers are metadata, not free

`user_id` and `device_id` are correlatable. Log them only when an operation genuinely needs
them, and never at `info` on a hot path. `ZK-PAYLOAD` deliberately excludes `*_id` matches —
the four `ratchet session: {session_id}` lines in `messaging-service` are identifiers, not
key material, and are allowed under that rule.

## The two failures with no owned step

`ZK-PII` fires on `common/src/rate_limit.rs:241` and `:256`, which log a raw client IP.
`AGENTS.md` §4 lists IP address as PII. This was found while writing these predicates and
has no step in `implementation_plan.md` — open an issue before fixing it.
