# keebs

Personal split-keyboard firmware on [ZMK](https://zmk.dev/) and QMK.

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
- QMK build paths for YetiS, Wysteria, and KLOR, generated from the same ZMK layer/combo files

## Boards

| Board | Repo config | Make target |
| ----- | ----------- | ----------- |
| [Ferris Sweep](https://github.com/davidphilipbarr/Sweep) | `cradio.*` | `cradio` |
| [Aurora Sweep](https://splitkb.com/products/aurora-sweep) | `splitkb_aurora_sweep.*` | `aurora` |
| [Piantor Pro](https://github.com/beekeeb/piantor) | `piantor_pro.*` | `piantor` |
| [Glove80](https://www.moergo.com/collections/glove80-keyboards) | `glove80.*` | `glove80` |
| [YetiS](https://github.com/jogme/yetis-keyboard) | generated from `config/includes/layers/*.dtsi` + `config/includes/combos.dtsi` | `yetis` |
| [ANSIC](https://github.com/yuburoll/ANSIC) | `ansic.*` wireless shield | `ansic` |
| [KLOTZ](https://github.com/GEIGEIGEIST/KLOTZ) | `klotz.*` wireless shield | `klotz` |
| [LambBT](https://github.com/johnlamb/LambBT) | `lambbt.*` wireless shield | `lambbt` |
| [Lintilla](https://github.com/ctranstrum/lintilla/tree/zmk) | `lintilla.*` Xiao BLE shield | `lintilla` |
| [Wysteria](https://github.com/j-w-e/wysteria) | ZMK wireless config + generated QMK wired keymap | `wysteria` |
| [KLOR](https://github.com/GEIGEIGEIST/KLOR) | ZMK wireless config + generated QMK wired keymap | `klor` |

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
tools/layout-lab/          layout-analysis sandbox for magic/adaptive experiments
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
make yetis                 # build QMK firmware for YetiS
make wysteria              # build Wysteria wired QMK + wireless ZMK
make wysteria-wired        # build only Wysteria QMK firmware
make wysteria-bodged-wired # build Wysteria QMK firmware using the bodged keymap target
make wysteria-wireless     # build only Wysteria ZMK firmware
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
- `config/includes/adaptive_swaps.dtsi` for adaptive swap tables
- `config/includes/features.dtsi` for shared feature flags and opt-outs
- `config/includes/behaviors.dtsi` and `config/includes/thumbs.dtsi` for reusable behavior definitions

Normal builds run generation/checks automatically. Use `./scripts/generate check` only when you want a quick validation without building firmware.

Graphite adaptive bigram swaps live in `config/includes/adaptive_swaps.dtsi`. Each `ADAPTIVE_SWAP(Graphite, S, C, D)` entry makes `C` and `D` interchangeable after `S`. To disable them everywhere, set this in `config/includes/features.dtsi`:

```c
#define GRAPHITE_BIGRAM_SWAPS 0
```

To change the window:

```c
#define GRAPHITE_BIGRAM_TIMEOUT_MS 750
```

QMK generation supports the shared layer/combo behavior that is mapped in `qmk/scripts/generate_keymap.py`. It is intentionally strict: if a layer or combo starts using an unmapped ZMK behavior, generation fails instead of producing stale QMK firmware.

## Layout Lab

`tools/layout-lab/` is a separate sandbox for alpha-layout experiments. It does
not generate firmware. Use it to compare Whirl/Graphite/Magic Sturdy, encode
personal colstag position costs, and search around uncomfortable keys before
turning a candidate into a real `config/includes/layers/alpha_*.dtsi` file.

Useful commands:

```bash
python3 tools/layout-lab/lab.py compare --layouts whirl graphite magic_sturdy
python3 tools/layout-lab/lab.py neighborhood --layout whirl --focus-positions 21,24,25
python3 tools/layout-lab/lab.py optimize --layout whirl --iterations 12000
```

The first recorded run is in `tools/layout-lab/reports/first-run.md`.

## nRF52 BLE stability

nRF52 wireless builds automatically append `config/nrf52_ble_stability.conf`.
That profile uses the calibrated internal LFRC clock instead of trusting the
controller board's external 32 kHz crystal, and raises BLE TX power to +8 dBm.
This is intentional for nRF52840 controllers that otherwise reconnect poorly or
drop under normal use.

After changing BLE clock or bond settings, flash `settings_reset.uf2` to both
halves, then flash the normal left/right UF2s and pair from a freshly removed
host bond.

## Wysteria

Wysteria has two firmware paths:

```bash
make wysteria-wireless     # ZMK nice_nano left/right UF2s
make wysteria-wired        # QMK RP2040 UF2
make wysteria-bodged-wired # QMK RP2040 UF2 for the bodged Wysteria build
make wysteria              # both of the above
make wysteria-flash        # QMK flash target for the wired build
```

Wireless artifacts are copied to `build/wysteria/`. Wired QMK artifacts are copied to `build/qmk/wysteria/`.

## KLOR

KLOR follows the same split as Wysteria. The wired build uses QMK's `klor` target with the repo's generated `razen` keymap and defaults to `CONVERT_TO=rp2040_ce` for RP2040 ProMicro SuperMini controllers:

```bash
make klor-wireless         # ZMK nice_nano left/right UF2s
make klor-wired            # QMK RP2040 UF2
make klor                  # both of the above
make klor-flash            # QMK flash target for the wired build
```

Wireless artifacts are copied to `build/klor/`. Wired QMK artifacts are copied to `build/qmk/klor/`.

## QMK / Generated Keymaps

The generated QMK path stays inside this repo. `make yetis`, `make wysteria-wired`, and `make klor-wired` all reuse the same generated `razen` layer/combo tables, with per-board QMK glue around them.

The YetiS flow is:

```bash
make yetis-setup           # clone/pin QMK under .qmk/qmk_firmware and link this repo's keymap
make yetis                 # generate QMK tables from ZMK files, then build
make yetis-flash           # QMK flash target
make yetis-clean           # remove QMK build output
```

Artifacts are copied to `build/qmk/yetis/`. The default YetiS target is `rp2040_ce`, so `make yetis` emits `build/qmk/yetis/yetis_razen_rp2040_ce.uf2` for RP2040 Pro Micro-style controllers. The QMK checkout is cached in `.qmk/qmk_firmware` and pinned by `qmk-build.sh` to the upstream commit that added `keyboards/yetis`; `qmk-build.sh` applies the YetiS RP2040 metadata from `jogme/qmk_firmware` locally because that metadata is not in the pinned upstream commit.

To flash RP2040:

1. Hold `BOOTSEL`/`BOOT`, then plug in USB or tap/reset `RST`.
2. Wait for the `RPI-RP2` USB disk.
3. Copy `build/qmk/yetis/yetis_razen_rp2040_ce.uf2` onto it.
4. Repeat for the other half.

Double-tapping reset may also enter the bootloader after QMK has been flashed once. Shorting `RST` to `GND` only resets the controller; use `BOOTSEL` for the reliable first flash.

Edit the normal shared files for layout changes:

- `config/includes/layers/*.dtsi`
- `config/includes/combos.dtsi`
- `config/includes/features.dtsi`

`make yetis`, `make wysteria-wired`, and `make klor-wired` regenerate `.cache/qmk/.../generated_keymap.inc` from the preprocessed shared `.dtsi` files and copy it into the QMK checkout for compilation. The QMK files under `qmk/keyboards/*/keymaps/razen/` are compatibility glue for QMK-only behavior, thumb-wrapper differences, OLED/RGB feature flags, and board-specific tuning.

Do not edit `.cache/qmk/.../generated_keymap.inc` or the copied keymap inside `.qmk/qmk_firmware`; both are generated scratch output. If a normal layer/combo edit does not show up in QMK, run `./scripts/generate check` first. If you add a new custom ZMK behavior, add its QMK translation in the generator instead of hand-editing the generated QMK table.

Useful overrides:

```bash
QMK_REF=master make yetis
QMK_CONVERT_TO=none make yetis    # AVR Elite-C .hex build
OPERATING_SYSTEM=OS_MACOS make yetis
```
