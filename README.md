# keebs

<details>
<summary>Layout preview</summary>

<img src="draw/cradio.svg" alt="Sweep layout preview">

</details>

## What is in here

- Alternative keyboard layouts, namely [Gallium](https://layouts.wiki/layouts/2023/gallium/), my own mod of [Whirl](https://layouts.wiki/layouts/2024/whirl/) and [Vestnik](https://github.com/nxtk/vestnik-layout)
- Adaptive keys and magic
- [Timeless home row mods](https://github.com/urob/zmk-config#timeless-homerow-mods) with `hold-trigger-on-release`
- Symbol layer and combos
- QMK generation

## Layout

```
config/
  base.keymap              shared layers, behaviors, combos
  default.conf             default ZMK Kconfig
  default.west.yml         default west manifest
  includes/features.dtsi   shared feature flags and opt-outs
  includes/                shared layer/behavior/thumb/combo snippets
  keyboards/<board>/       board-specific conf/keymap/keyboard.yml/shields
draw/
  config.yaml              keymap-drawer config
  <board>.yaml             parsed keymap output
  <board>.svg              rendered layout preview
qmk/
  keyboards/               local QMK board and keymap overlays
  scripts/generate_keymap.py internal generator from preprocessed ZMK snippets to QMK tables
scripts/generate           shared generation/check entry point
build.sh                   ZMK workspace/build entry point
qmk-build.sh               QMK checkout/keymap/link/build entry point
Makefile                   common shortcuts
```

Dependencies come from each board's west manifest; there are no checked-in local ZMK modules in this repo.

## Build flow

Use `make` for day-to-day work:

```bash
make help
make setup                 # initialize all board workspaces
make cradio                # build firmware + drawing for one board
make klor                  # build KLOR wired QMK + wireless ZMK
make klor-wired            # build only KLOR QMK firmware
make klor-wireless         # build only KLOR ZMK firmware
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
./build.sh lintilla left-peripheral
./build.sh piantor_pro reset
```

If you change a board's `.west.yml`, rerun that board's `setup` command so `west update` picks up the new modules.

## Editing Layouts

The editable source of truth is intentionally small:

- `config/includes/layers/*.dtsi` for layer contents
- `config/includes/combos.dtsi` for combos
- `config/includes/features.dtsi` for shared feature flags and opt-ins
- `config/includes/behaviors.dtsi` and `config/includes/thumbs.dtsi` for reusable behavior definitions

Normal builds run generation/checks automatically. Use `./scripts/generate check` only when you want a quick validation without building firmware.

QMK generation supports the shared layer/combo behavior that is mapped in `qmk/scripts/generate_keymap.py`. It is intentionally strict: if a layer or combo starts using an unmapped ZMK behavior, generation fails instead of producing stale QMK firmware.

Do not edit `.cache/qmk/.../generated_keymap.inc` or the copied keymap inside `.qmk/qmk_firmware`; both are generated scratch output. If a normal layer/combo edit does not show up in QMK, run `./scripts/generate check` first. If you add a new custom ZMK behavior, add its QMK translation in the generator instead of hand-editing the generated QMK table.

Useful overrides:

```bash
QMK_REF=master make yetis
QMK_CONVERT_TO=none make yetis    # AVR Elite-C .hex build
OPERATING_SYSTEM=OS_MACOS make yetis
```

## Adaptive swaps

Adaptive swaps live in `keymap/adaptive_swaps.toml`. Each `[layout]` has `timeout_ms` and `swaps = [["prior", "a", "b"], ...]`; every swap makes `a` and `b` interchangeable after `prior`, and both directions are generated. `scripts/generate_adaptive_swaps.py` expands that data into `config/includes/generated/alpha_*.dtsi`, deriving plain key vs home-row mod from the layout's `#define <LAYOUT>_<KEY>` defaults. Builds run the generator automatically; edit the TOML, not generated files.

Genuinely special behaviors — magic repeat keys, and contextual or symbol/macro redirects (e.g. `night`'s `yq -> y'`, `dusk`'s `ntc -> nts`) — are not two-letter swaps and stay hand-written below the generated block.

The swaps are gated by a per-layout opt-in flag, off by default (`GRAPHITE_ADAPTIVE`, `TWIRL_ADAPTIVE`, …). Enable one in `config/includes/features.dtsi`:

```c
#define GRAPHITE_ADAPTIVE 1
```

Generic swaps use the per-layout `timeout_ms` from `keymap/adaptive_swaps.toml`. Hand-written adaptive behaviors still use `ADAPTIVE_TIMEOUT_MS`:

```c
#define ADAPTIVE_TIMEOUT_MS 750
```

Read more about adaptive swaps [here](https://dario.ca/posts/2026-05-18-keyboard-layout-adaptive-swaps/).
