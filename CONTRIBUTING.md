# Contributing to Guardyn

Guardyn is developed **agent-first**: most changes are made by AI coding agents working
under a written constitution, reviewed by humans. Whether you are an agent or a person,
the same rules apply.

**Read [`AGENTS.md`](AGENTS.md) before you write anything.** It is the authoritative
contract — invariants, git workflow, language policy, logging law, code standards. This
file only tells you how to get set up and what a good pull request looks like; it does
not restate the rules, because a second copy of a rule is a rule that will drift.

---

## Set up

```sh
git clone https://github.com/guardyn/guardyn.git
cd guardyn
just install-hooks          # protected-branch guard; run once per clone
just dc-up                  # full stack via Docker Compose
just dc-status              # confirm the containers are healthy
```

`just --list` shows every recipe. `nix develop` gives a reproducible shell with the whole
toolchain (Rust, kubectl, helm, just, sops, k3d) if you would rather not install it
piecemeal.

Prerequisites without Nix: Rust stable, Docker with Compose, `just`, and — only for the
clients — Node 20 and the Flutter SDK.

---

## The micro-step contract

This is the part that most often surprises new contributors, so it is worth stating
plainly:

**One micro-step = one branch = one pull request = one issue.**

- Branch: `<type>/<issue>-<slug>`, where `<type>` is one of
  `feat fix docs refactor chore security`. For example `security/43-enforce-always-on-e2ee`.
- **Never commit to `main`.** It is protected by a ruleset, and `just install-hooks`
  makes your machine say so before you get that far.
- **Budget: ≤400 hand-written changed lines, or ≤8 files.** A step that would exceed it
  is split *before* the branch is opened. This is not a style preference — it keeps a
  whole step inside one agent context window, so no step needs its context reconstructed.
- Each pull request is independently revertable and leaves `main` green.

Work in progress on the current 44-step refactor is tracked in
[`implementation_plan.md`](implementation_plan.md).

---

## Before you open a pull request

1. `git branch --show-current` is not `main`.
2. The change weakens no invariant in [`AGENTS.md`](AGENTS.md) §1. If it appears to
   require that, **stop and ask** — do not proceed on an assumption.
3. `cargo fmt --check` and `cargo clippy -- -D warnings` pass for Rust changes.
4. Tests pass, and a bug fix ships with a regression test that fails before the fix.
   Never weaken or delete a test to make CI green; if a test is wrong, say so and
   explain why.
5. The pull request body says what you deliberately left **out** of scope.

Commit messages follow Conventional Commits, in English, imperative mood, referencing
the issue with `Refs #N`. Explain *why*, not just what.

---

## What gets a change rejected

- Anything that lets encryption be turned off, or that puts a payload, a key, or PII
  into a log, a metric, a span, or `stdout`.
- A new datastore, message bus, or major dependency without an accepted ADR.
- A hardcoded domain. Everything derives from `${DOMAIN}`.
- Non-English content outside the marked localization paths.
- Hand-edited generated protobuf. Change the `.proto` and regenerate.

Each of these has a testable predicate in [`.claude/rules/`](.claude/rules/); you can
check yourself before a reviewer does.

---

## Reporting a vulnerability

**Do not open a public issue.** See [`SECURITY.md`](SECURITY.md) — report privately to
security@guardyn.app.

---

## Everything else

Bug reports and feature requests go to
[GitHub Issues](https://github.com/guardyn/guardyn/issues). Be specific about what you
expected and what happened; for anything reproducible, include the steps.

By contributing you agree your work is licensed under Apache-2.0, and that you will
follow the [Code of Conduct](CODE_OF_CONDUCT.md).
