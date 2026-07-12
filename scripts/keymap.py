#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


def load(path: Path) -> dict:
    return json.loads(path.read_text())


def fail(message: str) -> None:
    raise ValueError(message)


def cells(layout: dict) -> list[str]:
    return [cell for row in layout["rows"] for cell in row]


def validate_position_sets(model: dict) -> None:
    expected = {"core_30": 30, "core_34": 34, "standard_36": 36}
    position_sets = model["position_sets"]
    for name, count in expected.items():
        positions = position_sets.get(name)
        if not isinstance(positions, list) or len(positions) != count:
            fail(f"{name} must have {count} positions")
        if len(set(positions)) != len(positions):
            fail(f"{name} repeats logical positions")

    core_30 = set(position_sets["core_30"])
    core_34 = set(position_sets["core_34"])
    omitted = {"L_INNER_TOP", "R_INNER_TOP", "L_PINKY_BOTTOM", "R_PINKY_BOTTOM"}
    if core_34 - core_30 != omitted or core_30 - core_34:
        fail("core_30 must omit only the two inner tops and two pinky bottoms")

    standard_36 = set(position_sets["standard_36"])
    if standard_36 - core_34 != {"L_THUMB_OPTIONAL", "R_THUMB_OPTIONAL"} or core_34 - standard_36:
        fail("standard_36 must add only optional outer thumbs")

    totem_38 = set(position_sets.get("totem_38", []))
    if totem_38 - standard_36 != {"L_BOTTOM_EXTRA", "R_BOTTOM_EXTRA"} or standard_36 - totem_38:
        fail("totem_38 must be standard_36 plus only the two outer-pinky extras")

    klor_konrad_42 = set(position_sets.get("klor_konrad_42", []))
    klor_polydactyl_44 = set(position_sets.get("klor_polydactyl_44", []))
    if klor_polydactyl_44 - klor_konrad_42 != {"L_THUMB_OUTER", "R_THUMB_OUTER"} or klor_konrad_42 - klor_polydactyl_44:
        fail("klor_polydactyl_44 must be klor_konrad_42 plus only the two outer thumbs")


def validate_alphas(model: dict) -> None:
    if model["active_alphas"] != ["graphite", "vestnik_dm"]:
        fail("active alpha set must be graphite and vestnik_dm")

    graphite = model["alphas"]["graphite"]
    graphite_30 = cells(graphite["30"])
    graphite_34 = cells(graphite["34"])
    if len(graphite_30) != 26:
        fail("graphite 30 must have 26 non-thumb bindings")
    if len(graphite_34) != 30:
        fail("graphite 34 must have 30 non-thumb bindings")
    if len(set(graphite_30)) != len(graphite_30):
        fail("graphite 30 contains duplicate bindings")
    if len(set(graphite_34)) != len(graphite_34):
        fail("graphite 34 contains duplicate bindings")
    if graphite["30"]["deferred"] != ["Q", "Z", "SQT", "MINUS"]:
        fail("graphite 30 deferred roles changed")

    vestnik = model["alphas"]["vestnik_dm"]
    expected = {"30": 26, "34": 30, "38": 32, "extended": 36}
    for capacity, count in expected.items():
        values = cells(vestnik[capacity])
        if len(values) != count:
            fail(f"vestnik_dm {capacity} must have {count} non-thumb bindings")
        if len(set(values)) != len(values):
            fail(f"vestnik_dm {capacity} contains duplicate bindings")
    if vestnik["30"]["deferred"] != ["Ц", "Х", "Ф", "Э", "Щ", "Ъ", "Ё"]:
        fail("vestnik_dm 30 deferred letters changed")
    if vestnik["34"]["deferred"] != ["Щ", "Ъ", "Ё"]:
        fail("vestnik_dm 34 deferred letters changed")
    if vestnik["38"]["deferred"] != ["Щ", "Ъ", "Ё"]:
        fail("vestnik_dm 38 deferred letters changed")
    if vestnik["extended"]["deferred"]:
        fail("vestnik_dm extended must expose all deferred letters")

    for name in model["active_alphas"]:
        alpha = model["alphas"][name]
        core_30 = model["position_sets"]["core_30"][:-4]
        core_34 = model["position_sets"]["core_34"][:-4]
        values_30 = dict(zip(core_30, cells(alpha["30"])))
        values_34 = dict(zip(core_34, cells(alpha["34"])))
        changed = [position for position in core_30 if values_30[position] != values_34[position]]
        allowed = model["capacity_overrides"].get(name, {}).get("30_to_34", [])
        if changed != allowed:
            fail(f"{name} 30-to-34 role changes must be explicit: {changed}")


def profile_positions(model: dict, profile: dict) -> list[str] | None:
    position_set = profile.get("position_set")
    positions = profile.get("logical_positions")
    if position_set and positions:
        fail("profile cannot use position_set and logical_positions")
    if position_set:
        try:
            return model["position_sets"][position_set]
        except KeyError:
            fail(f"unknown position set {position_set}")
    return positions


def profile_firmware_positions(model: dict, profile: dict, firmware: str) -> list[str] | None:
    positions = profile.get(f"{firmware}_slots")
    if positions is not None:
        return positions
    return profile_positions(model, profile)


def validate_profiles(model: dict, profiles: dict) -> None:
    core_34 = set(model["position_sets"]["core_34"])
    for name, profile in profiles["profiles"].items():
        physical = profile["physical_keys"]
        bindings = profile["binding_positions"]
        board_only = profile.get("board_only_positions", [])
        if physical <= 0 or bindings <= 0:
            fail(f"{name} has invalid key count")
        if len(board_only) != len(set(board_only)):
            fail(f"{name} repeats board-only positions")
        if bindings < physical:
            fail(f"{name} has fewer binding positions than physical keys")
        if bindings - physical != len(board_only):
            fail(f"{name} must name every non-physical binding position")
        matrix_positions = profile.get("matrix_positions", bindings)
        unbound_matrix = profile.get("unbound_matrix_positions", [])
        if matrix_positions < bindings:
            fail(f"{name} has fewer matrix positions than bindings")
        if matrix_positions - bindings != len(unbound_matrix):
            fail(f"{name} must name every unbound matrix position")
        if len(unbound_matrix) != len(set(unbound_matrix)):
            fail(f"{name} repeats unbound matrix positions")
        if profile["alpha_capacity"] not in {30, 34, 38}:
            fail(f"{name} has unsupported alpha capacity")
        if profile["layout_source"] not in {"cols_thumbs", "zmk_dts", "qmk_info", "custom"}:
            fail(f"{name} has unsupported layout source")
        if "qmk" in profile and not profile["qmk"]["layout"]:
            fail(f"{name} lacks a QMK layout")
        positions = profile_positions(model, profile)
        if positions is not None:
            if len(positions) != bindings:
                fail(f"{name} logical positions has {len(positions)}, expected {bindings}")
            if len(set(positions)) != len(positions):
                fail(f"{name} repeats logical positions")
        for firmware in ("zmk", "qmk"):
            slots = profile.get(f"{firmware}_slots")
            if slots is None:
                continue
            if firmware not in profile:
                fail(f"{name} has {firmware.upper()} slots without a {firmware.upper()} target")
            if len(slots) != bindings:
                fail(f"{name} {firmware.upper()} slots has {len(slots)}, expected {bindings}")
            if len(set(slots)) != len(slots):
                fail(f"{name} repeats {firmware.upper()} slots")
            if profile["alpha_capacity"] >= 34 and set(slots) & core_34 != core_34:
                fail(f"{name} {firmware.upper()} slots must map every 34-key core role")
            if firmware == "qmk" and not set(board_only).issubset(slots):
                fail(f"{name} {firmware.upper()} slots must name board-only positions")


def zmk_positions(path: Path) -> list[str]:
    text = path.read_text()
    match = re.search(r"\bmap\s*=\s*<(?P<map>.*?)>;", text, re.S)
    if not match:
        fail(f"{path} has no matrix transform map")
    return re.findall(r"RC\(\s*\d+\s*,\s*\d+\s*\)", match.group("map"))


def qmk_positions(path: Path, layout: str) -> list[str]:
    data = load(path)
    try:
        entries = data["layouts"][layout]["layout"]
    except KeyError as error:
        fail(f"{path} has no {layout} layout")
        raise error
    positions = []
    for entry in entries:
        matrix = entry.get("matrix")
        if matrix is None:
            positions.append("visual")
        else:
            positions.append(",".join(str(value) for value in matrix))
    return positions


def select_qmk_variant(text: str, define: str | None) -> str:
    marker = "#ifdef RAZEN_KLOR_KONRAD"
    if marker not in text:
        return text
    before, conditional = text.split(marker, 1)
    konrad, polydactyl = conditional.split("#else", 1)
    polydactyl, after = polydactyl.split("#endif", 1)
    return before + (konrad if define == "RAZEN_KLOR_KONRAD" else polydactyl) + after


def qmk_adapter_positions(repo: Path, model: dict, profile: dict) -> list[str | None] | None:
    if "qmk" not in profile:
        return None
    path = repo / "qmk" / "keyboards" / profile["qmk"]["keyboard"] / "keymaps" / "razen" / "keymap.c"
    if not path.exists():
        return None
    text = select_qmk_variant(path.read_text(), profile.get("qmk_define"))
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"\\\s*\n", " ", text)
    match = re.search(
        r"#\s*define\s+RAZEN_LAYOUT\s*\((?P<params>[^)]*)\)\s*(?P<body>LAYOUT(?:_[A-Za-z0-9_]+)?\s*\((?P<slots>[^)]*)\))",
        text,
        re.S,
    )
    if not match:
        fail(f"{path} has no RAZEN_LAYOUT")
    params = [value.strip() for value in match.group("params").split(",") if value.strip()]
    roles = model["position_sets"]["core_34"]
    if len(params) != len(roles):
        fail(f"{path} RAZEN_LAYOUT has {len(params)} parameters, expected {len(roles)}")
    parameter_roles = dict(zip(params, roles))
    slots = [value.strip() for value in match.group("slots").split(",") if value.strip()]
    return [parameter_roles.get(value) for value in slots]


def source_positions(repo: Path, profile: dict) -> dict[str, list[str]]:
    result: dict[str, list[str]] = {}
    if "zmk_transform" in profile:
        result["zmk"] = zmk_positions(repo / profile["zmk_transform"])
    if "qmk_info" in profile:
        result["qmk"] = qmk_positions(repo / profile["qmk_info"], profile["qmk"]["layout"])
    return result


def validate_profile_sources(repo: Path, model: dict, profiles: dict) -> None:
    for name, profile in profiles["profiles"].items():
        positions = source_positions(repo, profile)
        if profile.get("matrix_confirmation_required"):
            continue
        for firmware, order in positions.items():
            if len(order) != profile["binding_positions"]:
                fail(f"{name} {firmware} order has {len(order)} positions, expected {profile['binding_positions']}")
            firmware_positions = profile_firmware_positions(model, profile, firmware)
            if firmware_positions is not None and len(order) != len(firmware_positions):
                fail(f"{name} {firmware} order does not match logical positions")
        adapter_positions = qmk_adapter_positions(repo, model, profile)
        expected = profile_firmware_positions(model, profile, "qmk")
        if adapter_positions is not None and expected is not None:
            if len(adapter_positions) != len(expected):
                fail(f"{name} QMK adapter has {len(adapter_positions)} slots, expected {len(expected)}")
            core_34 = set(model["position_sets"]["core_34"])
            for index, (actual, wanted) in enumerate(zip(adapter_positions, expected)):
                if wanted in core_34 and actual != wanted:
                    fail(f"{name} QMK adapter slot {index} maps {actual}, expected {wanted}")
                if wanted not in core_34 and actual in core_34:
                    fail(f"{name} QMK adapter slot {index} unexpectedly maps {actual}")


def manifest(repo: Path, model: dict, profiles: dict, name: str) -> dict:
    profile = profiles["profiles"][name]
    capacity = str(profile["alpha_capacity"])
    graphite_capacity = "34" if capacity == "38" else capacity
    vestnik_capacity = "extended" if capacity == "38" and profile["physical_keys"] >= 42 else capacity
    return {
        "profile": name,
        "physical_keys": profile["physical_keys"],
        "binding_positions": profile["binding_positions"],
        "matrix_positions": profile.get("matrix_positions", profile["binding_positions"]),
        "board_only_positions": profile.get("board_only_positions", []),
        "unbound_matrix_positions": profile.get("unbound_matrix_positions", []),
        "layout_source": profile["layout_source"],
        "firmware_order": source_positions(repo, profile),
        "logical_positions": profile_positions(model, profile),
        "firmware_logical_positions": {
            firmware: profile_firmware_positions(model, profile, firmware)
            for firmware in source_positions(repo, profile)
        },
        "matrix_confirmation_required": profile.get("matrix_confirmation_required", False),
        "graphite": model["alphas"]["graphite"][graphite_capacity],
        "vestnik_dm": model["alphas"]["vestnik_dm"][vestnik_capacity],
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["validate", "manifest"])
    parser.add_argument("--repo", type=Path, default=Path.cwd())
    parser.add_argument("--profile")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    repo = args.repo.resolve()
    model = load(repo / "keymap" / "model.json")
    profiles = load(repo / "keymap" / "profiles.json")
    validate_position_sets(model)
    validate_alphas(model)
    validate_profiles(model, profiles)
    validate_profile_sources(repo, model, profiles)

    if args.command == "validate":
        return

    if not args.profile or not args.out:
        parser.error("manifest requires --profile and --out")
    if args.profile not in profiles["profiles"]:
        parser.error(f"unknown profile: {args.profile}")
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(manifest(repo, model, profiles, args.profile), ensure_ascii=False, indent=2) + "\n")


if __name__ == "__main__":
    try:
        main()
    except ValueError as error:
        print(f"keymap: {error}", file=sys.stderr)
        raise SystemExit(1)
