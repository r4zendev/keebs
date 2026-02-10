#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SDK=~/.local/zephyr-sdk-0.17.0
WORKSPACE_BASE=~/.local/share/zmk-workspaces

export ZEPHYR_SDK_INSTALL_DIR="$SDK"
export ZEPHYR_TOOLCHAIN_VARIANT=zephyr
export PATH="$SDK/hosttools/sysroots/x86_64-pokysdk-linux/usr/bin:$PATH"

usage() {
    echo "Usage: $0 <keyboard> [left|right|both|clean|setup]"
    echo ""
    echo "Keyboards:"
    for d in "$REPO_ROOT"/*/west.yml; do
        [[ -f "$d" ]] && basename "$(dirname "$d")"
    done
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
KEEB_DIR="$REPO_ROOT/$KEYBOARD"
WORKSPACE="$WORKSPACE_BASE/$KEYBOARD"

[[ ! -f "$KEEB_DIR/west.yml" ]] && echo "No west.yml in $KEYBOARD/" && exit 1

setup_workspace() {
    echo "Setting up west workspace for $KEYBOARD at $WORKSPACE ..."
    mkdir -p "$WORKSPACE/config"

    # Symlink all config files
    for f in "$KEEB_DIR"/*; do
        [[ "$(basename "$f")" == "west.yml" ]] && continue
        ln -sf "$f" "$WORKSPACE/config/"
    done

    # west.yml needs self.path: config
    sed 's/path: [a-zA-Z0-9_-]*/path: config/' "$KEEB_DIR/west.yml" > "$WORKSPACE/config/west.yml"

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

# Read board names from build.yaml
get_boards() {
    grep 'board:' "$WORKSPACE/config/build.yaml" | sed 's/.*board: *//'
}

build_side() {
    local label=$1 board=$2
    if [[ "${CLEAN:-}" == "1" ]]; then
        rm -rf "build/$label"
    fi
    west build -d "build/$label" -s zmk/app -b "$board" -- -DZMK_CONFIG="$WORKSPACE/config"

    # Copy UF2 to repo
    local out="$REPO_ROOT/build/$KEYBOARD"
    mkdir -p "$out"
    cp "build/$label/zephyr/zmk.uf2" "$out/${board}.uf2"
    echo "→ build/$KEYBOARD/${board}.uf2"
}

boards=($(get_boards))
lh="" rh=""
for b in "${boards[@]}"; do
    [[ "$b" == *_lh ]] && lh="$b"
    [[ "$b" == *_rh ]] && rh="$b"
done

# Single-board keyboards (no lh/rh split)
if [[ -z "$lh" && -z "$rh" && ${#boards[@]} -eq 1 ]]; then
    case "$ACTION" in
        both|left|right) build_side "${boards[0]}" "${boards[0]}" ;;
        clean) rm -rf build/ "$REPO_ROOT/build/$KEYBOARD"; echo "Cleaned." ;;
        *) usage ;;
    esac
    exit 0
fi

case "$ACTION" in
    left|lh)  [[ -n "$lh" ]] && build_side left "$lh" || echo "No left board found" ;;
    right|rh) [[ -n "$rh" ]] && build_side right "$rh" || echo "No right board found" ;;
    both)
        [[ -n "$lh" ]] && build_side left "$lh"
        [[ -n "$rh" ]] && build_side right "$rh"
        ;;
    clean) rm -rf build/ "$REPO_ROOT/build/$KEYBOARD"; echo "Cleaned." ;;
    *) usage ;;
esac
