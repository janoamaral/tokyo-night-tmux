# Installation

[← Back to README](../README.md) · [Themes →](themes.md) · [Widgets →](widgets.md) · [Customization →](customization.md)

---

## Requirements

### Hard requirements

| Dependency | Purpose |
|---|---|
| [Nerd Fonts] v3+ | Icons and glyphs throughout the theme |
| Bash 4.2+ | Script execution |

> **macOS note:** macOS ships with Bash 3.2. You must install a newer version (see below).

### Optional dependencies

| Dependency | Purpose |
|---|---|
| [Noto Sans] Symbols 2 | Segmented digit number style |
| [bc] | Netspeed and git widgets |
| [jq] | Git widgets |
| [gh] | GitHub web-based git widget |
| [glab] | GitLab web-based git widget |
| [playerctl] *(Linux)* | Now Playing widget |
| [nowplaying-cli] *(macOS)* | Now Playing widget |

---

## Installing dependencies

### macOS

Install all dependencies at once via [Homebrew]:

```bash
brew install --cask font-monaspace-nerd-font font-noto-sans-symbols-2
brew install bash bc coreutils gawk gh glab gsed jq nowplaying-cli
```

### Linux

#### Alpine Linux

```bash
apk add bash bc coreutils gawk git jq playerctl sed
```

#### Arch Linux

```bash
pacman -Sy bash bc coreutils git jq playerctl
```

#### Ubuntu / Debian

```bash
apt-get install bash bc coreutils gawk git jq playerctl
```

---

## Installing the theme

### Via TPM (recommended)

[TPM](https://github.com/tmux-plugins/tpm) is the easiest way to install and keep the theme up to date.

1. Add the following line to your `~/.tmux.conf`:

```bash
set -g @plugin "janoamaral/tokyo-night-tmux"
```

2. Press `prefix` + <kbd>I</kbd> inside tmux to fetch and install the plugin.

### Manual installation

1. Clone the repository:

```bash
git clone https://github.com/janoamaral/tokyo-night-tmux ~/.config/tmux/plugins/tokyo-night-tmux
```

2. Add the following line to your `~/.tmux.conf`:

```bash
run ~/.config/tmux/plugins/tokyo-night-tmux/tokyo-night.tmux
```

3. Reload your tmux config:

```bash
tmux source ~/.tmux.conf
```

---

## Next steps

- [Configure a theme](themes.md)
- [Enable widgets](widgets.md)
- [Customize number and window styles](customization.md)

[Nerd Fonts]: https://www.nerdfonts.com/
[Noto Sans]: https://fonts.google.com/noto/specimen/Noto+Sans
[bc]: https://www.gnu.org/software/bc/
[jq]: https://jqlang.github.io/jq/
[gh]: https://cli.github.com/
[glab]: https://gitlab.com/gitlab-org/cli
[playerctl]: https://github.com/altdesktop/playerctl
[nowplaying-cli]: https://github.com/kirtan-shah/nowplaying-cli
[Homebrew]: https://brew.sh/
