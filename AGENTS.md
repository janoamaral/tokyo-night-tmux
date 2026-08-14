# AGENTS.md

Guidance for AI agents working in this repo. Verify locally with the **same** commands CI runs — do not declare a task done until they pass.

## Verification (mirror CI)

Run all of these from the repo root. They match `.github/workflows/pre-commit.yml` and `.github/workflows/bats.yml`.

### 1. Pre-commit (shfmt + codespell)
```bash
pre-commit run --show-diff-on-failure --color=always --all-files
```

If `pre-commit` is not installed in this environment, mirror the shell-format hook directly (it runs `shfmt -w -s -l -i 2` over shell files):
```bash
shfmt -d -s -i 2 $(git ls-files '*.sh' '*.bats' '*.tmux')
```
Expect zero diff. A non-zero exit here means shell files would be auto-rewritten in CI — fix them before committing.

### 2. bats + doc coverage
```bash
bash test/check-docs-coverage.sh          # doc-coverage gate (added by sync-user-docs)
bats --verbose-run --report-formatter junit test/
```
`test/widget-reorder.bats` is self-contained. `test/netspeed.bats` needs `bats-mock/stub.bash`; if missing locally and you did not touch `lib/netspeed.sh`, that suite's failure is environmental, not a regression — but say so explicitly.

### 3. OpenSpec
```bash
openspec validate --changes <change-name>
```

## Project context

- **tokyo-night-tmux** — a tmux theme (Bash 4.2+, tmux 3+). Config surface is `@tokyo-night-tmux_*` tmux user options.
- **Wiring**: `tokyo-night.tmux` (entrypoint) + `src/*.sh` (one widget each) + `lib/*.sh` (shared helpers).
- **Docs**: `user_docs/*.md` (installation, themes, widgets, customization), surfaced by `README.md`.
- **Hard rule** (enforced by CI via `test/check-docs-coverage.sh`): every `@tokyo-night-tmux_*` option read by `tokyo-night.tmux`/`src/`/`lib/` MUST appear in `user_docs/*.md`. Adding/changing an option requires a matching `user_docs/` entry in the same change.
- **OpenSpec** changes live under `openspec/changes/<name>/` (see `openspec/config.yaml` for project context + per-artifact rules).
- Do not commit unless explicitly asked. Do not push or open PRs unless explicitly asked.