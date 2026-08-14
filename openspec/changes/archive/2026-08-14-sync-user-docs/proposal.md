## Why

The theme ships a real, tested feature — right-side widget reordering via `@tokyo-night-tmux_show_right_widgets` — that is wired in `tokyo-night.tmux:91-96` and implemented/tested in `lib/widget-reorder.sh` + `test/widget-reorder.bats`, yet appears nowhere in `README.md` or `user_docs/*.md`. At the same time there is no mechanism forcing `user_docs/` to track `@tokyo-night-tmux_*` options as they are added, so future changes drift again. This change closes the existing gap and installs guardrails so it does not reopen.

## What Changes

- **Document widget ordering** — add a `user_docs/` section and a README Features row covering `@tokyo-night-tmux_show_right_widgets`: comma-separated widget list, recognized names (`battery`, `path`, `music`, `netspeed`, `git`, `wbg`, `datetime`, `hostname`), passthrough for `#(...)`, `#{...}`, and `#[...]` entries, and skip-unknown/skip-empty behavior. Document the default right-bar order used when the option is unset.
- **Add a doc-coverage guardrail (CI)** — a check that fails when an `@tokyo-night-tmux_*` option referenced in `tokyo-night.tmux`, `src/`, or `lib/` is absent from `user_docs/*.md`. Wired into CI so unreviewed gaps block a merge.
- **Populate `openspec/config.yaml`** — add project `context:` (tmux theme, Bash 4.2+, `@tokyo-night-tmux_*` option surface, `src/`+`lib/`+`tokyo-night.tmux` wiring, `user_docs/` as the user-facing doc) and per-artifact `rules:` requiring any feature/option change to update the relevant `user_docs/` file. This is the agent-facing guardrail.
- **Update `CONTRIBUTING.md`** — short note for human contributors that adding/changing an `@tokyo-night-tmux_*` option requires a matching `user_docs/` entry, and that the CI check enforces it.
- **Remove dead/legacy scripts** — delete `src/os-icons.sh` (never sourced by any file) and `src/cmus-tmux-statusbar.sh` (not wired; the music widget uses `src/music-tmux-statusbar.sh`). Neither is referenced by code or docs, so removal is non-breaking and removes a false "undocumented feature" trap for future readers.

## Capabilities

### New Capabilities
- `right-widget-ordering`: user control over the layout and order of the right-hand status bar via `@tokyo-night-tmux_show_right_widgets`.
- `doc-sync-guardrails`: guardrails enforcing that every `@tokyo-night-tmux_*` option surfaced in code is reflected in `user_docs/`, plus agent guidance for keeping docs in sync on future changes.

### Modified Capabilities
<!-- openspec/specs/ is empty — no existing capabilities to modify. -->

## Impact

- **Docs**: `user_docs/widgets.md` (new widget-ordering section), `README.md` (Features table row + optional config example), `CONTRIBUTING.md` (contributor note).
- **OpenSpec config**: `openspec/config.yaml` gains populated `context` and `rules` (currently the unedited template).
- **Tests/CI**: a new doc-coverage test plus a CI step in `.github/workflows/` to run it.
- **Code removal**: `src/os-icons.sh`, `src/cmus-tmux-statusbar.sh` deleted; no references to update.
- **No runtime behavior change** for theme users; existing options and widgets are unaffected.