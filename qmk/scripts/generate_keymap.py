#!/usr/bin/env python3
"""Generate shared QMK layer/combo tables from the ZMK config."""

from __future__ import annotations

import argparse
import re
import subprocess
from pathlib import Path


LAYER_FILES = [
    "alpha_graphite.dtsi",
    "alpha_vestnik.dtsi",
    "symbol.dtsi",
    "nav.dtsi",
    "num.dtsi",
    "fn.dtsi",
    "mouse.dtsi",
    "system.dtsi",
]

LAYER_ENUMS = {
    "Graphite": "L_GRAPHITE",
    "Vestnik": "L_VESTNIK",
    "VestnikDm": "L_VESTNIK",
    "Symbol": "L_SYMBOL",
    "Nav": "L_NAV",
    "Num": "L_NUM",
    "NumMirror": "L_NUM_MIRROR",
    "Fn": "L_FN",
    "Mouse": "L_MOUSE",
    "System": "L_SYSTEM",
    "Magic": "L_SYSTEM",
}

STANDALONE = {
    "THUMB_MAGIC": "MAGIC",
    "SYS_SLOT1": "TO(L_GRAPHITE)",
    "SYS_SLOT2": "TO(L_VESTNIK)",
    "SYS_SLOT3": "KC_NO",
    "SYS_LIGHT_TOG": "RGB_TOG",
    "SYS_LIGHT_DEC": "RGB_VAD",
    "SYS_LIGHT_INC": "RGB_VAI",
}

POSITION_ENUMS = {
    "LT1": "P_LT1",
    "LT2": "P_LT2",
    "LT3": "P_LT3",
    "LT4": "P_LT4",
    "RT0": "P_RT0",
    "RT1": "P_RT1",
    "RT2": "P_RT2",
    "RT3": "P_RT3",
    "LT0": "P_LT0",
    "LM0": "P_LM0",
    "LM1": "P_LM1",
    "LM2": "P_LM2",
    "LM3": "P_LM3",
    "LM4": "P_LM4",
    "RM0": "P_RM0",
    "RM1": "P_RM1",
    "RM2": "P_RM2",
    "RM3": "P_RM3",
    "RM4": "P_RM4",
    "RT4": "P_RT4",
    "LB0": "P_LB0",
    "LB1": "P_LB1",
    "LB2": "P_LB2",
    "LB3": "P_LB3",
    "LB4": "P_LB4",
    "RB0": "P_RB0",
    "RB1": "P_RB1",
    "RB2": "P_RB2",
    "RB3": "P_RB3",
    "RB4": "P_RB4",
    "LH1": "P_LH1",
    "LH2": "P_LH2",
    "RH1": "P_RH1",
    "RH2": "P_RH2",
}

KEYS = {
    "A": "KC_A",
    "B": "KC_B",
    "C": "KC_C",
    "D": "KC_D",
    "E": "KC_E",
    "F": "KC_F",
    "G": "KC_G",
    "H": "KC_H",
    "I": "KC_I",
    "J": "KC_J",
    "K": "KC_K",
    "L": "KC_L",
    "M": "KC_M",
    "N": "KC_N",
    "O": "KC_O",
    "P": "KC_P",
    "Q": "KC_Q",
    "R": "KC_R",
    "S": "KC_S",
    "T": "KC_T",
    "U": "KC_U",
    "V": "KC_V",
    "W": "KC_W",
    "X": "KC_X",
    "Y": "KC_Y",
    "Z": "KC_Z",
    "N0": "KC_0",
    "N1": "KC_1",
    "N2": "KC_2",
    "N3": "KC_3",
    "N4": "KC_4",
    "N5": "KC_5",
    "N6": "KC_6",
    "N7": "KC_7",
    "N8": "KC_8",
    "N9": "KC_9",
    "SPACE": "KC_SPC",
    "RET": "KC_ENT",
    "ESC": "KC_ESC",
    "TAB": "KC_TAB",
    "CAPS": "KC_CAPS",
    "BSPC": "KC_BSPC",
    "DEL": "KC_DEL",
    "PG_UP": "KC_PGUP",
    "PG_DN": "KC_PGDN",
    "UP": "KC_UP",
    "DOWN": "KC_DOWN",
    "LEFT": "KC_LEFT",
    "RIGHT": "KC_RGHT",
    "HOME": "KC_HOME",
    "END": "KC_END",
    "LGUI": "KC_LGUI",
    "LALT": "KC_LALT",
    "LCTRL": "KC_LCTL",
    "LSHFT": "KC_LSFT",
    "RGUI": "KC_RGUI",
    "RALT": "KC_RALT",
    "RCTRL": "KC_RCTL",
    "RSHFT": "KC_RSFT",
    "F1": "KC_F1",
    "F2": "KC_F2",
    "F3": "KC_F3",
    "F4": "KC_F4",
    "F5": "KC_F5",
    "F6": "KC_F6",
    "F7": "KC_F7",
    "F8": "KC_F8",
    "F9": "KC_F9",
    "F10": "KC_F10",
    "F11": "KC_F11",
    "F12": "KC_F12",
    "COMMA": "KC_COMM",
    "DOT": "KC_DOT",
    "SEMI": "KC_SCLN",
    "SQT": "KC_QUOT",
    "MINUS": "KC_MINS",
    "EQUAL": "KC_EQL",
    "FSLH": "KC_SLSH",
    "BSLH": "KC_BSLS",
    "LBKT": "KC_LBRC",
    "RBKT": "KC_RBRC",
    "GRAVE": "KC_GRV",
    "C_PREV": "KC_MPRV",
    "C_PP": "KC_MPLY",
    "C_NEXT": "KC_MNXT",
    "C_MUTE": "KC_MUTE",
    "_HOME": "KC_HOME_OS",
    "_END": "KC_END_OS",
    "_LOCK": "KC_LOCK_OS",
    "_SHUTDOWN": "KC_SHUT_OS",
    "_SLEEP": "KC_SLEP",
    "_SCR_FULL": "KC_SCR_FULL_OS",
    "_SCR_AREA": "KC_SCR_AREA_OS",
    "_PASTE": "KC_PASTE_OS",
}

SHIFTED = {
    "AMPS": "S(KC_7)",
    "AT": "S(KC_2)",
    "CARET": "S(KC_6)",
    "COLON": "S(KC_SCLN)",
    "DLLR": "S(KC_4)",
    "DQT": "S(KC_QUOT)",
    "EXCL": "S(KC_1)",
    "GT": "S(KC_DOT)",
    "HASH": "S(KC_3)",
    "LBRC": "S(KC_LBRC)",
    "LPAR": "S(KC_9)",
    "LT": "S(KC_COMM)",
    "PIPE": "S(KC_BSLS)",
    "PLUS": "S(KC_EQL)",
    "PRCNT": "S(KC_5)",
    "QMARK": "S(KC_SLSH)",
    "RBRC": "S(KC_RBRC)",
    "RPAR": "S(KC_0)",
    "STAR": "S(KC_8)",
    "TILDE": "S(KC_GRV)",
    "UNDER": "S(KC_MINS)",
}

MODS = {"LG": "G", "LC": "C", "LS": "S", "LA": "A", "RG": "G", "RC": "C", "RS": "S", "RA": "A"}
HRM = {
    ("hml", "LGUI"): "HMLG",
    ("hml", "LALT"): "HMLA",
    ("hml", "LCTRL"): "HMLC",
    ("hml", "LSHFT"): "HMLS",
    ("hmr", "RSHFT"): "HMRS",
    ("hmr", "RCTRL"): "HMRC",
    ("hmr", "RALT"): "HMRA",
    ("hmr", "RGUI"): "HMRG",
}

GRAPHITE_ADAPTIVE_QMK_KEYCODE = {
    "graphite_bigram_n": "HMLG(KC_N)",
    "graphite_bigram_r": "HMLA(KC_R)",
    "graphite_bigram_s": "HMLS(KC_S)",
    "graphite_bigram_h": "HMRS(KC_H)",
    "graphite_bigram_e": "HMRA(KC_E)",
}

DEFINE_INT_DEFAULTS = {
    "COMBO_TERM": 30,
    "COMBO_IDLE": 50,
}
HRM_TAPPING_TERM_MS = 180
HRM_PRIOR_IDLE_MS = 100


def qmk_basic_keycode(token: str) -> str:
    keycode = qmk_key(token)
    if not keycode.startswith("KC_"):
        raise ValueError(f"Expected a basic key token, got {token!r}")
    return keycode


def strip_comments(text: str) -> str:
    return "\n".join(line.split("//", 1)[0] for line in text.splitlines())


def preprocess_dtsi(repo: Path, path: Path) -> str:
    text = path.read_text().replace("#binding-cells", "binding-cells")
    cmd = [
        "cpp",
        "-E",
        "-P",
        "-x",
        "c",
        "-I",
        str(repo / "config"),
        "-I",
        str(path.parent),
        "-include",
        str(repo / "config" / "includes" / "features.dtsi"),
        "-",
    ]
    result = subprocess.run(cmd, input=text, text=True, capture_output=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"Failed to preprocess {path}:\n{result.stderr}")
    return result.stdout


def macro_calls(text: str, macro: str) -> list[str]:
    calls: list[str] = []
    i = 0
    needle = f"{macro}("
    while True:
        start = text.find(needle, i)
        if start == -1:
            return calls
        pos = start + len(needle)
        depth = 1
        while pos < len(text) and depth:
            if text[pos] == "(":
                depth += 1
            elif text[pos] == ")":
                depth -= 1
            pos += 1
        calls.append(text[start + len(needle) : pos - 1])
        i = pos


def split_args(s: str) -> list[str]:
    args: list[str] = []
    depth = 0
    start = 0
    for i, ch in enumerate(s):
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif ch == "," and depth == 0:
            args.append(s[start:i].strip())
            start = i + 1
    args.append(s[start:].strip())
    return args


def layer_const(name: str) -> str:
    if name not in LAYER_ENUMS:
        raise ValueError(f"Unknown layer {name!r}")
    return LAYER_ENUMS[name]


def qmk_key(token: str) -> str:
    token = token.strip()
    match = re.fullmatch(r"([A-Z][A-Z])\((.*)\)", token)
    if match and match.group(1) in MODS:
        return f"{MODS[match.group(1)]}({qmk_key(match.group(2))})"
    if token in SHIFTED:
        return SHIFTED[token]
    if token in KEYS:
        return KEYS[token]
    raise ValueError(f"Unknown key token {token!r}")


def qmk_layer(token: str) -> str:
    if not token.startswith("LAYER_"):
        raise ValueError(f"Unknown layer token {token!r}")
    return layer_const(token.removeprefix("LAYER_"))


def config_int(repo: Path, name: str) -> int:
    text = (repo / "config" / "includes" / "defines.dtsi").read_text()
    match = re.search(rf"^\s*#\s*define\s+{re.escape(name)}\s+(\d+)\b", text, flags=re.M)
    if match:
        return int(match.group(1))
    if name in DEFINE_INT_DEFAULTS:
        return DEFINE_INT_DEFAULTS[name]
    raise ValueError(f"Unknown integer config {name!r}")


def parse_int_expr(repo: Path, expr: str) -> int:
    expr = expr.strip()
    if expr.isdigit():
        return int(expr)
    return config_int(repo, expr)


def convert_binding(name: str, args: list[str]) -> str:
    if name == "none":
        return "KC_NO"
    if name == "trans":
        return "KC_TRNS"
    if name == "kp":
        return qmk_key(args[0])
    if name in {"hml", "hmr"}:
        return f"{HRM[(name, args[0])]}({qmk_key(args[1])})"
    # Generated adaptive behaviors, any layout. A grid cell maps to its base key
    # (or home-row mod); the swap logic itself is emitted separately for Graphite
    # and is ZMK-only for the other layouts.
    m = re.fullmatch(r"[a-z]+_bigram_([a-z])", name)
    if m:
        return qmk_key(m.group(1).upper())
    m = re.fullmatch(r"[a-z]+_(hml|hmr)_([a-z])", name)
    if m:
        return f"{HRM[(m.group(1), args[0])]}({qmk_key(m.group(2).upper())})"
    if re.fullmatch(r"[a-z]+_magic_ht", name):
        return "NUM_REPEAT"
    if name == "lt":
        return f"LT({qmk_layer(args[0])}, {qmk_key(args[1])})"
    if name == "sl":
        return f"OSL({qmk_layer(args[0])})"
    if name == "sk":
        if args[0] != "LSHFT":
            raise ValueError(f"Unsupported sticky key {args!r}")
        return "STICKY_SHIFT"
    if name == "mo":
        return f"MO({qmk_layer(args[0])})"
    if name == "nav_ht":
        return "NAV_ESC"
    if name == "num_repeat":
        return "NUM_REPEAT"
    if name == "num_shift":
        return "NUM_SHIFT"
    if name == "nav_repeat":
        return "NUM_0"
    if name == "mouse_ht":
        return "MOUSE_T"
    if name == "thumb_bspc":
        return "NAV_BSPC_DEL"
    if name == "thumb_spc":
        return f"LT({qmk_layer(args[0])}, {qmk_key(args[1])})"
    if name == "thumb_r":
        return f"LT({qmk_layer(args[0])}, {qmk_key(args[1])})"
    if name == "sturdy_num_repeat":
        return "NUM_0"
    if name == "alpha_magic_racket_1":
        return "RACKET_MAGIC"
    if name == "alpha_magic_sturdy":
        return "STURDY_MAGIC"
    if name == "sturdy_repeat":
        return "STURDY_REPEAT"
    if name == "key_repeat":
        return "QK_REP"
    if name == "comma_excl":
        return "COM_EX"
    if name == "dot_qmark":
        return "DOT_Q"
    if name == "minus_slash":
        return "MNS_SLSH"
    if name == "sqt_dqt":
        return "SQT_DQT"
    if name == "undo_redo":
        return "UNDO_REDO"
    if name == "paste_morph":
        return "PASTE_M"
    if name == "copy_cut":
        return "COPY_CUT"
    if name == "bspc_del":
        return "BSPC_DEL"
    if name == "esc_tab":
        return "ESC_TAB"
    if name == "v_comma_excl":
        return "V_COM_EX"
    if name == "v_dot_qmark":
        return "V_DOT_Q"
    if name == "lang_en":
        return "LANG_EN"
    if name == "lang_ru":
        return "LANG_RU"
    if name == "to_graphite":
        return "TO(L_GRAPHITE)"
    if name == "to_whirlmrl":
        return "TO(L_WHIRLMRL)"
    if name == "to_vestnik":
        return "TO(L_VESTNIK)"
    if name == "to":
        return f"TO({qmk_layer(args[0])})"
    if name == "bootloader":
        return "QK_BOOT"
    if name == "sys_reset":
        return "QK_REBOOT"
    if name == "soft_off":
        return "KC_NO"
    if name == "out":
        return "KC_NO"
    if name == "bt":
        return "KC_NO"
    if name in {"bt_0", "bt_1", "bt_2", "bt_3"}:
        return "KC_NO"
    if name == "mmv":
        return {"MOVE_UP": "MS_UP", "MOVE_DOWN": "MS_DOWN", "MOVE_LEFT": "MS_LEFT", "MOVE_RIGHT": "MS_RGHT"}[args[0]]
    if name == "msc":
        return {"SCRL_UP": "MS_WHLU", "SCRL_DOWN": "MS_WHLD", "SCRL_LEFT": "MS_WHLL", "SCRL_RIGHT": "MS_WHLR"}[args[0]]
    if name == "mkp":
        return {"LCLK": "MS_BTN1", "RCLK": "MS_BTN2", "MCLK": "MS_BTN3", "MB4": "MS_BTN4", "MB5": "MS_BTN5"}[args[0]]
    raise ValueError(f"Unsupported ZMK behavior &{name} {' '.join(args)}")


def parse_binding_list(s: str) -> list[str]:
    bindings: list[str] = []
    tokens = s.replace("\n", " ").split()
    i = 0
    while i < len(tokens):
        token = tokens[i]
        if token in {"LH_NONE", "RH_NONE"}:
            i += 1
            continue
        if token in STANDALONE:
            bindings.append(STANDALONE[token])
            i += 1
            continue
        if not token.startswith("&"):
            raise ValueError(f"Unexpected token {token!r} in {s!r}")
        name = token[1:]
        i += 1
        args: list[str] = []
        while i < len(tokens) and not tokens[i].startswith("&") and tokens[i] not in STANDALONE:
            if tokens[i] not in {"LH_NONE", "RH_NONE"}:
                args.append(tokens[i])
            i += 1
        bindings.append(convert_binding(name, args))
    return bindings


def parse_layers(repo: Path) -> list[tuple[str, list[str]]]:
    layers: list[tuple[str, list[str]]] = []
    layer_dir = repo / "config" / "includes" / "layers"
    for filename in LAYER_FILES:
        text = strip_comments(preprocess_dtsi(repo, layer_dir / filename))
        for call in macro_calls(text, "ZMK_BASE_LAYER"):
            args = split_args(call)
            name = args[0]
            cells: list[str] = []
            for section in args[1:]:
                cells.extend(parse_binding_list(section))
            if len(cells) != 34:
                raise ValueError(f"Layer {name} produced {len(cells)} keys, expected 34")
            layers.append((name, cells))
    return layers


def parse_graphite_adaptive_keys(repo: Path) -> list[dict[str, object]]:
    text = strip_comments(preprocess_dtsi(repo, repo / "config" / "includes" / "layers" / "alpha_graphite.dtsi"))
    adaptive_keys: list[dict[str, object]] = []

    for call in macro_calls(text, "ZMK_ADAPTIVE_KEY"):
        args = split_args(call)
        if len(args) != 2:
            continue
        name = args[0].strip()
        if not name.startswith("graphite_bigram_"):
            continue

        body = args[1]
        default_match = re.search(r"bindings\s*=\s*<\s*&kp\s+([A-Z])\s*>;", body)
        if not default_match:
            raise ValueError(f"Unsupported default binding for {name}")

        triggers = []
        timeout_ms = None
        for child in re.finditer(r"\w+\s*\{([^{}]*)\};", body, flags=re.S):
            child_body = child.group(1)
            trigger_match = re.search(r"trigger-keys\s*=\s*<\s*([A-Z])\s*>;", child_body)
            binding_match = re.search(r"bindings\s*=\s*<\s*&kp\s+([A-Z])\s*>;", child_body)
            timeout_match = re.search(r"max-prior-idle-ms\s*=\s*<\s*(\d+)\s*>;", child_body)
            if not trigger_match or not binding_match:
                raise ValueError(f"Unsupported adaptive child in {name}: {child_body!r}")
            if timeout_match:
                timeout_ms = int(timeout_match.group(1))
            triggers.append(
                {
                    "prior": qmk_basic_keycode(trigger_match.group(1)),
                    "output": qmk_basic_keycode(binding_match.group(1)),
                }
            )

        if triggers:
            adaptive_keys.append(
                {
                    "name": name,
                    "replacement": qmk_basic_keycode(default_match.group(1)),
                    "qmk_keycode": GRAPHITE_ADAPTIVE_QMK_KEYCODE.get(name, convert_binding(name, [])),
                    "triggers": triggers,
                    "timeout_ms": timeout_ms or 1000,
                }
            )

    return adaptive_keys


def combo_action(action: str) -> tuple[str, str | None]:
    bits = action.split()
    if bits[0] == "&caps_morph":
        return "handle_caps_combo();", None
    if bits[0] == "&undo_redo":
        return "tap_morph(C(KC_Z), C(S(KC_Z)));", None
    if bits[0] == "&paste_morph":
        return "tap_morph(KC_PASTE_OS, C(KC_V));", None
    if bits[0] == "&copy_cut":
        return "tap_morph(C(KC_C), C(KC_X));", None
    if bits[0] == "&kp":
        return f"tap_code16({qmk_key(bits[1])});", None
    if bits[0] == "&v_comma_excl":
        return "tap_morph(S(KC_SLSH), S(KC_1));", None
    if bits[0] == "&v_dot_qmark":
        return "tap_morph(KC_SLSH, S(KC_7));", None
    if bits[0] == "&sl":
        layer = qmk_layer(bits[1])
        return f"layer_on({layer});", f"layer_off({layer});"
    if bits[0] == "&mouse_ht":
        return "layer_on(L_MOUSE);", "layer_off(L_MOUSE);"
    if bits[0] == "&leader":
        return "tap_code16(QK_LEAD);", None
    raise ValueError(f"Unsupported combo action {action!r}")


def combo_layer_check(layers: str) -> str:
    if layers in {"ALPHA_LAYERS", "CAPS_LAYERS"}:
        names = ["L_GRAPHITE", "L_VESTNIK"]
    elif layers.startswith("LAYER_"):
        names = [qmk_layer(layers)]
    else:
        names = [qmk_layer(layer) for layer in layers.split()]
    return " || ".join(f"generated_combo_layer_is({name})" for name in names)


def parse_combos(repo: Path) -> list[dict[str, object]]:
    text = strip_comments(preprocess_dtsi(repo, repo / "config" / "includes" / "combos.dtsi"))
    combos: list[dict[str, object]] = []
    for call in macro_calls(text, "ZMK_COMBO"):
        args = split_args(call)
        if len(args) != 6:
            raise ValueError(f"Unexpected combo args: {args!r}")
        name, action, positions, layers, term, idle = args
        pressed, released = combo_action(action)
        if pressed is None:
            continue
        combos.append(
            {
                "name": name,
                "enum": "CB_" + re.sub(r"[^A-Za-z0-9]+", "_", name).upper(),
                "array": "combo_" + re.sub(r"[^A-Za-z0-9]+", "_", name).lower(),
                "positions": [POSITION_ENUMS[p] for p in positions.split()],
                "pressed": pressed,
                "released": released,
                "layer_check": combo_layer_check(layers),
                "term": parse_int_expr(repo, term),
                "idle": parse_int_expr(repo, idle),
            }
        )
    return combos


def collect_hrm_keycodes(layers: list[tuple[str, list[str]]]) -> list[str]:
    keycodes = set()
    for _name, cells in layers:
        for cell in cells:
            if cell.startswith(("HML", "HMR")):
                keycodes.add(cell)
    return sorted(keycodes)


def emit_layers(layers: list[tuple[str, list[str]]]) -> str:
    out = ["const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {"]
    for name, cells in layers:
        out.append(f"    [{layer_const(name)}] = RAZEN_LAYOUT(")
        for idx in range(0, len(cells), 10):
            chunk = cells[idx : idx + 10]
            comma = "," if idx + 10 < len(cells) else ""
            out.append("        " + ", ".join(f"{cell:<16}" for cell in chunk) + comma)
        out.append("    ),")
        out.append("")
    out.append("#ifdef RAZEN_COMBO_REF_LAYER")
    out.append("    [RAZEN_COMBO_REF_LAYER] = RAZEN_LAYOUT(")
    out.append(
        "        P_LT4, P_LT3, P_LT2, P_LT1, P_LT0, P_RT0, P_RT1, P_RT2, P_RT3, P_RT4,"
    )
    out.append(
        "        P_LM4, P_LM3, P_LM2, P_LM1, P_LM0, P_RM0, P_RM1, P_RM2, P_RM3, P_RM4,"
    )
    out.append(
        "        P_LB4, P_LB3, P_LB2, P_LB1, P_LB0, P_RB0, P_RB1, P_RB2, P_RB3, P_RB4,"
    )
    out.append("        P_LH2, P_LH1, P_RH1, P_RH2")
    out.append("    ),")
    out.append("#endif")
    out.append("};")
    return "\n".join(out)


def emit_combos(combos: list[dict[str, object]]) -> str:
    out = ["enum combo_events {"]
    for combo in combos:
        out.append(f"    {combo['enum']},")
    out.append("};")
    out.append("")
    for combo in combos:
        positions = ", ".join(combo["positions"])  # type: ignore[arg-type]
        out.append(f"const uint16_t PROGMEM {combo['array']}[] = {{{positions}, COMBO_END}};")
    out.append("")
    out.append("combo_t key_combos[] = {")
    for combo in combos:
        out.append(f"    [{combo['enum']}] = COMBO_ACTION({combo['array']}),")
    out.append("};")
    out.append("")
    out.append("uint16_t get_combo_term(uint16_t combo_index, combo_t *combo) {")
    out.append("    (void)combo;")
    out.append("    switch (combo_index) {")
    for combo in combos:
        out.append(f"        case {combo['enum']}: return {combo['term']};")
    out.append("    }")
    out.append("    return COMBO_TERM;")
    out.append("}")
    out.append("")
    out.append("bool process_generated_combo_event(uint16_t combo_index, bool pressed) {")
    out.append("    if (!pressed) {")
    out.append("        switch (combo_index) {")
    for combo in combos:
        if combo["released"]:
            out.append(f"            case {combo['enum']}: {combo['released']} return false;")
    out.append("        }")
    out.append("        return true;")
    out.append("    }")
    out.append("")
    out.append("    switch (combo_index) {")
    for combo in combos:
        out.append(f"        case {combo['enum']}: {combo['pressed']} return false;")
    out.append("    }")
    out.append("    return true;")
    out.append("}")
    out.append("")
    out.append("static bool generated_combo_prior_idle_ok(combo_t *combo, keyrecord_t *record, uint16_t idle_ms) {")
    out.append("    return !record->event.pressed || combo->state != 0 || razen_current_keypress_idle_ms >= idle_ms;")
    out.append("}")
    out.append("")
    out.append("static bool generated_combo_layer_is(uint8_t layer) {")
    out.append("    return layer_state_cmp(layer_state | default_layer_state, layer);")
    out.append("}")
    out.append("")
    out.append("bool generated_combo_should_trigger(uint16_t combo_index, combo_t *combo, keyrecord_t *record) {")
    out.append("    switch (combo_index) {")
    for combo in combos:
        out.append(
            f"        case {combo['enum']}: "
            f"return generated_combo_prior_idle_ok(combo, record, {combo['idle']}) && ({combo['layer_check']});"
        )
    out.append("    }")
    out.append("    return true;")
    out.append("}")
    return "\n".join(out)


def emit_tap_hold_helpers(hrm_keycodes: list[str]) -> str:
    out = [
        f"#define RAZEN_HRM_TAPPING_TERM_MS {HRM_TAPPING_TERM_MS}",
        f"#define RAZEN_HRM_PRIOR_IDLE_MS {HRM_PRIOR_IDLE_MS}",
        "",
        "static uint32_t razen_last_keypress_timer = 0;",
        "static uint32_t razen_current_keypress_idle_ms = UINT32_MAX;",
        "",
        "bool pre_process_record_user(uint16_t keycode, keyrecord_t *record) {",
        "    (void)keycode;",
        "    if (record->event.pressed) {",
        "        razen_current_keypress_idle_ms = razen_last_keypress_timer ? timer_elapsed32(razen_last_keypress_timer) : UINT32_MAX;",
        "        razen_last_keypress_timer = timer_read32();",
        "    }",
        "    return true;",
        "}",
        "",
        "static bool generated_is_home_row_mod(uint16_t keycode) {",
        "    switch (keycode) {",
    ]

    for keycode in hrm_keycodes:
        out.append(f"        case {keycode}:")
    out.extend(
        [
            "            return true;",
            "    }",
            "    return false;",
            "}",
            "",
            "static bool generated_is_flow_tap_predecessor(uint16_t keycode) {",
            "    switch (get_tap_keycode(keycode)) {",
            "        case KC_A ... KC_Z:",
            "            return true;",
            "    }",
            "    return false;",
            "}",
            "",
            "uint16_t get_tapping_term(uint16_t keycode, keyrecord_t *record) {",
            "    (void)record;",
            "    return generated_is_home_row_mod(keycode) ? RAZEN_HRM_TAPPING_TERM_MS : TAPPING_TERM;",
            "}",
            "",
            "bool get_permissive_hold(uint16_t keycode, keyrecord_t *record) {",
            "    (void)record;",
            "    return generated_is_home_row_mod(keycode);",
            "}",
            "",
            "uint16_t get_flow_tap_term(uint16_t keycode, keyrecord_t *record, uint16_t prev_keycode) {",
            "    (void)record;",
            "    if (!generated_is_home_row_mod(keycode) || !generated_is_flow_tap_predecessor(prev_keycode) ||",
            "        get_mods() || get_oneshot_mods() || get_weak_mods()) {",
            "        return 0;",
            "    }",
            "    return RAZEN_HRM_PRIOR_IDLE_MS;",
            "}",
        ]
    )
    return "\n".join(out)


def parse_graphite_yous(repo: Path) -> dict[str, object]:
    text = strip_comments(preprocess_dtsi(repo, repo / "config" / "includes" / "layers" / "alpha_graphite.dtsi"))
    for call in macro_calls(text, "ZMK_ADAPTIVE_KEY"):
        args = split_args(call)
        if len(args) != 2 or args[0].strip() != "graphite_yous":
            continue
        body = args[1]
        trigger = re.search(r"trigger-keys\s*=\s*<\s*([A-Z])\s*>;", body)
        prior = re.search(r"prior-keys\s*=\s*<\s*([A-Z])\s+([A-Z])\s*>;", body)
        timeout = re.search(r"max-prior-idle-ms\s*=\s*<\s*([A-Z_0-9]+)\s*>;", body)
        binding = re.search(r"bindings\s*=\s*<\s*&([a-z_]+)\s*>;", body)
        if not trigger or not prior or not timeout or not binding:
            raise ValueError("Unsupported graphite_yous definition")
        if binding.group(1) != "sqt_dqt":
            raise ValueError("graphite_yous must emit sqt_dqt")
        return {
            "history": [qmk_basic_keycode(prior.group(1)), qmk_basic_keycode(prior.group(2)), qmk_basic_keycode(trigger.group(1))],
            "timeout_ms": parse_int_expr(repo, timeout.group(1)),
        }
    raise ValueError("Missing graphite_yous definition")


def emit_graphite_yous(yous: dict[str, object]) -> str:
    history = yous["history"]
    timeout_ms = yous["timeout_ms"]
    return "\n".join(
        [
            "#ifndef GRAPHITE_YOUS_TIMEOUT_MS",
            f"#define GRAPHITE_YOUS_TIMEOUT_MS {timeout_ms}",
            "#endif",
            "",
            "static uint16_t generated_basic_history[3] = {KC_NO, KC_NO, KC_NO};",
            "static bool generated_yous_suppressed = false;",
            "",
            "static void generated_record_basic_key(uint16_t keycode) {",
            "    generated_basic_history[0] = generated_basic_history[1];",
            "    generated_basic_history[1] = generated_basic_history[2];",
            "    generated_basic_history[2] = keycode;",
            "}",
            "",
            "static void generated_reset_basic_history(void) {",
            "    generated_basic_history[0] = KC_NO;",
            "    generated_basic_history[1] = KC_NO;",
            "    generated_basic_history[2] = KC_NO;",
            "}",
            "",
            "static bool process_generated_graphite_yous(uint16_t keycode, keyrecord_t *record) {",
            "    if (keycode != HMLS(KC_S)) {",
            "        return true;",
            "    }",
            "    if (!record->event.pressed) {",
            "        if (generated_yous_suppressed) {",
            "            generated_yous_suppressed = false;",
            "            return false;",
            "        }",
            "        return true;",
            "    }",
            "    if (record->tap.count == 0 || get_highest_layer(layer_state) != L_GRAPHITE ||",
            "        get_mods() || get_oneshot_mods() || get_weak_mods() ||",
            "        timer_elapsed32(last_basic_key_timer) > GRAPHITE_YOUS_TIMEOUT_MS ||",
            f"        generated_basic_history[0] != {history[0]} ||",
            f"        generated_basic_history[1] != {history[1]} ||",
            f"        generated_basic_history[2] != {history[2]}) {{",
            "        return true;",
            "    }",
            "    generated_yous_suppressed = true;",
            "    tap_code16(KC_QUOT);",
            "    last_basic_keycode = KC_QUOT;",
            "    last_basic_key_timer = timer_read32();",
            "    generated_record_basic_key(KC_QUOT);",
            "    return false;",
            "}",
        ]
    )


def emit_sticky_shift() -> str:
    return "\n".join(
        [
            "#ifndef RAZEN_STICKY_SHIFT_TIMEOUT_MS",
            "#define RAZEN_STICKY_SHIFT_TIMEOUT_MS 1200",
            "#endif",
            "",
            "static bool generated_sticky_shift_active = false;",
            "static bool generated_sticky_shift_clear_after_press = false;",
            "static uint32_t generated_sticky_shift_timer = 0;",
            "",
            "static void generated_clear_sticky_shift(void) {",
            "    if (!generated_sticky_shift_active) {",
            "        return;",
            "    }",
            "    del_weak_mods(MOD_BIT(KC_LSFT));",
            "    send_keyboard_report();",
            "    generated_sticky_shift_active = false;",
            "    generated_sticky_shift_clear_after_press = false;",
            "}",
            "",
            "static bool generated_sticky_shift_ignores(uint16_t keycode) {",
            "    return IS_MODIFIER_KEYCODE(keycode) ||",
            "           (IS_QK_MODS(keycode) && QK_MODS_GET_BASIC_KEYCODE(keycode) == KC_NO) ||",
            "           IS_QK_ONE_SHOT_MOD(keycode);",
            "}",
            "",
            "static bool process_generated_sticky_shift(uint16_t keycode, keyrecord_t *record) {",
            "    if (keycode == STICKY_SHIFT) {",
            "        if (record->event.pressed) {",
            "            add_weak_mods(MOD_BIT(KC_LSFT));",
            "            send_keyboard_report();",
            "            generated_sticky_shift_active = true;",
            "            generated_sticky_shift_timer = timer_read32();",
            "        }",
            "        return false;",
            "    }",
            "",
            "    if (record->event.pressed && generated_sticky_shift_active && !generated_sticky_shift_ignores(keycode)) {",
            "        generated_sticky_shift_clear_after_press = true;",
            "    }",
            "    return true;",
            "}",
            "",
            "static void generated_sticky_shift_post_process(uint16_t keycode, keyrecord_t *record) {",
            "    (void)keycode;",
            "    if (record->event.pressed && generated_sticky_shift_clear_after_press) {",
            "        generated_clear_sticky_shift();",
            "    }",
            "}",
            "",
            "static void generated_sticky_shift_task(void) {",
            "    if (generated_sticky_shift_clear_after_press ||",
            "        (generated_sticky_shift_active && timer_elapsed32(generated_sticky_shift_timer) > RAZEN_STICKY_SHIFT_TIMEOUT_MS)) {",
            "        generated_clear_sticky_shift();",
            "    }",
            "}",
        ]
    )


def emit_graphite_adaptive(adaptive_keys: list[dict[str, object]]) -> str:
    if not adaptive_keys:
        return "\n".join(
            [
                "static bool process_generated_adaptive_key(uint16_t keycode, keyrecord_t *record) {",
                "    (void)keycode;",
                "    (void)record;",
                "    return true;",
                "}",
            ]
        )

    timeout_ms = max(int(key["timeout_ms"]) for key in adaptive_keys)

    out = [
        "#ifndef GRAPHITE_BIGRAM_TIMEOUT_MS",
        f"#define GRAPHITE_BIGRAM_TIMEOUT_MS {timeout_ms}",
        "#endif",
        "",
        "static bool process_generated_adaptive_key(uint16_t keycode, keyrecord_t *record) {",
        "    if (!record->event.pressed || get_highest_layer(layer_state) != L_GRAPHITE ||",
        "        get_mods() || get_oneshot_mods() || get_weak_mods() ||",
        "        timer_elapsed32(last_basic_key_timer) > GRAPHITE_BIGRAM_TIMEOUT_MS) {",
        "        return true;",
        "    }",
        "",
        "    uint16_t tap_keycode = KC_NO;",
        "    switch (keycode) {",
    ]

    for adaptive in adaptive_keys:
        qmk_keycode = adaptive["qmk_keycode"]
        replacement = adaptive["replacement"]
        if qmk_keycode != replacement:
            out.append(f"        case {qmk_keycode}:")
            out.append("            if (!record->tap.count) {")
            out.append("                return true;")
            out.append("            }")
            out.append(f"            tap_keycode = {replacement};")
            out.append("            break;")
        else:
            out.append(f"        case {qmk_keycode}: tap_keycode = {replacement}; break;")

    out.extend(
        [
            "        default:",
            "            return true;",
            "    }",
            "",
            "    switch (tap_keycode) {",
        ]
    )

    for adaptive in adaptive_keys:
        out.append(f"        case {adaptive['replacement']}:")
        out.append("            switch (last_basic_keycode) {")
        for trigger in adaptive["triggers"]:  # type: ignore[index]
            out.append(
                f"                case {trigger['prior']}: "
                f"tap_code16({trigger['output']}); "
                f"set_last_keycode({trigger['output']}); "
                "set_last_mods(0); "
                f"last_basic_keycode = {trigger['output']}; "
                "last_basic_key_timer = timer_read32(); "
                f"generated_record_basic_key({trigger['output']}); "
                "return false;"
            )
        out.append("            }")
        out.append("            break;")

    out.extend(
        [
            "    }",
            "",
            "    return true;",
            "}",
        ]
    )
    return "\n".join(out)


def emit_leader() -> str:
    return (
        "#ifdef LEADER_ENABLE\n"
        "void leader_end_user(void) {\n"
        "    if (leader_sequence_one_key(KC_C)) {\n"
        "        tap_code(KC_CAPS);\n"
        "    } else if (leader_sequence_one_key(KC_G)) {\n"
        "        layer_move(L_GRAPHITE);\n"
        "    } else if (leader_sequence_one_key(KC_V)) {\n"
        "        layer_move(L_VESTNIK);\n"
        "    } else if (leader_sequence_four_keys(KC_B, KC_O, KC_O, KC_T)) {\n"
        "        reset_keyboard();\n"
        "    } else if (leader_sequence_three_keys(KC_R, KC_E, KC_S)) {\n"
        "        soft_reset_keyboard();\n"
        "    }\n"
        "}\n"
        "#endif"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()

    layers = parse_layers(args.repo)
    combos = parse_combos(args.repo)
    graphite_adaptive = parse_graphite_adaptive_keys(args.repo)
    graphite_yous = parse_graphite_yous(args.repo)
    hrm_keycodes = collect_hrm_keycodes(layers)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(
        "/* Generated by qmk/scripts/generate_keymap.py. Do not edit. */\n\n"
        + emit_layers(layers)
        + "\n\n"
        + emit_tap_hold_helpers(hrm_keycodes)
        + "\n\n"
        + emit_combos(combos)
        + "\n\n"
        + emit_graphite_yous(graphite_yous)
        + "\n\n"
        + emit_sticky_shift()
        + "\n\n"
        + emit_graphite_adaptive(graphite_adaptive)
        + "\n\n"
        + emit_leader()
        + "\n"
    )


if __name__ == "__main__":
    main()
