#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "${RECIPE_DIR}/../.." && pwd)"
SOURCE_QT_PREFIX="${QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX:-/home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike/lib/python3.13/site-packages/PySide6}"
SOURCE_QT_REPO="${QT6_WEBENGINE_UIBCDF_SOURCE_REPO:-/home/diego/repos@others/qtwebengine}"
MANIFEST="${QT6_WEBENGINE_UIBCDF_MANIFEST:-${REPO_ROOT}/manifests/qt6_webengine.files.txt}"

if [ ! -d "$SOURCE_QT_PREFIX/Qt" ]; then
    echo "Missing source Qt runtime under: $SOURCE_QT_PREFIX" >&2
    exit 1
fi

if [ ! -f "$MANIFEST" ]; then
    echo "Missing manifest: $MANIFEST" >&2
    exit 1
fi

if [ ! -d "$SOURCE_QT_REPO/src/core/api" ]; then
    echo "Missing source Qt WebEngine repo under: $SOURCE_QT_REPO" >&2
    exit 1
fi

while IFS= read -r relpath; do
    [ -n "$relpath" ] || continue
    src="$SOURCE_QT_PREFIX/$relpath"
    dst="$PREFIX/${relpath#Qt/}"
    if [ ! -e "$src" ]; then
        echo "Missing manifest entry in source environment: $src" >&2
        exit 1
    fi
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
done < "$MANIFEST"

copy_headers() {
    local src_dir="$1"
    local dst_dir="$2"
    mkdir -p "$dst_dir"
    find "$src_dir" -maxdepth 1 -type f -name '*.h' -exec cp -a {} "$dst_dir/" \;
}

create_module_header() {
    local module_name="$1"
    local dst_dir="$2"
    local umbrella="$dst_dir/$module_name"
    local guard
    guard="$(printf '%s' "$module_name" | tr '[:lower:]' '[:upper:]')_MODULE_H"
    {
        printf '#ifndef %s\n' "$guard"
        printf '#define %s\n\n' "$guard"
        for header in "$dst_dir"/*.h; do
            [ -f "$header" ] || continue
            local base
            base="$(basename "$header")"
            case "$base" in
                *global_p.h|*_p.h)
                    continue
                    ;;
                *)
                    printf '#include <%s/%s>\n' "$module_name" "$base"
                    ;;
            esac
        done
        printf '\n#endif\n'
    } > "$umbrella"
}


create_class_alias_headers() {
    local module_name="$1"
    local dst_dir="$2"
    local header
    for header in "$dst_dir"/*.h; do
        [ -f "$header" ] || continue
        local base
        base="$(basename "$header")"
        case "$base" in
            *global.h|*global_p.h|*_p.h|qtwebengine*-config.h)
                continue
                ;;
        esac
        while IFS= read -r alias; do
            [ -n "$alias" ] || continue
            cat > "$dst_dir/$alias" <<HDR
#include <${module_name}/${base}>
HDR
        done < <(rg -o '^(class|struct)\s+(Q[A-Za-z0-9_]+)' -r '$2' "$header" | sort -u)
    done
}

copy_headers "$SOURCE_QT_REPO/src/core/api" "$PREFIX/include/qt6/QtWebEngineCore"
copy_headers "$SOURCE_QT_REPO/src/webenginequick/api" "$PREFIX/include/qt6/QtWebEngineQuick"
copy_headers "$SOURCE_QT_REPO/src/webenginewidgets/api" "$PREFIX/include/qt6/QtWebEngineWidgets"

create_module_header "QtWebEngineCore" "$PREFIX/include/qt6/QtWebEngineCore"
create_class_alias_headers "QtWebEngineCore" "$PREFIX/include/qt6/QtWebEngineCore"
create_module_header "QtWebEngineQuick" "$PREFIX/include/qt6/QtWebEngineQuick"
create_class_alias_headers "QtWebEngineQuick" "$PREFIX/include/qt6/QtWebEngineQuick"
create_module_header "QtWebEngineWidgets" "$PREFIX/include/qt6/QtWebEngineWidgets"
create_class_alias_headers "QtWebEngineWidgets" "$PREFIX/include/qt6/QtWebEngineWidgets"

cat > "$PREFIX/include/qt6/QtWebEngineCore/qtwebenginecore-config.h" <<'CFG'
#define QT_FEATURE_webengine_printing_and_pdf 1
#define QT_FEATURE_webengine_spellchecker 1
#define QT_FEATURE_webengine_pepper_plugins 1
#define QT_FEATURE_webengine_webrtc 1
#define QT_FEATURE_webengine_native_spellchecker 1
#define QT_FEATURE_webengine_webchannel 1
#define QT_FEATURE_webengine_geolocation 1
#define QT_FEATURE_webengine_extensions 1
#define QT_FEATURE_webengine_embedded_build -1
#define QT_FEATURE_webengine_vulkan 1
CFG

cat > "$PREFIX/include/qt6/QtWebEngineQuick/qtwebenginequick-config.h" <<'CFG'
#define QT_FEATURE_webengine_webchannel 1
#define QT_FEATURE_webengine_printing_and_pdf 1
CFG

for module in Qt6WebEngineCore Qt6WebEngineQuick Qt6WebEngineWidgets; do
    cmake_dst_dir="$PREFIX/lib/cmake/$module"
    mkdir -p "$cmake_dst_dir"
    cp -a "$REPO_ROOT/cmake/${module}/${module}Config.cmake" "$cmake_dst_dir/"
    cp -a "$REPO_ROOT/cmake/${module}/${module}ConfigVersion.cmake" "$cmake_dst_dir/"
    cp -a "$REPO_ROOT/cmake/${module}/${module}Targets.cmake" "$cmake_dst_dir/"
done

# Copy activate/deactivate scripts
mkdir -p "$PREFIX/etc/conda/activate.d"
mkdir -p "$PREFIX/etc/conda/deactivate.d"
cp -a "$REPO_ROOT/devtools/conda-build/activate.sh" "$PREFIX/etc/conda/activate.d/qt6-webengine-uibcdf.sh"
cp -a "$REPO_ROOT/devtools/conda-build/deactivate.sh" "$PREFIX/etc/conda/deactivate.d/qt6-webengine-uibcdf.sh"
