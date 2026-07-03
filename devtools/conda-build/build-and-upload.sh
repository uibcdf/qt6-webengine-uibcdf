#!/usr/bin/env bash
#
# build-and-upload.sh — build this package and upload it to the uibcdf conda
# channel (anaconda.org/uibcdf), so users can install it with:
#     mamba install -c uibcdf -c conda-forge <package>
#
# The upstream version stays FIXED (6.9.2). "Newer" is signalled by the recipe's
# build number (build: number in meta.yaml) — bump it before re-uploading.
#
# This is a REPACKAGE build. The two external inputs are REQUIRED — point at them:
#     export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX=/path/to/PySide6     # dir with Qt/
#     export QT6_WEBENGINE_UIBCDF_SOURCE_REPO=/path/to/qtwebengine   # dir with src/
# The recipe forwards these into the build (build.script_env). Diego's paths are
# used only as a fallback if they happen to exist on this machine.
#
# Run the family in order (each repo has its own build-and-upload.sh):
#     1. shiboken6-uibcdf
#     2. pyside6-essentials-uibcdf
#     3. qt6-positioning-uibcdf
#     4. qt6-webengine-uibcdf       <-- this repo
#     5. pyside6-addons-uibcdf
#
# Auth: run `anaconda login` first, or export ANACONDA_API_TOKEN.
#
# Usage:
#     conda activate <build-env>
#     ./devtools/conda-build/build-and-upload.sh
#
set -euo pipefail

PKG_NAME="qt6-webengine-uibcdf"
CHANNEL="uibcdf"
RECIPE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REQUIRED_PKGS=(qt6-positioning-uibcdf)

FALLBACK_PREFIX="/home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike/lib/python3.13/site-packages/PySide6"
FALLBACK_REPO="/home/diego/repos@others/qtwebengine"
SRC_PREFIX="${QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX:-$FALLBACK_PREFIX}"
SRC_REPO="${QT6_WEBENGINE_UIBCDF_SOURCE_REPO:-$FALLBACK_REPO}"

if ! conda build --version >/dev/null 2>&1; then
    echo "error: 'conda build' not available.  mamba install -n base conda-build" >&2
    exit 1
fi
if ! command -v anaconda >/dev/null 2>&1; then
    echo "error: 'anaconda' (anaconda-client) not available.  mamba install -n base anaconda-client" >&2
    exit 1
fi
if [ -z "${CONDA_PREFIX:-}" ]; then
    echo "error: no active conda environment (activate the build env first)." >&2
    exit 1
fi
if [ ! -d "${SRC_PREFIX}/Qt" ]; then
    echo "error: upstream PySide6 not found at: ${SRC_PREFIX}" >&2
    echo "       export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX=/path/to/PySide6   # must contain Qt/" >&2
    exit 1
fi
if [ ! -d "${SRC_REPO}/src" ]; then
    echo "error: qtwebengine source repo not found at: ${SRC_REPO}" >&2
    echo "       export QT6_WEBENGINE_UIBCDF_SOURCE_REPO=/path/to/qtwebengine   # must contain src/" >&2
    exit 1
fi
export QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX="${SRC_PREFIX}"
export QT6_WEBENGINE_UIBCDF_SOURCE_REPO="${SRC_REPO}"

# Resolve the output artifact path (does not build) + the local conda-bld dir.
OUT="$(conda build "${RECIPE_DIR}" -c local -c conda-forge --output 2>/dev/null | grep -E '\.(conda|tar\.bz2)$' | tail -1)"
if [ -z "${OUT}" ]; then
    echo "error: could not resolve the build output path (conda build --output)." >&2
    exit 1
fi
CB_DIR="$(dirname "${OUT}")"

# Prerequisite uibcdf packages must already be built into the local channel.
for dep in "${REQUIRED_PKGS[@]}"; do
    ls "${CB_DIR}/${dep}-6.9.2-"*.conda >/dev/null 2>&1 || {
        echo "error: prerequisite '${dep}' not found in local conda-bld (${CB_DIR})." >&2
        echo "       build qt6-positioning-uibcdf FIRST via its build-and-upload.sh." >&2
        exit 1
    }
done

echo ">> [${PKG_NAME}] building ..."
echo ">>   source PySide6 : ${SRC_PREFIX}"
echo ">>   source Qt repo : ${SRC_REPO}"
conda build "${RECIPE_DIR}" -c local -c conda-forge

ANACONDA=(anaconda)
[ -n "${ANACONDA_API_TOKEN:-}" ] && ANACONDA+=(-t "${ANACONDA_API_TOKEN}")
echo ">> [${PKG_NAME}] uploading ${OUT} to channel '${CHANNEL}' ..."
"${ANACONDA[@]}" upload -u "${CHANNEL}" "${OUT}"

echo ">> [${PKG_NAME}] done. Install with: mamba install -c ${CHANNEL} -c conda-forge ${PKG_NAME}"
