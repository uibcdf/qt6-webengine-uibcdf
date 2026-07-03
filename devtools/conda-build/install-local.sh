#!/usr/bin/env bash
#
# install-local.sh — build this package from its local conda recipe and install
# it into the active conda environment. For local testing WITHOUT waiting for the
# uibcdf conda channel.
#
# This is a REPACKAGE build: it does NOT compile Qt WebEngine. It copies files from
# a prebuilt upstream PySide6 install plus the matching Qt source repo (for headers),
# according to manifests/qt6_webengine.files.txt. You therefore need both inputs
# available. Defaults point at Diego's paths; override with:
#     export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX=/path/to/PySide6   # has Qt/ inside
#     export QT6_WEBENGINE_UIBCDF_SOURCE_REPO=/path/to/qtwebengine
# (If you override these, also add them to the recipe's build.script_env so conda
#  build forwards them into the build sandbox.)
#
# Also depends on qt6-positioning-uibcdf, so build that first.
#
# Build order for the whole Qt-for-Python family — run each repo's
# devtools/conda-build/install-local.sh in this order:
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

SRC_PREFIX="${QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX:-/home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike/lib/python3.13/site-packages/PySide6}"
SRC_REPO="${QT6_WEBENGINE_UIBCDF_SOURCE_REPO:-/home/diego/repos@others/qtwebengine}"

if ! conda build --version >/dev/null 2>&1; then
    echo "error: 'conda build' is not available." >&2
    echo "       install it with:  mamba install -n base conda-build" >&2
    exit 1
fi

if [ -z "${CONDA_PREFIX:-}" ]; then
    echo "error: no active conda environment (CONDA_PREFIX is empty)." >&2
    echo "       activate the target env first:  conda activate <env>" >&2
    exit 1
fi

if [ ! -d "${SRC_PREFIX}/Qt" ]; then
    echo "error: upstream PySide6 not found at: ${SRC_PREFIX}" >&2
    echo "       set QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX to a PySide6 dir (with Qt/ inside)." >&2
    exit 1
fi
if [ ! -d "${SRC_REPO}/src" ]; then
    echo "error: Qt source repo not found at: ${SRC_REPO}" >&2
    echo "       set QT6_WEBENGINE_UIBCDF_SOURCE_REPO to the qtwebengine source checkout." >&2
    exit 1
fi

echo ">> [${PKG_NAME}] building from recipe: ${RECIPE_DIR}"
echo ">>   source PySide6 : ${SRC_PREFIX}"
echo ">>   source Qt repo : ${SRC_REPO}"
conda build "${RECIPE_DIR}" -c local -c conda-forge

echo ">> [${PKG_NAME}] installing into active env: ${CONDA_PREFIX}"
mamba install -y -c local -c conda-forge "${PKG_NAME}"

echo ">> [${PKG_NAME}] done."
