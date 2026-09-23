#!/usr/bin/env bash
#
# install-local.sh — build this package from its local conda recipe and install
# it into the active conda environment. For local testing WITHOUT the uibcdf
# conda channel.
#
# This is a REPACKAGE build: it does NOT compile Qt WebEngine. The recipe
# downloads checksum-pinned official PySide and Qt sources automatically.
#
# It also depends on qt6-positioning-uibcdf, so build that first.
#
# Family build order (run each repo's devtools/conda-build/install-local.sh):
#     1. shiboken6-uibcdf
#     2. pyside6-essentials-uibcdf
#     3. qt6-positioning-uibcdf
#     4. qt6-webengine-uibcdf        <-- this repo
#     5. pyside6-addons-uibcdf
#
# Usage:
#     conda activate <target-env>
#     ./devtools/conda-build/install-local.sh
#
set -euo pipefail

PKG_NAME="qt6-webengine-uibcdf"
RECIPE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# uibcdf packages that must already be built + installed (in family order).
REQUIRED_PKGS=(qt6-positioning-uibcdf)

if ! conda build --version >/dev/null 2>&1; then
    echo "error: 'conda build' is not available. Install it with:" >&2
    echo "       mamba install -n base conda-build" >&2
    exit 1
fi
if [ -z "${CONDA_PREFIX:-}" ]; then
    echo "error: no active conda environment (activate the target env first)." >&2
    exit 1
fi

missing=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    conda list "$pkg" 2>/dev/null | grep -qE "^${pkg}\s" || missing+=("$pkg")
done
if [ "${#missing[@]}" -gt 0 ]; then
    echo "error: prerequisite package(s) not installed in this env: ${missing[*]}" >&2
    echo "       build qt6-positioning-uibcdf FIRST via its install-local.sh." >&2
    exit 1
fi

echo ">> [${PKG_NAME}] building from recipe: ${RECIPE_DIR}"
conda build "${RECIPE_DIR}" --override-channels -c local -c conda-forge

echo ">> [${PKG_NAME}] installing into active env: ${CONDA_PREFIX}"
mamba install -y --override-channels -c local -c conda-forge "${PKG_NAME}"

echo ">> [${PKG_NAME}] done."
