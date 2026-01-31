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

path, *order = sys.argv[1:]
with open(path) as f:
    data = yaml.safe_load(f)

layers = data["layers"]
if "Vestnik" in layers:
    layers["Vestnik"] = [VESTNIK_MAP.get(k, k) if isinstance(k, str) else k for k in layers["Vestnik"]]

data["layers"] = {name: layers[name] for name in order if name in layers}

with open(path, "w") as f:
    yaml.dump(data, f, default_flow_style=None, allow_unicode=True, sort_keys=False)
