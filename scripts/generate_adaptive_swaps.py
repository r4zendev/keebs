#!/usr/bin/env python3
from __future__ import annotations

import argparse
import re
import tomllib
from pathlib import Path


LAYERS_DIR = Path("config/includes/layers")
GENERATED_DIR = Path("config/includes/generated")
SOURCE = Path("keymap/adaptive_swaps.toml")

BEGIN = "/* >>> generated adaptive swaps (do not edit — run ./scripts/generate) >>> */"
END = "/* <<< end generated adaptive swaps <<< */"

TOKEN = re.compile(r"[A-Z][A-Z0-9_]*")


def load_swaps(path: Path) -> dict[str, tuple[int, list[tuple[str, str, str]], bool]]:
    data = tomllib.loads(path.read_text())
    layouts: dict[str, tuple[int, list[tuple[str, str, str]], bool]] = {}
    for layout, config in data.items():
        if not re.fullmatch(r"[a-z][a-z0-9_]*", layout):
            raise ValueError(f"Invalid adaptive swap layout name {layout!r}")
        if not isinstance(config, dict):
            raise ValueError(f"{layout} must be a table")
        timeout = config.get("timeout_ms")
        if not isinstance(timeout, int) or timeout <= 0:
            raise ValueError(f"{layout} timeout_ms must be a positive integer")
        raw_swaps = config.get("swaps")
        if not isinstance(raw_swaps, list) or not raw_swaps:
            raise ValueError(f"{layout} swaps must be a non-empty list")
        enabled = config.get("enabled", False)
        if not isinstance(enabled, bool):
            raise ValueError(f"{layout} enabled must be a boolean")
        layouts[layout] = (timeout, parse_swaps(layout, raw_swaps), enabled)
    return layouts


def parse_swaps(layout: str, raw_swaps: list[object]) -> list[tuple[str, str, str]]:
    swaps: list[tuple[str, str, str]] = []
    seen: set[tuple[str, str, str]] = set()
    for raw in raw_swaps:
        if not (
            isinstance(raw, list)
            and len(raw) == 3
            and all(isinstance(value, str) and TOKEN.fullmatch(value) for value in raw)
        ):
            raise ValueError(f"{layout} has invalid swap {raw!r}")
        prior, left, right = raw
        if left == right:
            raise ValueError(f"{layout} adaptive swap cannot map {left} to itself")
        item = (prior, left, right)
        if item in seen or (prior, right, left) in seen:
            raise ValueError(f"{layout} duplicate adaptive swap after {prior}: {left} <-> {right}")
        seen.add(item)
        swaps.append(item)
    return swaps


def binding_kind(text: str, name: str, key: str) -> tuple[str, str | None]:
    match = re.search(
        rf"#\s*define\s+{name}_{key}\s+&(kp|hml|hmr)\b\s*(\w+)?\s*{key}\b", text
    )
    if not match:
        return ("plain", None)
    flavor = match.group(1)
    if flavor == "kp":
        return ("plain", None)
    return (flavor, match.group(2))


def generate_body(name: str, timeout: int, swaps: list[tuple[str, str, str]], text: str) -> str:
    lower = name.lower()
    groups: dict[str, list[tuple[str, str]]] = {}
    for prior, left, right in swaps:
        groups.setdefault(right, []).append((prior, left))
        groups.setdefault(left, []).append((prior, right))

    out = []

    for key, triggers in groups.items():
        out.append(f"ZMK_ADAPTIVE_KEY({lower}_bigram_{key.lower()}, bindings = <&kp {key}>;")
        for prior, output in triggers:
            out.append(
                f"    {lower}_bigram_{prior.lower()}{output.lower()} "
                f"{{ trigger-keys = <{prior}>; max-prior-idle-ms = <{timeout}>; "
                f"bindings = <&kp {output}>; strict-modifiers; }};"
            )
        out.append(")")
        out.append("")

    kinds = {key: binding_kind(text, name, key) for key in groups}

    for key in groups:
        flavor, _mod = kinds[key]
        if flavor == "plain":
            continue
        positions = "KEYS_R" if flavor == "hml" else "KEYS_L"
        out.extend(
            [
                f"ZMK_HOLD_TAP({lower}_{flavor}_{key.lower()}, bindings = <&kp>, <&{lower}_bigram_{key.lower()}>;",
                '             flavor = "balanced"; tapping-term-ms = <180>;',
                "             quick-tap-ms = <QUICK_TAP_MS>; require-prior-idle-ms = <100>;",
                f"             hold-trigger-key-positions = <{positions} THUMBS>;",
                "             hold-trigger-on-release;)",
                "",
            ]
        )

    for key in groups:
        flavor, mod = kinds[key]
        if flavor == "plain":
            out.append(f"#define {name}_{key} &{lower}_bigram_{key.lower()}")
        else:
            out.append(f"#define {name}_{key} &{lower}_{flavor}_{key.lower()} {mod} 0")

    return "\n".join(out)


def process(
    path: Path, gen_dir: Path, timeout: int, swaps: list[tuple[str, str, str]], enabled: bool
) -> None:
    text = path.read_text()
    begin = text.find(BEGIN)
    end = text.find(END)
    if begin == -1 or end == -1:
        raise ValueError(f"{path.name} has no generated adaptive swaps markers")
    if end < begin:
        raise ValueError(f"Markers out of order in {path.name}")

    name = path.stem.removeprefix("alpha_").upper()

    gen_dir.mkdir(parents=True, exist_ok=True)
    if enabled:
        header = "/* Generated by scripts/generate — do not edit. Source: keymap/adaptive_swaps.toml */"
        body = generate_body(name, timeout, swaps, text)
        (gen_dir / path.name).write_text(header + "\n\n" + body + "\n")
    else:
        header = "/* Generated by scripts/generate — do not edit. Source: keymap/adaptive_swaps.toml (enabled = false, swaps skipped) */"
        (gen_dir / path.name).write_text(header + "\n")

    include_line = f'#include "../generated/{path.name}"'
    new = text[: begin + len(BEGIN)] + "\n" + include_line + "\n" + text[end:]
    if new != text:
        path.write_text(new)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    args = parser.parse_args()

    repo = args.repo.resolve()
    layouts = load_swaps(repo / SOURCE)
    gen_dir = repo / GENERATED_DIR
    for layout, (timeout, swaps, enabled) in sorted(layouts.items()):
        path = repo / LAYERS_DIR / f"alpha_{layout}.dtsi"
        if not path.exists():
            raise ValueError(f"Missing alpha layer for adaptive swaps: {path}")
        process(path, gen_dir, timeout, swaps, enabled)


if __name__ == "__main__":
    main()
