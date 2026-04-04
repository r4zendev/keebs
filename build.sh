#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
CONFIG_DIR="$REPO_ROOT/config"
WORKSPACE_BASE="${ZMK_WORKSPACE_BASE:-${XDG_DATA_HOME:-$HOME/.local/share}/zmk-workspaces}"

find_sdk() {
    if [[ -n "${ZEPHYR_SDK_INSTALL_DIR:-}" && -d "$ZEPHYR_SDK_INSTALL_DIR" ]]; then
        echo "$ZEPHYR_SDK_INSTALL_DIR"
        return
    fi
    local search_dirs=("$HOME/.local" "$HOME" "/opt" "/usr/local")
    for dir in "${search_dirs[@]}"; do
        for sdk in "$dir"/zephyr-sdk-*; do
            [[ -d "$sdk" ]] && echo "$sdk" && return
        done
    done
    echo "Error: Zephyr SDK not found. Install it or set ZEPHYR_SDK_INSTALL_DIR." >&2
    exit 1
}

SDK="$(find_sdk)"
export ZEPHYR_SDK_INSTALL_DIR="$SDK"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr

hosttools="$(find "$SDK/hosttools" -type d -name bin 2>/dev/null | head -1)"
[[ -n "$hosttools" ]] && export PATH="$hosttools:$PATH"

find_keyboard_dir() {
    if [[ -d "$CONFIG_DIR/keyboards/$1" ]]; then
        echo "$CONFIG_DIR/keyboards/$1"
    else
        echo "No keyboard config found for '$1'" >&2
        exit 1
    fi
}

# Resolve west manifest: keyboard-specific if exists, otherwise default
find_manifest() {
    if [[ -f "$KB_DIR/$KEYBOARD.west.yml" ]]; then
        echo "$KEYBOARD.west.yml"
    elif [[ -f "$CONFIG_DIR/default.west.yml" ]]; then
        echo "default.west.yml"
    else
        echo "No west manifest found for '$KEYBOARD'" >&2
        exit 1
    fi
}

# Resolve conf: keyboard-specific if exists, otherwise default
find_conf() {
    if [[ -f "$KB_DIR/$KEYBOARD.conf" ]]; then
        echo "$KB_DIR/$KEYBOARD.conf"
    elif [[ -f "$CONFIG_DIR/default.conf" ]]; then
        echo "$CONFIG_DIR/default.conf"
    fi
}

# Read board/shield from keyboard.yml or use conventions
get_board_shield() {
    local yml="$KB_DIR/keyboard.yml"
    if [[ -f "$yml" ]]; then
        python3 -c "
import yaml
with open('$yml') as f:
    d = yaml.safe_load(f)
board = d.get('board', 'nice_nano/nrf52840/zmk')
prefix = d.get('shield_prefix', '$KEYBOARD')
suffixes = d.get('split_suffixes', '_left _right')
print(f'{board}|{prefix}|{suffixes}')
"
    else
        echo "nice_nano/nrf52840/zmk|$KEYBOARD|_left _right"
    fi
}

usage() {
    echo "Usage: $0 <keyboard> [left|right|both|clean|setup|reset]"
    echo ""
    echo "Keyboards:"
    for d in "$CONFIG_DIR"/keyboards/*/; do
        [[ -d "$d" ]] && echo "  $(basename "$d")"
    done
    echo ""
    echo "Examples:"
    echo "  $0 cradio          # build both halves"
    echo "  $0 cradio left     # left hand only"
    echo "  $0 cradio setup    # init west workspace"
    echo "  $0 cradio clean    # remove build artifacts"
    echo "  $0 cradio reset    # build settings_reset firmware"
    echo "  CLEAN=1 $0 cradio  # full rebuild"
    exit 1
}

[[ $# -lt 1 ]] && usage

KEYBOARD="$1"
ACTION="${2:-both}"
WORKSPACE="$WORKSPACE_BASE/$KEYBOARD"
KB_DIR="$(find_keyboard_dir "$KEYBOARD")"

[[ ! -f "$KB_DIR/$KEYBOARD.keymap" ]] && echo "No $KEYBOARD.keymap found" && exit 1

setup_workspace() {
    echo "Setting up west workspace for $KEYBOARD at $WORKSPACE ..."
    rm -rf "$WORKSPACE/config"
    mkdir -p "$WORKSPACE/config"

    # Shared config
    for f in "$CONFIG_DIR"/base.keymap "$CONFIG_DIR"/includes "$CONFIG_DIR"/default.west.yml "$CONFIG_DIR"/default.conf; do
        [[ -e "$f" ]] && ln -sf "$f" "$WORKSPACE/config/"
    done

    # Keyboard-specific files
    for f in "$KB_DIR"/*; do
        [[ -e "$f" && "$(basename "$f")" != "shields" ]] && ln -sf "$f" "$WORKSPACE/config/"
    done

    # If no keyboard-specific conf, symlink default as {keyboard}.conf (ZMK expects this name)
    if [[ ! -f "$KB_DIR/$KEYBOARD.conf" && -f "$CONFIG_DIR/default.conf" ]]; then
        ln -sf "$CONFIG_DIR/default.conf" "$WORKSPACE/config/$KEYBOARD.conf"
    fi

    # Custom shield definitions (must be at config/boards/shields/ for ZMK)
    if [[ -d "$KB_DIR/shields" ]]; then
        mkdir -p "$WORKSPACE/config/boards"
        ln -sf "$KB_DIR/shields" "$WORKSPACE/config/boards/shields"
    fi

    local manifest
    manifest="$(find_manifest)"

    cd "$WORKSPACE"
    [[ -d .west ]] && rm -rf .west
    west init -l config/ --mf "$manifest"
    west update

    python3 -m venv "$WORKSPACE/.venv"
    "$WORKSPACE/.venv/bin/pip" install -q -r "$WORKSPACE/zephyr/scripts/requirements.txt"

    # Apply patches
    if [[ -d "$KB_DIR/shields" ]]; then
        for patch in "$KB_DIR"/shields/*/*.patch; do
            [[ -f "$patch" ]] || continue
            echo "Applying patch: $patch"
            cd "$WORKSPACE/zephyr" && git apply "$patch" 2>/dev/null && echo "  Applied." || echo "  Already applied or failed."
            cd "$WORKSPACE"
        done
    fi

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
[[ -d "$WORKSPACE/.venv" ]] && source "$WORKSPACE/.venv/bin/activate"
cd "$WORKSPACE"

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

IFS='|' read -r board shield_prefix suffixes <<< "$(get_board_shield)"
read -ra suffix_arr <<< "$suffixes"

case "$ACTION" in
    left|lh)
        if [[ -n "$shield_prefix" ]]; then
            build_entry "$board" "${shield_prefix}${suffix_arr[0]}"
        else
            build_entry "${board}${suffix_arr[0]}" ""
        fi ;;
    right|rh)
        if [[ -n "$shield_prefix" ]]; then
            build_entry "$board" "${shield_prefix}${suffix_arr[1]}"
        else
            build_entry "${board}${suffix_arr[1]}" ""
        fi ;;
    both)
        for sfx in "${suffix_arr[@]}"; do
            if [[ -n "$shield_prefix" ]]; then
                build_entry "$board" "${shield_prefix}${sfx}"
            else
                build_entry "${board}${sfx}" ""
            fi
        done
        ;;
    reset)
        west build -d "build/settings_reset" -s zmk/app -b "$board" -- -DSHIELD=settings_reset
        out="$REPO_ROOT/build/$KEYBOARD"
        mkdir -p "$out"
        cp "build/settings_reset/zephyr/zmk.uf2" "$out/settings_reset.uf2"
        echo "→ build/$KEYBOARD/settings_reset.uf2"
        echo "Flash this to BOTH halves to clear bonds."
        ;;
    clean)
        rm -rf build/ "$REPO_ROOT/build/$KEYBOARD"
        echo "Cleaned."
        ;;
    *) usage ;;
esac
