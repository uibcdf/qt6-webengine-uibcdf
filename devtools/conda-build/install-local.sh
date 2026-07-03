#!/usr/bin/env bash
#
# install-local.sh — build this package from its local conda recipe and install
# it into the active conda environment. For local testing WITHOUT the uibcdf
# conda channel.
#
# This is a REPACKAGE build: it does NOT compile Qt WebEngine. It copies files
# from a prebuilt upstream PySide6 install plus the matching Qt source repo (for
# headers). Those two inputs are REQUIRED and machine-specific — point at them:
#     export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX=/path/to/PySide6     # dir with Qt/ inside
#     export QT6_WEBENGINE_UIBCDF_SOURCE_REPO=/path/to/qtwebengine   # dir with src/ inside
# The recipe forwards these into the build (build.script_env). Diego's paths are
# used only as a fallback if they happen to exist on this machine.
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

# Fallback paths (Diego's machine). Do NOT rely on these elsewhere — set the vars.
FALLBACK_PREFIX="/home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike/lib/python3.13/site-packages/PySide6"
FALLBACK_REPO="/home/diego/repos@others/qtwebengine"
SRC_PREFIX="${QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX:-$FALLBACK_PREFIX}"
SRC_REPO="${QT6_WEBENGINE_UIBCDF_SOURCE_REPO:-$FALLBACK_REPO}"

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

if [ ! -d "${SRC_PREFIX}/Qt" ]; then
    echo "error: upstream PySide6 not found at: ${SRC_PREFIX}" >&2
    echo "       set it explicitly (this machine is not Diego's):" >&2
    echo "         export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX=/path/to/PySide6   # must contain Qt/" >&2
    exit 1
fi
if [ ! -d "${SRC_REPO}/src" ]; then
    echo "error: qtwebengine source repo not found at: ${SRC_REPO}" >&2
    echo "         export QT6_WEBENGINE_UIBCDF_SOURCE_REPO=/path/to/qtwebengine   # must contain src/" >&2
    exit 1
fi

# Export so conda build forwards them into the sandbox (recipe build.script_env).
export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX="${SRC_PREFIX}"
export QT6_WEBENGINE_UIBCDF_SOURCE_REPO="${SRC_REPO}"

echo ">> [${PKG_NAME}] building from recipe: ${RECIPE_DIR}"
echo ">>   source PySide6 : ${SRC_PREFIX}"
echo ">>   source Qt repo : ${SRC_REPO}"
conda build "${RECIPE_DIR}" -c local -c conda-forge

echo ">> [${PKG_NAME}] installing into active env: ${CONDA_PREFIX}"
mamba install -y -c local -c conda-forge "${PKG_NAME}"

echo ">> [${PKG_NAME}] done."
