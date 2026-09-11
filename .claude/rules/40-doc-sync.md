---
id: rules-doc-sync
type: rules
status: accepted
owns: [docs/]
read_when: [changing any source file, adding a document, before opening a PR]
---

# 40 · Documentation sync

The algorithm that keeps documentation from drifting. It is a **mechanism, not a
convention**: drift is a build failure, not a review nit.

This file was `status: draft` pending PR-15 and PR-16. Both landed —
[`docs/.manifest.yaml`](../../docs/.manifest.yaml), `just docs-verify` and
[`docs.yml`](../../.github/workflows/docs.yml) all exist and run on every pull request — so
the algorithm below is executed, not followed by hand.

## The loop, per micro-step

1. List the source paths the step changes.
2. Look each up in `docs/.manifest.yaml`. Every match yields a set of documents that
   **own** that path.
3. Update those documents in the **same PR**. Not a follow-up — the same PR.
4. If a changed path genuinely has no documentation impact, label the PR
   `docs-impact:none` **and state the reason in the body**. The label without a reason is
   not acceptable.
5. Run `just docs-verify` before pushing.

## The six checks

| # | Check | Fails when |
|---|---|---|
| 1 | Frontmatter | a `docs/**/*.md` file has unparseable frontmatter, a duplicate `id`, or a `status` outside the enum |
| 2 | Impact | a changed source path's mapped documents are untouched and the PR carries no `docs-impact:none` |
| 3 | Glossary | a term defined in `GLOSSARY.md` appears under one of its `forbidden_aliases` |
| 4 | Links | a relative link does not resolve, **or** a tracked document links into `_local/` |
| 5 | Language | Cyrillic appears in `docs/**` outside the allowlisted policy file |
| 6 | Staleness | `docs/roadmap/STATE.md` differs from what `just docs-state` renders today |

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
tokens: 820               # an estimate; only STATE.md's is generated and checked (#241)
supersedes: []
---
```

## Regenerated, never hand-edited

`docs/roadmap/STATE.md` is **generated** by `just docs-state` from `docs/roadmap/roadmap.yaml`,
and check 6 fails if the committed file differs. Editing it by hand will be reverted by the
next generation run — change `roadmap.yaml` or the generator, not the output.

Generation runs in one direction: `roadmap.yaml` → `STATE.md`. The generator never writes the
YAML and never reads GitHub. `roadmap.yaml` records the **desired** state, so refreshing it
from live issue state would invert the direction of truth — the mistake that reopened
twenty-one correctly-closed issues before #228.

### What this section used to claim, and why the correction matters

It read: *"`docs/INDEX.md`, `docs/roadmap/STATE.md` and every `tokens:` value are generated.
`docs-verify` fails if a generated file is stale."* **None of that was true.** PR-15 shipped
five checks and scoped the generator out, so three documents carried a header telling the
reader they were machine-derived while nothing derived them and nothing noticed them rotting.
`STATE.md` went stale inside the same phase that created it and ended up sixty steps behind
the YAML — worse than no such file, because the header made the wrong answer look
authoritative. That was [#101](https://github.com/guardyn/guardyn/issues/101).

`docs/INDEX.md` and the per-document `tokens:` values are **still hand-written** and are
still not checked. They are [#241](https://github.com/guardyn/guardyn/issues/241). Until that
lands, treat a `tokens:` value as an estimate somebody typed — several documents carry a
literal `tokens: 0`. The one exception is `STATE.md`'s own, which its generator computes as
characters ÷ 4 over the body, and which check 6 therefore holds to.

A rule that describes a mechanism nobody built trains readers to disbelieve the rules. State
what is enforced; name the rest as an open issue.

## Why this exists

`docs/INDEX.md` is the only file an agent must read cold. It routes to everything else via
`read_when`, so a session loads two or three documents instead of the whole corpus. That
only works while the routing is true — which is what checks 1, 2 and 4 defend.

## Known defect this must catch

`CHANGELOG.md:55` links into `_local/`, which is gitignored and invisible to every cloner.
Check 4 exists so that class of defect cannot recur; the existing instance needs an issue.
