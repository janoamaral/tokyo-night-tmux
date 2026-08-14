# Doc Sync Guardrails

## Purpose

Keep `user_docs/` in sync with the `@tokyo-night-tmux_*` option surface, so every option surfaced in code is documented, and give agents and contributors the guardrails to prevent drift on future changes.

## Requirements

### Requirement: Every surfaced option is documented
Every `@tokyo-night-tmux_*` option referenced by `tokyo-night.tmux`, `src/`, or `lib/` SHALL appear in at least one file under `user_docs/`.

#### Scenario: New option added without a docs entry
- **WHEN** a contributor adds a new `@tokyo-night-tmux_*` option to `src/` without any matching `user_docs/` entry
- **THEN** the doc-coverage check fails

#### Scenario: New option added with a docs entry
- **WHEN** a contributor adds the option and a matching `user_docs/` entry
- **THEN** the doc-coverage check passes

### Requirement: Doc-coverage check runs in CI and locally
The repository SHALL run the doc-coverage check on CI for every pull request and SHALL fail the build when any `@tokyo-night-tmux_*` option read by code lacks a `user_docs/` entry. The check SHALL be runnable locally without tmux.

#### Scenario: CI blocks an undocumented option
- **WHEN** a pull request introduces an `@tokyo-night-tmux_*` option that is absent from `user_docs/`
- **THEN** the CI build fails and the pull request cannot merge

#### Scenario: Local run mirrors CI
- **WHEN** a contributor runs the doc-coverage check command locally
- **THEN** it reports the same pass/fail result as CI without requiring a tmux session

### Requirement: Agent guidance keeps docs in sync
`openspec/config.yaml` SHALL carry project `context` and per-artifact `rules` that direct any agent to update the relevant `user_docs/` file when adding or changing an `@tokyo-night-tmux_*` option or feature.

#### Scenario: Agent proposes a change that adds an option
- **WHEN** an agent creates a change proposal introducing a new `@tokyo-night-tmux_*` option
- **THEN** the config rules direct it to name the affected `user_docs/` file in the proposal and to include a docs-update task

### Requirement: Contributor guidance documents the rule
`CONTRIBUTING.md` SHALL state that adding or changing an `@tokyo-night-tmux_*` option requires a matching `user_docs/` entry, and that CI enforces it.

#### Scenario: Contributor reads the contributing guide
- **WHEN** a contributor opens `CONTRIBUTING.md` before adding an option
- **THEN** they learn the docs-sync requirement and that CI enforces it

### Requirement: No shipping of unreferenced status-bar scripts
The repository SHALL NOT carry scripts under `src/` or `lib/` that are neither sourced by `tokyo-night.tmux` (directly or transitively) nor invoked as status-bar widgets. The legacy `src/os-icons.sh` and `src/cmus-tmux-statusbar.sh` SHALL be removed.

#### Scenario: Legacy dead scripts removed
- **WHEN** the change is applied
- **THEN** `src/os-icons.sh` and `src/cmus-tmux-statusbar.sh` no longer exist and nothing sources or invokes them

#### Scenario: Future unreferenced script rejected
- **WHEN** a contributor adds a script under `src/` that nothing sources or invokes
- **THEN** it is rejected in review with direction to wire it in or remove it