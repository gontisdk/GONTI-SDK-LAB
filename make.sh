#!/bin/bash
set -e

# --- Configuration ---
SDK_ROOT="../GONTI-SDK/GONTI-SDK"
SDK_ROOT_BIN="../GONTI-SDK/Build/bin/linux/GONTI-SDK"
MAK_SRC_DIR="Build/Scripts/linux"
OUT_TESTBED="Build/bin/Testbed"
OUT_TESTS="Build/bin/Tests"
MAK_FNAME_S="Makefile"
MAK_FNAME_E="linux.mak"
LIB_DIR="Lib/GONTI-SDK"
INCLUDE_DEST="./Include/GONTI-SDK"
LIB_EXTENSION=".so"

# Modules that produce a compiled library (.so) - used for lib copying.
# Format: "ModuleName:RelativeGroupPath" (path relative to SDK_ROOT / SDK_ROOT_BIN)
LIB_MODULES=(
    "GONTI.CORE:GONTI-CORE"
    "GONTI.CONTAINERS:GONTI-CORE"
    "GONTI.MATH:GONTI-CORE"
    "GONTI.STRING:GONTI-CORE"
    "GONTI.FILESYSTEM:GONTI-CORE"
    "GONTI.RENDER:GONTI-RENDER"
    "GONTI.RENDER.CORE.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.DEBUGGER.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.SHADERS.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.UTILITIES.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RUNTIME:GONTI-RUNTIME"
)

# All modules that expose headers, including header-only ones (GONTI.RENDER.COMMON,
# GONTI.RENDER.COMMON.VK) which have no compiled library but must still be collected.
# Format: "ModuleName:RelativeGroupPath"
HEADER_MODULES=(
    "GONTI.CORE:GONTI-CORE"
    "GONTI.CONTAINERS:GONTI-CORE"
    "GONTI.MATH:GONTI-CORE"
    "GONTI.STRING:GONTI-CORE"
    "GONTI.FILESYSTEM:GONTI-CORE"
    "GONTI.RENDER:GONTI-RENDER"
    "GONTI.RENDER.COMMON:GONTI-RENDER"
    "GONTI.RENDER.COMMON.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.CORE.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.DEBUGGER.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.SHADERS.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.UTILITIES.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RENDER.VK:GONTI-RENDER/GONTI-RENDER-VK"
    "GONTI.RUNTIME:GONTI-RUNTIME"
)

# --- Helper Functions ---

# Ensures a directory exists
prepare_dir() {
    local dir=$1
    mkdir -p "$dir"
}

# Copies shared libraries (.so)
copy_engine_libs() {
    local dest=$1
    prepare_dir "$dest"

    echo "Copying engine libraries to $dest..."
    for entry in "${LIB_MODULES[@]}"; do
        local module="${entry%%:*}"
        local group="${entry##*:}"
        local lib_path="$SDK_ROOT_BIN/$group/$module$LIB_EXTENSION"
        if [ -f "$lib_path" ]; then
            cp -f "$lib_path" "$dest/"
        else
            echo "[WARN] Library $lib_path not found!"
        fi
    done
}

# Collects header files (.h and .inl)
collect_headers() {
    echo "Collecting headers into $INCLUDE_DEST..."
    prepare_dir "$INCLUDE_DEST"

    for entry in "${HEADER_MODULES[@]}"; do
        local module="${entry%%:*}"
        local group="${entry##*:}"
        local src_path="$SDK_ROOT/$group/$module/Source"
        local dest_path="$INCLUDE_DEST/$group/$module/Source"

        if [ -d "$src_path" ]; then
            echo "  -> Processing module: $module"
            prepare_dir "$dest_path"

            # Using a more direct find/cp approach to avoid shell suspension
            # This version is less likely to hang in VS Code terminals
            find "$src_path" -type f \( -name "*.h" -o -name "*.inl" \) | while read -r file; do
                local rel_path="${file#$src_path/}"
                local target_file="$dest_path/$rel_path"
                mkdir -p "$(dirname "$target_file")"
                cp -f "$file" "$target_file"
            done
        else
            echo "  [WARN] Missing source headers at $src_path"
        fi
    done
}

# --- Pre-run Validation ---
if [ ! -d "$SDK_ROOT_BIN" ]; then
    echo "Error: SDK Binary directory ($SDK_ROOT_BIN) missing. Aborting."
    exit 1
fi

# --- Execution ---

# 1. Prepare Environment
collect_headers
copy_engine_libs "$LIB_DIR"

# 2. Build Process
echo "Building GONTI-SDK-LAB components..."

# Use -j for faster compilation if your CPU allows it
make -f "$MAK_SRC_DIR/$MAK_FNAME_S.Testbed.$MAK_FNAME_E" all
make -f "$MAK_SRC_DIR/$MAK_FNAME_S.Tests.$MAK_FNAME_E" all

echo "---------------------------------------"
echo "All assemblies built successfully."

# --- Launching ---

if [ -d "$OUT_TESTBED" ]; then
    echo "Launching Testbed..."
    # Using absolute path or subshell to avoid 'cd' side effects
    (cd "$OUT_TESTBED" && ./Testbed)
else
    echo "[ERROR] Testbed target directory missing: $OUT_TESTBED"
fi