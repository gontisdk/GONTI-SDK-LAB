#!/bin/bash
set -e

# --- Configuration ---
SDK_ROOT="../GONTI-SDK/GONTI/GONTI-ENGINE"
SDK_ROOT_BIN="../GONTI-SDK/Build/bin/linux/GONTI/GONTI-ENGINE"
MAK_SRC_DIR="Build/Scripts/linux"
OUT_TESTBED="Build/bin/Testbed"
OUT_TESTS="Build/bin/Tests"
MAK_FNAME_S="Makefile"
MAK_FNAME_E="linux.mak"
LIB_DIR="Lib/GONTI/GONTI-ENGINE"
INCLUDE_DEST="./Include/GONTI/GONTI-ENGINE"

# Shared module list for libraries and headers
MODULES=("GONTI.CORE" "GONTI.RENDER" "GONTI.RENDER.VK" "GONTI.RUNTIME")

# --- Helper Functions ---

# Ensures a directory exists and is empty if requested
prepare_dir() {
    local dir=$1
    if [ -d "$dir" ]; then
        # Optional: Uncomment to wipe existing files before re-copying
        # rm -rf "$dir"/*
        mkdir -p "$dir"
    else
        mkdir -p "$dir"
    fi
}

# Copies shared libraries (.so)
copy_engine_libs() {
    local dest=$1
    prepare_dir "$dest"
    
    echo "Copying engine libraries to $dest..."
    for module in "${MODULES[@]}"; do
        local lib_path="$SDK_ROOT_BIN/$module.so"
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

    for module in "${MODULES[@]}"; do
        local src_path="$SDK_ROOT/$module/Source"
        local dest_path="$INCLUDE_DEST/$module/Source"

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