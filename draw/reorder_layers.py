"""Reorder layers and relabel Vestnik (Russian Cyrillic) layer in keymap-drawer YAML."""

import sys
import yaml

VESTNIK_MAP = {
    "W": "Ц",
    "L": "Д",
    "H": "Р",
    "U": "Г",
    "[": "Х",
    "A": "Ф",
    "G": "П",
    "F": "А",
    "Z": "Я",
    "'": "Э",
    "C": "С",
    "N": "Т",
    "Y": "Н",
    "R": "К",
    ",": "Б",
    "M": "Ь",
    "D": "В",
    "J": "О",
    "T": "Е",
    "B": "И",
    "I": "Ш",
    "P": "З",
    "K": "Л",
    "V": "М",
    "X": "Ч",
    ";": "Ж",
    "Q": "Й",
    "S": "Ы",
    "E": "У",
    ".": "Ю",
}


def translate_vestnik_key(k):
    if isinstance(k, str):
        return VESTNIK_MAP.get(k, k)
    if isinstance(k, dict) and "t" in k:
        k = dict(k)
        k["t"] = VESTNIK_MAP.get(k["t"], k["t"])
    return k


def get_hold_layer(key):
    """Extract hold layer name from a key dict, e.g. {t: Esc, h: Nav} -> 'Nav'."""
    if isinstance(key, dict) and "h" in key:
        return key["h"]
    return None


def build_held_map(data):
    """Derive which positions are held for each layer from base layer hold-taps and combos."""
    held = {}
    first_layer = next(iter(data["layers"].values()), [])

    for pos, key in enumerate(first_layer):
        layer = get_hold_layer(key)
        if layer:
            held.setdefault(layer, []).append(pos)

    for combo in data.get("combos", []):
        k = combo.get("k", "")
        name = k.get("t") if isinstance(k, dict) else k if isinstance(k, str) else None
        if name and combo.get("p"):
            held.setdefault(name, []).extend(combo["p"])

    return held


path, *order = sys.argv[1:]
with open(path) as f:
    data = yaml.safe_load(f)

layers = data["layers"]
if "Vestnik" in layers:
    layers["Vestnik"] = [translate_vestnik_key(k) for k in layers["Vestnik"]]

data["layers"] = {name: layers[name] for name in order if name in layers}

if "combos" in data:
    kept_layers = set(data["layers"])
    for combo in data["combos"]:
        if combo.get("k") == "Magic":
            combo["k"] = {
                "t": "System",
                "type": "layer-activator",
            }
        if "l" in combo:
            combo["l"] = [l for l in combo["l"] if l in kept_layers]
    data["combos"] = [c for c in data["combos"] if "l" not in c or c["l"]]

held = build_held_map(data)
for layer_name, positions in held.items():
    if layer_name in data["layers"]:
        layer = data["layers"][layer_name]
        for pos in positions:
            if pos < len(layer):
                layer[pos] = {"type": "held"}

with open(path, "w") as f:
    yaml.dump(data, f, default_flow_style=None, allow_unicode=True, sort_keys=False)
