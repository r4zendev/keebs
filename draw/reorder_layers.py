"""Reorder layers in a keymap-drawer YAML file."""
import sys
import yaml

path, *order = sys.argv[1:]
with open(path) as f:
    data = yaml.safe_load(f)

layers = data["layers"]
data["layers"] = {name: layers[name] for name in order if name in layers}

with open(path, "w") as f:
    yaml.dump(data, f, default_flow_style=None, allow_unicode=True, sort_keys=False)
