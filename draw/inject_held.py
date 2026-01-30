#!/usr/bin/env python3
"""Inject {type: held} markers into keymap-drawer YAML for layer activator keys."""

import json
import re
import sys

# Map: layer_name -> key position index (0-based) that activates it
HELD_KEYS = {
    "Symbol": 41,
    "Nav": 36,
    "Function": 38,
    "Mouse": 39,
}

lines = sys.stdin.readlines()
current_layer = None
key_index = -1
in_layer_list = False

i = 0
while i < len(lines):
    line = lines[i]

    # Detect layer header like "  Symbol:" or "  Nav:"
    m = re.match(r'^  (\w+):$', line)
    if m and m.group(1) in HELD_KEYS:
        current_layer = m.group(1)
        key_index = -1
        in_layer_list = False
        sys.stdout.write(line)
        i += 1
        continue

    # Reset layer tracking on new layer or non-list content
    if re.match(r'^  \w', line) and not line.startswith('  -'):
        current_layer = None

    # Count list items in current layer
    if current_layer and line.startswith('  - '):
        key_index += 1
        if key_index == HELD_KEYS[current_layer]:
            sys.stdout.write('  - {type: held}\n')
            i += 1
            continue

    sys.stdout.write(line)
    i += 1
