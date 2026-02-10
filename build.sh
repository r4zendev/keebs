#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$REPO_ROOT/config"
SDK=~/.local/zephyr-sdk-0.17.0
WORKSPACE_BASE=~/.local/share/zmk-workspaces

export ZEPHYR_SDK_INSTALL_DIR="$SDK"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export PATH="$SDK/hosttools/sysroots/x86_64-pokysdk-linux/usr/bin:$PATH"

usage() {
    echo "Usage: $0 <keyboard> [left|right|both|clean|setup]"
    echo ""
    echo "Keyboards are defined by build entries in config/build.yaml."
    echo "Use keyboard name matching the keymap file (e.g. glove80, sweep)."
    echo ""
    echo "Examples:"
    echo "  $0 glove80          # build both halves"
    echo "  $0 glove80 left     # left hand only"
    echo "  $0 glove80 setup    # init west workspace"
    echo "  $0 glove80 clean    # remove build artifacts"
    echo "  CLEAN=1 $0 glove80  # full rebuild"
    exit 1
}

[[ $# -lt 1 ]] && usage

KEYBOARD="$1"
ACTION="${2:-both}"
WORKSPACE="$WORKSPACE_BASE/$KEYBOARD"

# Map keyboard names to ZMK shield/config filenames
declare -A SHIELD_MAP=([sweep]=cradio)
CONFIG_NAME="${SHIELD_MAP[$KEYBOARD]:-$KEYBOARD}"

[[ ! -f "$CONFIG_DIR/$CONFIG_NAME.keymap" ]] && echo "No $CONFIG_NAME.keymap in config/" && exit 1

setup_workspace() {
    echo "Setting up west workspace for $KEYBOARD at $WORKSPACE ..."
    mkdir -p "$WORKSPACE/config"

    for f in "$CONFIG_DIR"/*; do
        ln -sf "$f" "$WORKSPACE/config/"
    done

    # Use board-specific west.yml if available (e.g. glove80.west.yml for moergo fork)
    if [[ -f "$CONFIG_DIR/$KEYBOARD.west.yml" ]]; then
        cp "$CONFIG_DIR/$KEYBOARD.west.yml" "$WORKSPACE/config/west.yml"
        echo "Using $KEYBOARD.west.yml"
    fi

    cd "$WORKSPACE"
    [[ -d .west ]] && rm -rf .west
    west init -l config/
    west update
    pip install -q -r "$WORKSPACE/zephyr/scripts/requirements.txt"
    echo "Done. Workspace ready at $WORKSPACE"
}

if [[ "$ACTION" == "setup" ]]; then
    setup_workspace
    exit 0
fi

if [[ ! -d "$WORKSPACE/.west" ]]; then
    echo "Workspace not initialized. Run: $0 $KEYBOARD setup"
    exit 1
fi

export ZEPHYR_BASE="$WORKSPACE/zephyr"
export CMAKE_PREFIX_PATH="$WORKSPACE/zephyr/share/zephyr-package/cmake"
cd "$WORKSPACE"

# Parse build.yaml entries for this keyboard.
# Each entry has board: and optionally shield:. We match entries by:
#   - board name contains the keyboard name (e.g. glove80_lh matches glove80)
#   - OR shield name contains the keyboard name mapped through aliases
# Returns lines like "board=glove80_lh shield=" or "board=nice_nano_v2 shield=cradio_left"
get_build_entries() {
    local build_yaml="$WORKSPACE/config/$KEYBOARD.build.yaml"
    if [[ ! -f "$build_yaml" ]]; then
        echo "No $KEYBOARD.build.yaml in config/"
        exit 1
    fi
    python3 -c "
import yaml, sys
with open('$build_yaml') as f:
    data = yaml.safe_load(f)

# Map keyboard names to shield prefixes
SHIELD_MAP = {'sweep': 'cradio'}

keyboard = '$KEYBOARD'
shield_prefix = SHIELD_MAP.get(keyboard, keyboard)

for entry in data.get('include', []):
    board = entry.get('board', '')
    shield = entry.get('shield', '')
    if shield:
        if shield.startswith(shield_prefix):
            print(f'{board} {shield}')
    else:
        if keyboard in board:
            print(f'{board} ')
"
}

build_entry() {
    local board=$1 shield=$2
    local label="${shield:-$board}"

    if [[ "${CLEAN:-}" == "1" ]]; then
        rm -rf "build/$label"
    fi

    local cmake_args="-DZMK_CONFIG=$WORKSPACE/config"
    if [[ -n "$shield" ]]; then
        cmake_args="$cmake_args -DSHIELD=$shield"
    fi
    west build -d "build/$label" -s zmk/app -b "$board" -- $cmake_args

    local out="$REPO_ROOT/build/$KEYBOARD"
    mkdir -p "$out"
    cp "build/$label/zephyr/zmk.uf2" "$out/${label}.uf2"
    echo "→ build/$KEYBOARD/${label}.uf2"
}

if [[ "$ACTION" == "clean" ]]; then
    rm -rf build/ "$REPO_ROOT/build/$KEYBOARD"
    echo "Cleaned."
    exit 0
fi

mapfile -t entries < <(get_build_entries)
if [[ ${#entries[@]} -eq 0 ]]; then
    echo "No build entries found for '$KEYBOARD' in build.yaml"
    exit 1
fi

lh_board="" lh_shield="" rh_board="" rh_shield=""
for entry in "${entries[@]}"; do
    read -r board shield <<< "$entry"
    if [[ "$board" == *_lh || "$shield" == *_left ]]; then
        lh_board="$board"; lh_shield="$shield"
    elif [[ "$board" == *_rh || "$shield" == *_right ]]; then
        rh_board="$board"; rh_shield="$shield"
    fi
done

case "$ACTION" in
    left|lh)
        [[ -n "$lh_board" ]] && build_entry "$lh_board" "$lh_shield" || echo "No left side found" ;;
    right|rh)
        [[ -n "$rh_board" ]] && build_entry "$rh_board" "$rh_shield" || echo "No right side found" ;;
    both)
        [[ -n "$lh_board" ]] && build_entry "$lh_board" "$lh_shield"
        [[ -n "$rh_board" ]] && build_entry "$rh_board" "$rh_shield"
        ;;
    *) usage ;;
esac
