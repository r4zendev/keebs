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
LH2: tap=Esc/Tab   hold=Nav
LH1: tap=Bspc/Del  hold=Shift
RH1: tap=Space      hold=Symbol
RH2: tap=Enter      hold=Num
```

Mod-morphs on thumbs: Esc→Tab (shift), Bspc→Del (shift).

### Thumb Combos

| Combo | Action |
| ----- | ------ |
| LH1+LH2 | Mouse layer (toggle) |
| RH1+RH2 | Function layer (sticky) |
| LH2+RH2 | System layer (sticky) |

### Home Row Mods

[urob's "timeless" mods](https://github.com/urob/zmk-config#timeless-homerow-mods) — GACS: `pinky=GUI ring=ALT mid=CTL index=SFT`.

`hold-trigger-on-release` enables same-hand multi-mod chording (triple/quad mods).

### Symbol Layer

Placement follows key effort grades from the [T-34 layout](https://www.jonashietala.se/blog/2021/06/03/the-t-34-keyboard-layout):

![Effort grid](effort.png)

- **Home row (effort 0)**: highest-frequency symbols `= _ / !`
- **Strong fingers for double-tap**: `==` `//` `&&` `||` `**` — none on pinkies
- **Common bigrams as rolls**: `!=` inward, `+=` outward, `~=` inward
- **Cross-hand alternation**: `->` `=>` `<=` `>=`
- **Bracket pairs as outward rolls**: `() {} [] <>`
- **Vim pairs**: `_`/`$` on home, `#`/`*` top, `^`/`%` bottom

## Configuration

| Define | Effect | Default |
| ------ | ------ | ------- |
| `OPERATING_SYSTEM` | OS-specific keys (1=Linux, 2=macOS, 3=Windows) | `1` |

## ZMK Modules

[zmk-helpers](https://github.com/urob/zmk-helpers) ·
[zmk-tri-state](https://github.com/urob/zmk-tri-state)

## Building

```bash
make setup                  # init west workspaces (one-time)
make                        # all boards: firmware + drawings
make glove80                # single board
make draw                   # drawings only
```
