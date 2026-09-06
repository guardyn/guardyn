---
id: adr-0008
type: adr
status: accepted
owns: [backend/proto/, backend/crates/*/src/generated/, client-desktop/src-tauri/src/proto/]
read_when: [changing a proto, touching generated code]
tokens: 454
supersedes: []
---

# ADR-0008 · Generated protobuf lives in OUT_DIR, not in the tree

## Status

`accepted` as the target. **Three strategies coexist today**; PR-23 unifies them.

## Context

`backend/proto/*.proto` is the canonical wire contract. How the Rust for it is produced has
drifted into three answers at once:

- `messaging-service` uses `tonic::include_proto!`, compiling from `OUT_DIR` at build time.
- Five services `include!` committed output under `src/generated/` — 13 files, ~12,100 lines.
- `client-desktop/src-tauri/src/proto/` holds a **third** copy — 8 files, ~7,600 lines.

Committed output invites two failures: it drifts silently from the `.proto` when someone
forgets to regenerate, and it invites hand-editing, which the `.proto` then silently
overwrites.

## Decision

Generated protobuf is produced at build time into `OUT_DIR` and included with
`include_proto!`. No generated Rust is committed.

## Consequences

The `.proto` becomes the only thing that can be edited, so drift is structurally impossible
and review diffs shrink by ~19,700 lines. `protoc` becomes a hard build dependency — it is
already pinned in `flake.nix`.

Deleting the committed copies is a large, single-purpose, trivially revertable change; CI
must prove regeneration before the deletion lands.

**The plan names only the backend copy.** The `client-desktop` copy is a third location and
belongs in the same step.

## Alternatives rejected

**Commit generated code everywhere** — consistent, but keeps drift and hand-edits possible.
**Leave it mixed** — three strategies means three ways to be wrong.
