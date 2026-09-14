---
id: adr-0008
type: adr
status: accepted
owns: [backend/proto/]
read_when: [changing a proto, touching generated code]
tokens: 454
supersedes: []
---

# ADR-0008 · Generated protobuf lives in OUT_DIR, not in the tree

## Status

`accepted`, and **fully implemented**. PR-23 moved all six backend services into `OUT_DIR`,
deleting `backend/crates/*/src/generated/` — 13 files, 12,114 lines. PR-56 did the same for
`client-desktop/src-tauri/src/proto/` — 8 files, 7,645 lines. No generated Rust is committed
anywhere in the repository.

**The delay had a measurable cost, and it is the argument for this ADR.** The desktop copy was
left out of PR-23 because it is a separate build with its own toolchain. By the time PR-56
picked it up the copy predated PR-36, so it lacked `KeyBundle.ml_kem_public`, while
`commands/auth.rs:96` had come to write that field: the tracked tree no longer compiled
against itself. `build.rs` wrote into the tree and declared `rerun-if-changed` on the proto
directory, so a **cold** checkout regenerated the copy, went green, and left two tracked files
dirty — whereas a **warm-cache** build skipped `build.rs` and failed on the stale copy with
E0560. CI has no cargo cache for this crate and was therefore structurally unable to see it.
Committed build output does not merely risk drift; it converts drift into a build break that
only some machines observe.

## Context

`backend/proto/*.proto` is the canonical wire contract. How the Rust for it is produced has
drifted into three answers at once:

- `messaging-service` uses `tonic::include_proto!`, compiling from `OUT_DIR` at build time.
- Five services `include!` committed output under `src/generated/` — 13 files, ~12,100 lines.
- `client-desktop/src-tauri/src/proto/` holds a **third** copy — 8 files, ~7,600 lines.

Committed output invites two failures: it drifts silently from the `.proto` when someone
forgets to regenerate, and it invites hand-editing, which the `.proto` then silently
overwrites.

The second failure was already live. Every one of those five `build.rs` files set
`.out_dir("src/generated")`, so **`cargo build` rewrote the committed files in place**. The
tree was not a stale snapshot that someone had forgotten to refresh — it was a build output
under version control, and any hand-edit to it survived exactly until the next build.

## Decision

Generated protobuf is produced at build time into `OUT_DIR` and included with
`include_proto!`. No generated Rust is committed.

## Consequences

The `.proto` becomes the only thing that can be edited, so drift is structurally impossible
and review diffs shrink by ~19,700 lines. `protoc` becomes a hard build dependency — it is
already pinned in `flake.nix`.

Deleting the committed copies is a large, single-purpose, trivially revertable change; CI
must prove regeneration before the deletion lands.

**The plan named only the backend copy.** The `client-desktop` copy was a third location;
PR-23 took the backend, PR-56 the desktop.

## Alternatives rejected

**Commit generated code everywhere** — consistent, but keeps drift and hand-edits possible.
**Leave it mixed** — three strategies means three ways to be wrong.
