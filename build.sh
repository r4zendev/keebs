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
    echo "Usage: $0 <keyboard> [left|right|both|clean|setup|reset]"
    echo ""
    echo "Keyboards: glove80, cradio, splitkb_aurora_sweep"
    echo ""
    echo "Examples:"
    echo "  $0 glove80          # build both halves"
    echo "  $0 glove80 left     # left hand only"
    echo "  $0 glove80 setup    # init west workspace"
    echo "  $0 glove80 clean    # remove build artifacts"
    echo "  $0 glove80 reset    # build settings_reset firmware"
    echo "  CLEAN=1 $0 glove80  # full rebuild"
    exit 1
}

[[ $# -lt 1 ]] && usage

KEYBOARD="$1"
ACTION="${2:-both}"
WORKSPACE="$WORKSPACE_BASE/$KEYBOARD"

[[ ! -f "$CONFIG_DIR/$KEYBOARD.keymap" ]] && echo "No $KEYBOARD.keymap in config/" && exit 1

setup_workspace() {
    echo "Setting up west workspace for $KEYBOARD at $WORKSPACE ..."
    mkdir -p "$WORKSPACE/config"

    for f in "$CONFIG_DIR"/*; do
        ln -sf "$f" "$WORKSPACE/config/"
    done

    if [[ ! -f "$CONFIG_DIR/$KEYBOARD.west.yml" ]]; then
        echo "No $KEYBOARD.west.yml in config/"
        exit 1
    fi
    cd "$WORKSPACE"
    [[ -d .west ]] && rm -rf .west
    west init -l config/ --mf "$KEYBOARD.west.yml"
    west update
    pip install -q -r "$WORKSPACE/zephyr/scripts/requirements.txt"

    # Apply patches if any exist for this keyboard's shield
    for patch in "$CONFIG_DIR"/boards/shields/*/?.patch "$CONFIG_DIR"/boards/shields/*/*.patch; do
        [[ -f "$patch" ]] || continue
        echo "Applying patch: $patch"
        cd "$WORKSPACE/zephyr" && git apply "$patch" 2>/dev/null && echo "  Applied." || echo "  Already applied or failed."
        cd "$WORKSPACE"
    done

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

keyboard = '$KEYBOARD'
for entry in data.get('include', []):
    board = entry.get('board', '')
    shield = entry.get('shield', '')
    if shield:
        if keyboard in shield:
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
    echo "No build entries found for '$KEYBOARD'"
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
    reset)
        board="${lh_board:-${rh_board}}"
        [[ -z "$board" ]] && echo "No board found" && exit 1
        west build -d "build/settings_reset" -s zmk/app -b "$board" -- -DSHIELD=settings_reset
        out="$REPO_ROOT/build/$KEYBOARD"
        mkdir -p "$out"
        cp "build/settings_reset/zephyr/zmk.uf2" "$out/settings_reset.uf2"
        echo "→ build/$KEYBOARD/settings_reset.uf2"
        echo "Flash this to BOTH halves to clear bonds."
        ;;
    *) usage ;;
esac
