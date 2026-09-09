---
id: adr-0010
type: adr
status: accepted
owns: [backend/crates/messaging-service/src/mls_manager.rs, backend/crates/messaging-service/src/handlers/send_message.rs, backend/crates/messaging-service/src/handlers/receive_messages.rs]
read_when: [touching messaging-service, changing the message path, implementing MLS on a client]
tokens: 0
supersedes: []
---

# ADR-0010 · The server is a pure relay; MLS and the ratchet run on the clients

## Status

`accepted`

## Context

`messaging-service` held the key material for every conversation. Three separate mechanisms,
all reachable, all removed in Phase 3:

| Mechanism | Where | What the server held |
|---|---|---|
| Double Ratchet session store | `models.rs` `RatchetSession.ratchet_state` | "DH keys, root key, chain keys, message counters, skipped keys" — its own words |
| Server-side E2EE handlers | `send_message_e2ee.rs`, `receive_messages_e2ee.rs` | encrypted on send, decrypted on receive, held the ratchet |
| MLS group state | `mls_manager.rs`, `crypto/src/mls.rs` `serialize_state` | a 32-byte secret exported from the epoch secret |

Each was presented as progress toward E2EE. Each was the opposite: a design in which the
server is a party to the encryption rather than blind to it. Invariant I-1 says the server
must never be able to read plaintext, and a server holding the ratchet state can read all of
it.

The plan of record made this worse rather than better. `AGENTS.md` §1 and
`implementation_plan.md` §6.3 both directed PR-32 to collapse the duplicated handler pairs
**onto the `_e2ee` variants**, on the reasonable-looking assumption that a file named
`_e2ee` is the encrypted one. It is not. Two comments in that code settle it:

```rust
// send_message_e2ee.rs:129
&request.encrypted_content, // Client should send plaintext, we encrypt server-side

// receive_messages_e2ee.rs:177
encrypted_content: decrypted_content, // Now contains plaintext
```

The unsuffixed handler passes `request.encrypted_content` through untouched. **It was already
the zero-knowledge relay.** Following the plan would have deleted it and kept the path where
the server holds the keys — trading an I-2 violation for an I-1 one.

A second false premise sat under PR-31. In-code comments claimed OpenMLS 0.6 cannot
deserialize a group, and the "workaround" was to rebuild the group from scratch on every
membership change. `MlsGroup::load<Storage: StorageProvider>` exists, at
`openmls-0.6.0/src/group/mls_group/mod.rs:417`. But making the round-trip work would have been
the breach, not the fix: `load` restores `group_epoch_secrets`, so a server able to reload a
group is a server able to decrypt it.

## Decision

**The server relays opaque bytes and holds no key material.**

It keeps:

- ciphertext, stored and returned byte-for-byte
- opaque `KeyPackage`, `Welcome` and `Commit` blobs, routed to their recipients
- a membership index — who is in which group
- a monotonic epoch counter the clients advance

It holds **none** of: group state, epoch secrets, MLS credentials, identity keys, ratchet
state, or any derived secret.

All group operations — create, add, remove, commit, encrypt, decrypt — run on the clients.
The server cannot perform them, and after Phase 3 it has no code that tries.

## Consequences

**A message is only as encrypted as the client makes it.** With the server out of the
encryption path there is no longer anything to compensate for a client that does not encrypt.
`client-desktop` is exactly that case — it puts plaintext in `encrypted_content`
(`commands/messaging.rs:86`), which the server used to encrypt on its behalf. That must be
fixed before the flag removal lands; see the sequencing note below.

**Group state persistence becomes a client concern**, and the right mechanism is the OpenMLS
`StorageProvider` paired with `MlsGroup::load` — not the 32-byte export that
`serialize_state` returns today.

**The epoch counter is advisory.** The server increments it on relayed commits but cannot
verify one. A client must treat MLS state as authoritative and the counter as a hint for
ordering.

**Deployment loses its encryption switches.** `GUARDYN_E2EE_ENABLED` and `GUARDYN_MLS_ENABLED`
are gone from every surface, and `rules-verify` fails the build if either name returns. This
is what I-2 means in practice: not a default, an absence.

## Sequencing

Phase 3 implements this across seven steps:

| Step | Issue | What |
|---|---|---|
| PR-31a | #42 | delete the dead `*_mls.rs` handlers |
| PR-31b | #151 | delete server-held MLS secrets and `create_test_credential` |
| PR-31c | #152 | remove the crate-wide `dead_code` allow that hid it |
| PR-31d | #153 | this ADR |
| PR-32a | #43 | delete the server-side E2EE handlers |
| PR-32b | #154 | delete the E2EE and MLS configuration flags |
| PR-32c | #155 | delete the deployment variables — **blocked on client-desktop encrypting (#163)** |
| PR-30′ | #41 | delete the server-side Double Ratchet key storage |

Follow-ups outside Phase 3: #158 (real group-state persistence, both sides), #163
(`client-desktop` encryption).

## Alternatives rejected

**Collapse onto the `_e2ee` handlers, as originally planned.** Rejected on the evidence above:
it keeps the server in the encryption path and breaches I-1.

**Keep server-side encryption as "encryption at rest".** It is genuinely better than storing
plaintext, and it is what production ran. But it is not what this product claims, and a server
that can decrypt is a server that can be compelled to. The claim is zero-knowledge; the
architecture has to match it.

**Repair the MLS round-trip with `MlsGroup::load`.** Technically available, and it would have
made the existing code work. Rejected because working code is the wrong goal here — a server
that can reload a group can decrypt every message in it.
