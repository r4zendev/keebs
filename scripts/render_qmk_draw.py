#!/usr/bin/env python3
from __future__ import annotations

import argparse
import importlib.util
import json
import re
import subprocess
import tempfile
from pathlib import Path

import yaml


def load(path: Path) -> dict:
    return json.loads(path.read_text())


def load_generator(repo: Path):
    path = repo / "qmk" / "scripts" / "generate_keymap.py"
    spec = importlib.util.spec_from_file_location("generate_keymap", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def profile_slots(model: dict, profile: dict) -> list[str]:
    slots = profile.get("qmk_slots")
    if slots is not None:
        return slots
    position_set = profile.get("position_set")
    if position_set is None:
        raise ValueError("profile has no QMK logical-position map")
    return model["position_sets"][position_set]


LABELS = {
    "SQT DQT": {"t": "'", "s": '"'},
    "DOT Q": {"t": ".", "s": "?"},
    "MNS SLSH": {"t": "-", "s": "/"},
    "COM EX": {"t": ",", "s": "!"},
    "NAV BSPC DEL": {"t": "$$mdi:backspace$$", "h": "Nav", "s": "$$mdi:backspace-reverse$$"},
    "LT(L SYMBOL,SPC)": {"t": "$$mdi:keyboard-space$$", "h": "Symbol"},
    "NUM SHIFT": {"t": "$$mdi:arrow-up-bold$$", "h": "Num"},
    "STICKY SHIFT": {"t": "$$mdi:arrow-up-bold$$"},
    "NUM REPEAT": {"t": "$$mdi:repeat$$", "h": "Num"},
    "MAGIC": "$$mdi:star-four-points$$",
}


HOLDS = {
    "G": "❖",
    "A": "⌥",
    "C": "⌃",
    "S": "$$mdi:arrow-up-bold$$",
}


def clean_key(key):
    if isinstance(key, str):
        if key in LABELS:
            return LABELS[key]
        match = re.fullmatch(r"HM[LR]([GACS])\((.+)\)", key)
        if match:
            return {"t": match.group(2), "h": HOLDS[match.group(1)]}
    return key


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--profile", required=True)
    parser.add_argument("--config", type=Path, default=Path("draw/config.yaml"))
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    repo = args.repo.resolve()
    model = load(repo / "keymap" / "model.json")
    profiles = load(repo / "keymap" / "profiles.json")["profiles"]
    profile = profiles[args.profile]
    if "qmk" not in profile:
        raise ValueError(f"{args.profile} has no QMK layout source")

    slots = profile_slots(model, profile)
    core_roles = model["position_sets"]["core_34"]
    if len(slots) != profile["binding_positions"]:
        raise ValueError(f"{args.profile} QMK slots do not match binding positions")
    if not set(core_roles).issubset(slots):
        raise ValueError(f"{args.profile} QMK slots do not cover the 34-key core")

    board_only = set(profile.get("board_only_positions", []))
    draw_slots = profile.get("qmk_draw_order") or [slot for slot in slots if slot not in board_only]
    if len(draw_slots) != profile["physical_keys"]:
        raise ValueError(f"{args.profile} draw slots has {len(draw_slots)}, expected {profile['physical_keys']} physical keys")

    generator = load_generator(repo)
    layers = generator.parse_layers(repo)
    mapped_layers = []
    for _name, cells in layers:
        if len(cells) != len(core_roles):
            raise ValueError("generated QMK layer does not match the 34-key core")
        values = dict(zip(core_roles, cells))
        mapped_layers.append([values.get(slot, "KC_NO") for slot in draw_slots])

    keymap = {
        "keyboard": profile["qmk"]["keyboard"],
        "keymap": "razen",
        "layout": profile.get("qmk_draw_layout", profile["qmk"]["layout"]),
        "layers": mapped_layers,
    }
    args.out.parent.mkdir(parents=True, exist_ok=True)
    config = args.config if args.config.is_absolute() else repo / args.config
    with tempfile.TemporaryDirectory() as directory:
        source = Path(directory) / "keymap.json"
        source.write_text(json.dumps(keymap, indent=2) + "\n")
        subprocess.run(
            [
                "keymap",
                "-c",
                str(config),
                "parse",
                "-q",
                str(source),
                "-l",
                *[name for name, _cells in layers],
                "-o",
                str(args.out),
            ],
            check=True,
        )

    data = yaml.safe_load(args.out.read_text())
    if "qmk_draw_order" in profile:
        data.pop("layout", None)
    for name, layer in data["layers"].items():
        data["layers"][name] = [clean_key(key) for key in layer]
    args.out.write_text(yaml.dump(data, default_flow_style=None, allow_unicode=True, sort_keys=False))


if __name__ == "__main__":
    main()
