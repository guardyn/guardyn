---
id: rules-doc-sync
type: rules
status: draft
owns: [docs/]
read_when: [changing any source file, adding a document, before opening a PR]
---

# 40 · Documentation sync

The algorithm that keeps documentation from drifting. It is a **mechanism, not a
convention**: once PR-15 and PR-16 land, drift is a build failure rather than a review nit.

`status: draft` until PR-15 ships `docs/.manifest.yaml` and `just docs-verify`. The
algorithm below is what an agent follows by hand in the meantime.

## The loop, per micro-step

1. List the source paths the step changes.
2. Look each up in `docs/.manifest.yaml`. Every match yields a set of documents that
   **own** that path.
3. Update those documents in the **same PR**. Not a follow-up — the same PR.
4. If a changed path genuinely has no documentation impact, label the PR
   `docs-impact:none` **and state the reason in the body**. The label without a reason is
   not acceptable.
5. Run `just docs-verify` before pushing.

## The five checks

| # | Check | Fails when |
|---|---|---|
| 1 | Frontmatter | a `docs/**/*.md` file has unparseable frontmatter, a duplicate `id`, or a `status` outside the enum |
| 2 | Impact | a changed source path's mapped documents are untouched and the PR carries no `docs-impact:none` |
| 3 | Glossary | a term defined in `GLOSSARY.md` appears under one of its `forbidden_aliases` |
| 4 | Links | a relative link does not resolve, **or** a tracked document links into `_local/` |
| 5 | Language | Cyrillic appears in `docs/**` outside the allowlisted policy file |

Check 2 is the one that matters. The rest catch mistakes; check 2 catches **neglect**.

## Frontmatter contract

Every file under `docs/` carries:

```yaml
---
id: adr-0005              # unique across docs/
type: adr                 # adr | spec | ops | roadmap | index | glossary | rules
status: accepted          # draft | accepted | superseded | deprecated
owns: [backend/crates/crypto/src/pqxdh.rs]
read_when: [touching crypto, changing key bundles]
tokens: 820               # measured, regenerated - never hand-edited
supersedes: []
---
```

## Regenerated, never hand-edited

`docs/INDEX.md`, `docs/roadmap/STATE.md` and every `tokens:` value are **generated**.
`docs-verify` fails if a generated file is stale. Editing one by hand will be reverted by
the next generation run — change the generator or the source, not the output.

## Why this exists

`docs/INDEX.md` is the only file an agent must read cold. It routes to everything else via
`read_when`, so a session loads two or three documents instead of the whole corpus. That
only works while the routing is true — which is what checks 1, 2 and 4 defend.

## Known defect this must catch

`CHANGELOG.md:55` links into `_local/`, which is gitignored and invisible to every cloner.
Check 4 exists so that class of defect cannot recur; the existing instance needs an issue.
