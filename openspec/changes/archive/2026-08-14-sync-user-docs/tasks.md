## 1. Document right-widget ordering

- [x] 1.1 Add a `## Right widget ordering` section to `user_docs/widgets.md` covering `@tokyo-night-tmux_show_right_widgets`: recognized names (`battery`, `path`, `music`, `netspeed`, `git`, `wbg`, `datetime`, `hostname`), passthrough for `#(...)`, `#{...}`, `#[...]`, skip-unknown/skip-empty behavior, and the default order (`battery, path, music, netspeed, git, wbg, datetime`).
- [x] 1.2 Add a README Features row for right-widget ordering and an optional `@tokyo-night-tmux_show_right_widgets "path, git, datetime"` example under the "4. Enable widgets" block in `README.md`.
- [x] 1.3 Verify the documented names and default order match `lib/widget-reorder.sh` (`case` block) and `tokyo-night.tmux:95`.

## 2. Doc-coverage check

- [x] 2.1 Create `test/check-docs-coverage.sh`: enumerate `@tokyo-night-tmux_[a-z_]+` in `tokyo-night.tmux` + `src/` + `lib/` (deduped, excluding nothing), assert each appears in `user_docs/*.md`, print any missing names, exit non-zero on miss; runnable without tmux.
- [x] 2.2 Run `bash test/check-docs-coverage.sh` and confirm it passes; confirm it fails when a `user_docs` mention of `@tokyo-night-tmux_show_right_widgets` is temporarily removed (sanity).
- [x] 2.3 Add a `Doc coverage` step to the `bats-alpine` job in `.github/workflows/bats.yml` running `bash test/check-docs-coverage.sh` after checkout.

## 3. Agent & contributor guardrails

- [x] 3.1 Populate `openspec/config.yaml` `context:` with the project stack — Bash 4.2+ tmux theme, the `@tokyo-night-tmux_*` option surface, wiring (`tokyo-night.tmux` + `src/` + `lib/`), `user_docs/*.md` as the user-facing docs, `test/*.bats` for tests.
- [x] 3.2 Add `rules:` to `openspec/config.yaml`: proposal rule (name affected `user_docs/` files when an option changes), specs rule (name the `user_docs/` file that documents a new option), tasks rule (every task that adds/changes an option MUST include a `user_docs/` update step).
- [x] 3.3 Add a short paragraph to `CONTRIBUTING.md` stating that adding or changing an `@tokyo-night-tmux_*` option requires a matching `user_docs/` entry and that the CI doc-coverage check enforces it.
- [x] 3.4 Confirm `openspec status --change sync-user-docs --json` parses the updated `config.yaml` without error.

## 4. Remove dead scripts

- [x] 4.1 `git rm src/os-icons.sh src/cmus-tmux-statusbar.sh`.
- [x] 4.2 Grep the repo for `os-icons` and `cmus-tmux-statusbar`; confirm zero references in code, docs, and tests.
- [x] 4.3 Run the bats suite (`bats --verbose-run --report-formatter junit test/`) and the doc-coverage check; confirm green.
  - Note: `widget-reorder.bats` 10/10 green (relevant to this change). `netspeed.bats` is blocked locally by the missing `bats-mock/stub.bash` system library (no root on this host; CI provides `bats-mock` via `stealthii/bats-action`). It exercises only unchanged code (`lib/netspeed.sh`); the removed scripts are referenced by no test.

## 5. Verify change

- [x] 5.1 Run `openspec validate --changes sync-user-docs` (and `openspec status --change sync-user-docs`); resolve any reported issues.
- [x] 5.2 Final pass: `bash test/check-docs-coverage.sh` green and `bats test/` green.
  - Note: doc-coverage green (27/27 options). `bats test/widget-reorder.bats` green (10/10). Full `bats test/` green for widget-reorder; netspeed.bats blocked locally by missing `bats-mock` system lib (see 4.3 note) — not a change regression.