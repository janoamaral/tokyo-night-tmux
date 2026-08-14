## ADDED Requirements

### Requirement: Right status bar follows user widget order
The theme SHALL build the right status bar from the comma-separated list in `@tokyo-night-tmux_show_right_widgets` when that option is set. When the option is unset, the theme SHALL fall back to the default order: `battery`, `path`, `music`, `netspeed`, `git`, `wbg`, `datetime`.

#### Scenario: Option is set to a reordered subset
- **WHEN** `@tokyo-night-tmux_show_right_widgets` is set to `path, git, datetime`
- **THEN** the right status bar renders only the path, git, and datetime widgets, in that order

#### Scenario: Option is unset
- **WHEN** `@tokyo-night-tmux_show_right_widgets` is not set
- **THEN** the right status bar renders the default order `battery`, `path`, `music`, `netspeed`, `git`, `wbg`, `datetime`

### Requirement: Recognized widget names map to status-bar widgets
The theme SHALL recognize the names `battery`, `path`, `music`, `netspeed`, `git`, `wbg`, `datetime`, and `hostname`, mapping each to its corresponding status-bar widget.

#### Scenario: Every recognized name renders
- **WHEN** the list contains each of the eight recognized names
- **THEN** each name renders its corresponding widget in the bar

### Requirement: Unknown and empty list entries are skipped
The theme SHALL silently skip list entries that are not recognized names and SHALL silently skip empty entries (including entries produced by leading, trailing, or doubled commas) without emitting errors.

#### Scenario: Unknown name in the list
- **WHEN** the list is `git, nonexistent, datetime`
- **THEN** only the git and datetime widgets render and no error is emitted

#### Scenario: Empty entries in the list
- **WHEN** the list is `git, , datetime` or contains whitespace-only items
- **THEN** only the git and datetime widgets render and no error is emitted

### Requirement: Passthrough entries render verbatim
The theme SHALL pass through, verbatim, list entries beginning with `#(`, `#{`, or `#[`, allowing arbitrary shell commands, tmux format variables, and style attributes.

#### Scenario: Mix of passthrough and named widgets
- **WHEN** the list is `#[fg=red]●, git, #(curl -s http://example.com)`
- **THEN** the styled dot, the git widget, and the literal `#(curl ...)` substitution appear in the bar in that order

### Requirement: Widget ordering is documented
The `user_docs/` SHALL include a section documenting `@tokyo-night-tmux_show_right_widgets` — recognized names, passthrough behavior, skip behavior, and the default order — and the `README.md` Features table SHALL list the capability.

#### Scenario: User configures ordering from the docs alone
- **WHEN** a user reads `user_docs/widgets.md` and the README Features table
- **THEN** they can configure `@tokyo-night-tmux_show_right_widgets` without reading the theme source