# Tokyo Night Tmux

A clean, dark Tmux theme that celebrates the lights of Downtown [Tokyo at night.](https://www.google.com/search?q=tokyo+night&newwindow=1&sxsrf=ACYBGNRiOGCstG_Xohb8CgG5UGwBRpMIQg:1571032079139&source=lnms&tbm=isch&sa=X&ved=0ahUKEwiayIfIhpvlAhUGmuAKHbfRDaIQ_AUIEigB&biw=1280&bih=666&dpr=2)
The perfect companion for [tokyonight-vim](https://github.com/ghifarit53/tokyonight-vim)
Adapted from the original, [Visual Studio Code theme](https://github.com/enkia/tokyo-night-vscode-theme).
The old version (deprecated) is still available in the `legacy` branch.

<a href="https://www.buymeacoffee.com/jano" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" style="height: 41px !important;width: 174px !important;box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;-webkit-box-shadow: 0px 3px 2px 0px rgba(190, 190, 190, 0.5) !important;" ></a>

## About this theme

This is a very opinionated project, as I am a Tech Lead, this theme is very developer-focused.

## Requirements

### Nerd Fonts

This theme requires the use of a patched font with Nerd Font. Ensure your terminal is set to use one before installing this theme. Any patched font will do. See
[`nerdfonts.com`](https://www.nerdfonts.com/) for more informations.

### Noto Fonts

This theme requires the Noto fonts to be installed on your operating system. Make sure your operating system has the needed font and is configured to use one.

### GNU bc
This theme requires the [`GNU bc`](https://www.gnu.org/software/bc/) for precise mathematical calculation of network speed, [Tokyo-night-tmux](https://janoamaral/tokyo-night-tmux) also shows the real time network speed in right side of status bar.

```bash
pacman -S bc
```
see documentation for installing [`GNU bc`](https://www.gnu.org/software/bc/) in other Operation system.

## Installation using TPM

In your `tmux.conf`:
```
set -g @plugin "janoamaral/tokyo-night-tmux"
```

### Configuration

#### Number styles

Run this

```
tmux set @tokyo-night-tmux_window_id_style digital
tmux set @tokyo-night-tmux_pane_id_style hsquare
tmux set @tokyo-night-tmux_zoom_id_style dsquare
```

or add this lines to your  `.tmux.conf`

```
set -g @tokyo-night-tmux_window_id_style digital
set -g @tokyo-night-tmux_pane_id_style hsquare
set -g @tokyo-night-tmux_zoom_id_style dsquare
```

The styles:
- `none`: no style, default font
- `digital`: 7 segment number (🯰...🯹) (needs [Unicode support](https://github.com/janoamaral/tokyo-night-tmux/issues/36#issuecomment-1907072080)) 
- `roman`: roman numbers (󱂈...󱂐) (needs nerdfont)
- `fsquare`: filled square (󰎡...󰎼) (needs nerdfont)
- `hsquare`: hollow square (󰎣...󰎾) (needs nerdfont)
- `dsquare`: hollow double square (󰎡...󰎼) (needs nerdfont)
- `super`: superscript symbol (⁰...⁹)
- `sub`: subscript symbols (₀...₉) 

### New tokyonight Highlights ⚡

Everything works out the box now. No need to modify anything and colors are hardcoded, 
so it's independent of terminal theme.

- Local git stats.
- Web based git server (GitHub/GitLab) stats.
    - Open PR count
    - Open PR reviews count 
    - Issue count
- Remote branch sync indicator (you will never forget to push or pull again 🤪).
- Great terminal icons.
- Prefix highlight incorporated.
- Now Playing status bar, supporting [cmus]/[nowplaying-cli]
- Windows has custom pane number indicator.
- Pane zoom mode indicator.
- Date and time.

#### TODO

- Add configurations
  - remote fetch time
  - ~number styles~
  - indicators order
  - disable indicators

### Demo

https://github.com/janoamaral/tokyo-night-tmux/assets/10008708/59ecd814-bc2b-47f2-82b1-ffdbfbc54fbf

### Snapshots

- Terminal: Kitty with [Tokyo Night Kitty Theme](https://github.com/davidmathers/tokyo-night-kitty-theme)
- Font: [SFMono Nerd Font Ligaturized](https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized)

![Snap 5](snaps/logico.png)

Legacy tokyonight

![Snap 4](snaps/l01.png)


[cmus]: https://cmus.github.io/
[nowplaying-cli]: https://github.com/kirtan-shah/nowplaying-cli
