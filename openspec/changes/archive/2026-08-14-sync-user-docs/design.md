## Context

`tokyo-night-tmux` exposes its configuration as tmux user options (`@tokyo-night-tmux_*`) read in `tokyo-night.tmux` (via `tmux show -g` grep) and in `src/*.sh` / `lib/*.sh` (via `tmux show-option -gv`). User-facing documentation lives in `user_docs/*.md`, surfaced by `README.md`. Two gaps exist today:

1. `@tokyo-night-tmux_show_right_widgets` (right-bar widget reordering) is implemented in `lib/widget-reorder.sh:12` (`build_widget_string`), wired at `tokyo-night.tmux:91-96`, tested in `test/widget-reorder.bats`, but absent from all docs.
2. `openspec/config.yaml` is still the unedited template (empty `context:` / `rules:`), so nothing reminds agents to update `user_docs/` when options change; and there is no CI check that catches drift.

Two unreferenced scripts (`src/os-icons.sh`, `src/cmus-tmux-statusbar.sh`) sit in `src/` unconnected to the theme, reads as "undocumented features" when auditing.

## Goals / Non-Goals

**Goals:**
- Document widget ordering so users can configure it from the docs alone.
- Enforce, in CI, that every `@tokyo-night-tmux_*` option read by code appears in `user_docs/`.
- Give agents (and contributors) a written rule, in `openspec/config.yaml` and `CONTRIBUTING.md`, to keep docs in sync.
- Remove the two dead scripts so the code surface matches the documented surface.

**Non-Goals:**
- Rewriting how options are read or reformatting existing `user_docs/` content.
- An allowlist mechanism for "internal" options (none exist today; YAGNI).
- A pre-commit hook for the doc check (CI is the guardrail; local pre-commit convenience is deferred).
- Enforcing that `README.md` Features table stays in sync (curated by hand).

## Decisions

**D1 — Document ordering inside `user_docs/widgets.md`, not a new file.**
Ordering is a widget-layout concern; `widgets.md` already lists every widget and its options, so a new `## Right widget ordering` section there is discoverable and adds no file. Alternative `ordering.md` rejected — fragments a small doc set.

**D2 — Document the real default order.**
When `@tokyo-night-tmux_show_right_widgets` is unset, `tokyo-night.tmux:95` renders `battery, path, music, netspeed, git, wbg, datetime` (hostname is left-bar only). The docs will state this exact default so users know what they are overriding. The eight recognized names — `battery`, `path`, `music`, `netspeed`, `git`, `wbg`, `datetime`, `hostname` — come from the `case` in `build_widget_string`.

**D3 — Doc-coverage check is a plain shell script in `test/`, run by CI.**
Doc coverage is a static grep assertion, not behavioral, so it does not belong in `test/*.bats`. A standalone `test/check-docs-coverage.sh` is runnable locally without tmux and is called from CI. Inline-in-workflow rejected (not locally runnable; duplicates logic). The check:
```
rg -o '@tokyo-night-tmux_[a-z_]+' tokyo-night.tmux src/ lib/ | dedupe
  → assert each name appears in user_docs/*.md
```
Scan surface is `tokyo-night.tmux` + `src/` + `lib/` only (not `test/`, which legitimately references options). The dynamic `@tokyo-night-tmux_$1` in `widget-reorder.sh:13` does not match the literal regex, so `show_right_widgets` is caught via its literal read at `tokyo-night.tmux:91`.

**D4 — `openspec/config.yaml` gets short `context` + `rules`, not a long playbook.**
`context`: one block naming the stack (Bash 4.2+ tmux theme), the option surface (`@tokyo-night-tmux_*`), the wiring (`tokyo-night.tmux` + `src/` + `lib/`), the docs (`user_docs/*.md`), and tests (`test/*.bats`). `rules` are advisory text nudging agents — proposal rule names affected `user_docs/` files; tasks rule makes each option change include a docs-update step; specs rule asks the spec to name the doc file. Advisory (not tool-enforced) on purpose — it nudges without blocking, while the CI check (D3) is the hard gate.

**D5 — Delete the two dead scripts, do not document them.**
`src/os-icons.sh` (never sourced) and `src/cmus-tmux-statusbar.sh` (not wired; music uses `src/music-tmux-statusbar.sh`, the `cmus_status` variable name is vestigial) are removed. Documenting dead code is worse than deleting it; a plugin run via `tokyo-night.tmux` does not expose internal `src/` scripts to users.

## Risks / Trade-offs

- **Check false positives** → mitigated by scanning only `tokyo-night.tmux`+`src/`+`lib/` and by the literal regex; `test/` usage excluded.
- **A future genuinely-internal option needs no docs** → none today; if one appears, prefer a one-line `user_docs/` mention over an allowlist (keeps the guardrail honest). Allowlist deferred (YAGNI).
- **Removing dead scripts breaks an undocumented external user** → they are unshipped-from-the-theme internal helpers, never wired or documented; risk is negligible.
- **Advisory `rules` could be ignored** → accepted; the CI check is the enforcing gate, the `rules` lower the chance an agent drifts in the first place.

## Migration Plan

Docs and `openspec/config.yaml` edits are additive. The dead scripts are `git rm`'d. No user migration; existing configs are unaffected. Rollback is a single revert.