# keebs

Split keyboard firmware built on [ZMK](https://zmk.dev/) with [urob/zmk-helpers](https://github.com/urob/zmk-helpers).

<details>
<summary>Layout</summary>

<img src="draw/cradio.svg" alt="Sweep layout">

</details>

## Design

- **Alpha layers**: [Graphite](https://layouts.wiki/layouts/2023/graphite/) (EN), [Racket](https://layouts.wiki/layouts/2024/racket/) (EN, adaptive magic key), [Vestnik](https://github.com/nxtk/vestnik-layout) (RU)
- **[Timeless home row mods](https://github.com/urob/zmk-config#timeless-homerow-mods)** with `hold-trigger-on-release` for multi-mod chording
- **Symbol layer** placement follows [T-34 effort grades](https://www.jonashietala.se/blog/2021/06/03/the-t-34-keyboard-layout/)
- Mod-morphs and combos to maximize 34 keys

## Boards

| Board | Config |
| ----- | ------ |
| [Ferris Sweep](https://github.com/davidphilipbarr/Sweep) | `cradio.*` |
| [Aurora Sweep](https://splitkb.com/products/aurora-sweep) | `splitkb_aurora_sweep.*` |
| [Piantor Pro](https://github.com/beekeeb/piantor) | `piantor_pro.*` (wired split, RP2040) |
| [Glove80](https://www.moergo.com/collections/glove80-keyboards) | `glove80.*` |

## Building

```bash
make setup    # init west workspaces (one-time)
make          # all boards: firmware + drawings
make cradio   # single board
make draw     # drawings only
```
