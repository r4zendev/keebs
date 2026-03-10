# keebs

Personal split-keyboard firmware on [ZMK](https://zmk.dev/).

This repo keeps one shared layout stack across a few boards, with behavior built on top of [urob/zmk-helpers](https://github.com/urob/zmk-helpers) and [urob/zmk-adaptive-key](https://github.com/urob/zmk-adaptive-key).

<details>
<summary>Preview</summary>

<img src="draw/cradio.svg" alt="Sweep layout preview">

</details>

## What is in here

- Alpha layers: [Graphite](https://layouts.wiki/layouts/2023/graphite/), [Racket](https://layouts.wiki/layouts/2024/racket/), DuskWP, Bunya, [Vestnik](https://github.com/nxtk/vestnik-layout)
- Adaptive alpha magic plus thumb repeat/shift magic
- [Timeless home row mods](https://github.com/urob/zmk-config#timeless-homerow-mods) with `hold-trigger-on-release`
- Symbols arranged around [T-34 effort grades](https://www.jonashietala.se/blog/2021/06/03/the-t-34-keyboard-layout/)
- Shared base config with board-specific wrappers, manifests, and overrides

## Boards

| Board | Repo config | Make target |
| ----- | ----------- | ----------- |
| [Ferris Sweep](https://github.com/davidphilipbarr/Sweep) | `cradio.*` | `cradio` |
| [Aurora Sweep](https://splitkb.com/products/aurora-sweep) | `splitkb_aurora_sweep.*` | `aurora` |
| [Piantor Pro](https://github.com/beekeeb/piantor) | `piantor_pro.*` | `piantor` |
| [Glove80](https://www.moergo.com/collections/glove80-keyboards) | `glove80.*` | `glove80` |

## Layout

```
config/
  base.keymap              shared layers, behaviors, combos
  <board>.keymap           board wrapper
  <board>.west.yml         module manifest for that board
  <board>.build.yaml       board/shield build targets
  <board>.conf             board-specific Kconfig
draw/
  config.yaml              keymap-drawer config
  <board>.yaml             parsed keymap output
  <board>.svg              rendered layout preview
build.sh                   low-level build entry point
Makefile                   common shortcuts
```

Dependencies come from each board's west manifest; there are no checked-in local ZMK modules in this repo.

## Build flow

Use `make` for day-to-day work:

```bash
make help
make setup                 # initialize all board workspaces
make cradio                # build firmware + drawing for one board
make aurora-left           # build one half only
make cradio-reset          # build settings_reset firmware
make draw                  # redraw supported layout previews
make clean                 # remove build outputs and draw cache
```

`build.sh` is still available as the lower-level entry point when you want the raw board ids directly:

```bash
./build.sh splitkb_aurora_sweep setup
./build.sh cradio left
./build.sh glove80 right
./build.sh piantor_pro reset
```

If you change a board's `.west.yml`, rerun that board's `setup` command so `west update` picks up the new modules.
