# keebs

Personal Graphite and Vestnik keymap compiled from one semantic model to ZMK, QMK, and keymap-drawer.

## Authoring

Only four files define generated keymaps:

- `keymap/keymap.toml`: layer order and OS-specific actions
- `keymap/layers.toml`: complete 30-key, 34-key, and Glove80 layer matrices
- `keymap/behaviors.toml`: timings, morphs, tap-holds, adaptives, combos, leader sequences, and platform actions
- `keymap/profiles.json`: physical slot order, firmware targets, capabilities, defaults, and overlays

Change keys and layer contents in `layers.toml`. Change timing, triggers, emitted keys, combos, or leader sequences in `behaviors.toml`. Map physical slots and firmware capabilities in `profiles.json`. Renderer and runtime code hold stable behavior mechanics.

Generated compiler files live under `.cache/keymap/<os>/<backend>/<profile>/` and must not be edited. Drawings are written to `draw/generated/<profile>.svg` using the shared `draw/config.yaml`.

## Generation

```sh
just check
just generate
just render zmk cradio_34
just render qmk yetis_34
just draw luna
just draw
just profiles
```

`check` validates every source and profile, renders every backend twice in temporary directories, and rejects nondeterministic output. `render` accepts `linux`, `macos`, or `windows` as its final argument.

## Commands

```sh
just
just targets
just setup luna
just build luna
just build aurora wired
just build aurora wireless
just left cradio
just flash yetis
```

`just build <target> [default|all|zmk|qmk|wired|wireless]` selects firmware backends from `keymap/profiles.json`. `just zmk <target> [action]` and `just qmk <target> [action]` expose backend-specific actions. `build.sh` and `qmk-build.sh` remain internal firmware mechanics. ZMK dependencies remain branch-based in west manifests. QMK uses the commit pinned in `qmk-build.sh`.

Adept and Cantor diagnostic probe keymaps remain standalone because they are hardware diagnostics, not generated user layouts.
