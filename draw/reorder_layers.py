"""Reorder layers and relabel Vestnik Cyrillic in a keymap-drawer YAML file."""
import sys
import yaml

VESTNIK_MAP = {
    "W": "Ц", "L": "Д", "H": "Р", "U": "Г", "[": "Х",
    "A": "Ф", "G": "П", "F": "А", "Z": "Я", "'": "Э",
    "C": "С", "N": "Т", "Y": "Н", "R": "К", ",": "Б",
    "M": "Ь", "D": "В", "J": "О", "T": "Е", "B": "И",
    "I": "Ш", "P": "З", "K": "Л", "V": "М", "X": "Ч",
    ";": "Ж", "Q": "Й", "S": "Ы", "E": "У", ".": "Ю",
}


def translate_vestnik_key(k):
    if isinstance(k, str):
        return VESTNIK_MAP.get(k, k)
    if isinstance(k, dict) and "t" in k:
        k = dict(k)
        k["t"] = VESTNIK_MAP.get(k["t"], k["t"])
    return k


path, *order = sys.argv[1:]
with open(path) as f:
    data = yaml.safe_load(f)

layers = data["layers"]
if "Vestnik" in layers:
    layers["Vestnik"] = [translate_vestnik_key(k) for k in layers["Vestnik"]]

data["layers"] = {name: layers[name] for name in order if name in layers}

# Mark held thumb keys per layer.
# 34-key: LH2=30(Nav), LH1=31(Num), RH1=32(Symbol)
# 80-key (glove80): positions differ per layout
first_layer = next(iter(data["layers"].values()), [])
n_keys = len(first_layer)

if n_keys == 34:
    HELD = {
        "Nav": [31],
        "Num": [30],
        "Symbol": [32],
        "Fn": [32, 33],
        "Mouse": [30, 31],
        "System": [31, 32],
    }
elif n_keys == 80:
    HELD = {
        "Nav": [70],
        "Num": [69],
        "Symbol": [73],
        "Fn": [73, 74],
        "Mouse": [69, 70],
        "Magic": [70, 73],
    }
else:
    HELD = {}

for layer_name, positions in HELD.items():
    if layer_name in data["layers"]:
        layer = data["layers"][layer_name]
        for pos in positions:
            if pos < len(layer):
                layer[pos] = {"type": "held"}

with open(path, "w") as f:
    yaml.dump(data, f, default_flow_style=None, allow_unicode=True, sort_keys=False)
