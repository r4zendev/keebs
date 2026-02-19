# keebs

Split keyboard firmware based on [Graphite](https://github.com/rdavison/graphite-layout) with [Vestnik](https://github.com/nxtk/vestnik-layout) for Cyrillic.

<details>
<summary>Layout</summary>

<img src="draw/cradio.svg" alt="Sweep layout">

</details>

## Boards

| Board | Config |
| ----- | ------ |
| [MoErgo Glove80](https://www.moergo.com/collections/glove80-keyboards/products/glove80-split-ergonomic-keyboard-revision-2) | `glove80.*` |
| [Ferris Sweep](https://github.com/davidphilipbarr/Sweep) | `cradio.*` |
| [Aurora Sweep](https://splitkb.com/products/aurora-sweep) | `splitkb_aurora_sweep.*` |

## Architecture

All layers live in `base.keymap` using `ZMK_BASE_LAYER` from [urob/zmk-helpers](https://github.com/urob/zmk-helpers). Board files either use the default 34-key expansion or redefine the macro for larger matrices (see `glove80.keymap`).

### Thumb Cluster

```
LH2: tap=Esc→Tab   hold=Nav
LH1: tap=repeat       hold=Shift
RH1: tap=Space→Enter  hold=Num
RH2: tap=Bspc→Del  hold=Symbol
```

All thumbs are hold-taps with mod-morphs (shift changes the tap behavior). Shift+Esc=Tab, Shift+Space=Enter, Shift+Bspc=Del.

### Home Row Mods

[urob's "timeless" mods](https://github.com/urob/zmk-config#timeless-homerow-mods) — GACS: `pinky=GUI ring=ALT mid=CTL index=SFT`.

`hold-trigger-on-release` enables same-hand multi-mod chording (triple/quad mods). Optional `#define BILATERAL` adds positional filtering + HRM-combo hack.

### Symbol Layer

Placement follows key effort grades from the [T-34 layout](https://www.jonashietala.se/blog/2021/06/03/the-t-34-keyboard-layout):

![Effort grid](effort.png)

- **Home row (effort 0)**: highest-frequency symbols `= _ / !`
- **Strong fingers for double-tap**: `==` `//` `&&` `||` `**` — none on pinkies
- **Common bigrams as rolls**: `!=` inward, `+=` outward, `~=` inward
- **Cross-hand alternation**: `->` `=>` `<=` `>=`
- **Bracket pairs as outward rolls**: `() {} [] <>`
- **Vim pairs**: `_`/`$` on home, `#`/`*` top, `^`/`%` bottom

### Repeat / Magic Key (★)

Tap = key repeat (last key). Hold = Shift. With `MAGIC_SEQUENCES` enabled, uses [zmk-adaptive-key](https://github.com/urob/zmk-adaptive-key) for SFB fixes and suffix completions instead of plain repeat.

<details>
<summary>Magic Sequences</summary>

#### SFB fixes

| Trigger | Output | SFB avoided |
| ------- | ------ | ----------- |
| U★ | E | ue 0.418% |
| H★ | Y | hy 0.142% |
| W★ | S | ws 0.100% |

#### Suffix completions

| Trigger | Result | Example |
| ------- | ------ | ------- |
| A★ | ation | nation, education |
| J★ | just | adjust, just |
| Q★ | quen | frequency, sequence |
| Z★ | zation | organization |
| SPC★ | the | most common word |

</details>

## Configuration

| Define | Effect | Default |
| ------ | ------ | ------- |
| `BILATERAL` | Positional hold-tap filtering + HRM-combo hack | enabled |
| `OPERATING_SYSTEM` | OS-specific keys (1=Linux, 2=macOS, 3=Windows) | `1` |
| `MAGIC_SEQUENCES` | Adaptive key SFB fixes + suffix completions | disabled |

## ZMK Modules

[zmk-adaptive-key](https://github.com/urob/zmk-adaptive-key) ·
[zmk-helpers](https://github.com/urob/zmk-helpers) ·
[zmk-tri-state](https://github.com/urob/zmk-tri-state)

## Building

```bash
make setup                  # init west workspaces (one-time)
make                        # all boards: firmware + drawings
make glove80                # single board
make draw                   # drawings only
```
