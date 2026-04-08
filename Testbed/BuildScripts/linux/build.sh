#!/bin/bash
# Make script for testbed (Linux version)

set -e

# 1. Ustalamy bezwzględną ścieżkę do głównego folderu projektu
# Zakładając, że skrypt jest w Project/Scripts/Linux/MakeTestbed.sh
scriptDir="$(cd "$(dirname "$0")" && pwd)"
workspaceFolder="$(cd "$scriptDir/../../.." && pwd)"
sourceDir="$(cd "$scriptDir/../../Source" && pwd)"
buildDir="$(cd "$scriptDir/../.." && pwd)/Build"

# 2. Zbieramy pliki .c używając tablicy (bezpieczne dla spacji)
cFilenames=()
while IFS= read -r -d '' file; do
    cFilenames+=("$file")
done < <(find "$sourceDir" -name "*.c" -print0)

echo "==============================================="
echo "=== START LIST OF: Files passed to compiler ==="
echo "==============================================="
printf '%s\n' "${cFilenames[@]}"
echo "============================================="

# 3. Utwórz katalog build jeśli nie istnieje
if [ ! -d "$buildDir" ]; then
    mkdir -p "$buildDir"
fi

# Przechodzimy do buildu
cd "$buildDir"

# 4. Definiujemy ścieżki (używamy cudzysłowów!)
vcpkgIncludeDir="$VULKAN_SDK/include"
vcpkgLibDir="$VULKAN_SDK/lib"
workspaceFoldersInclude="$workspaceFolder/GONTI-SDK"

GONTI_CORE_Libs_Dir="$workspaceFolder/GONTI-SDK/Build/bin/linux/GONTI/GONTI-ENGINE/GONTI.CORE"
GONTI_RENDER_VK_Libs_Dir="$workspaceFolder/GONTI-SDK/Build/bin/linux/GONTI/GONTI-ENGINE/GONTI.RENDER.VK"
GONTI_RENDER_Libs_Dir="$workspaceFolder/GONTI-SDK/Build/bin/linux/GONTI/GONTI-ENGINE/GONTI.RENDER"
GONTI_RUNTIME_Libs_Dir="$workspaceFolder/GONTI-SDK/Build/bin/linux/GONTI/GONTI-ENGINE/GONTI.RUNTIME"

# 5. Flagi kompilacji jako tablice (kluczowe dla obsługi spacji)
assembly="testbed"
compilerFlags=("-g")
defines=("-D_DEBUG" "-DKIMPORT")

includeFlags=(
    "-I$workspaceFoldersInclude"
    "-I$vcpkgIncludeDir"
)

linkerFlags=(
    "./GONTI.CORE.so"
    "./GONTI.RENDER.so"
    "./GONTI.RENDER.VK.so"
    "./GONTI.RUNTIME.so"
    "-L$vcpkgLibDir"
    "-lvulkan"
    "-lX11"
    "-lX11-xcb"
    "-lxcb"
    "-ldl"
    "-lpthread"
)

# 6. Kopiowanie bibliotek .so
echo "Copying libraries..."
cp "$GONTI_CORE_Libs_Dir/GONTI.CORE.so" "./"
cp "$GONTI_RENDER_VK_Libs_Dir/GONTI.RENDER.VK.so" "./"
cp "$GONTI_RENDER_Libs_Dir/GONTI.RENDER.so" "./"
cp "$GONTI_RUNTIME_Libs_Dir/GONTI.RUNTIME.so" "./"

echo "Building $assembly..."

# 7. Kompilacja - Zauważ cudzysłowy wokół tablic: "${tablica[@]}"
clang "${cFilenames[@]}" "${compilerFlags[@]}" -o "$assembly" "${defines[@]}" "${includeFlags[@]}" "${linkerFlags[@]}"

echo "Done."

# 8. Uruchomienie (opcjonalnie)
if [ -f "$scriptDir/run.sh" ]; then
    bash "$scriptDir/run.sh" "$assembly"
fi