# Bootstrap 6.9.2

## Scope

This repo tracks the first Linux / Python 3.13 experimental UIBCDF line for
the Qt `WebEngine` runtime layer needed by:

- `pyside6-addons-uibcdf 6.9.2`

## Why This Repo Exists

The current `pyside6-addons-uibcdf` blocker is no longer `_uibcdf` namespace or
PySide source-build structure. The remaining blocker is Qt runtime:

- `qt6-main 6.9.2` does not expose `Qt6WebEngine`
- `conda-forge` does not provide `qt6-webengine`

This repo exists to package that missing Qt layer explicitly.

## Relationship To Other Repos

This repo sits above:

- `qt6-positioning-uibcdf`

because `libQt6WebEngineCore.so.6` depends directly on:

- `libQt6Positioning.so.6`

This repo is expected to reuse:

- `qt6-main 6.9.2` for Qt base and `QtWebChannel`
- `qt6-positioning-uibcdf 6.9.2` for `QtPositioning`

## Runtime Reference

The working runtime reference is:

- `/home/diego/Myopt/miniconda3/envs/molsyssuite-qt-spike`

Visible `QtWebEngine` payload there includes:

- `PySide6/Qt/lib/libQt6WebEngineCore.so.6`
- `PySide6/Qt/lib/libQt6WebEngineQuick.so.6`
- `PySide6/Qt/lib/libQt6WebEngineQuickDelegatesQml.so.6`
- `PySide6/Qt/lib/libQt6WebEngineWidgets.so.6`
- `PySide6/Qt/libexec/QtWebEngineProcess`
- `PySide6/Qt/qml/QtWebEngine/`
- `PySide6/Qt/resources/qtwebengine*.pak`
- `PySide6/Qt/translations/qtwebengine_locales/`

## Current Reading

This is the large Qt-side package of the standalone stack.

Important findings so far:

- `libQt6WebEngineCore.so.6` is around 190 MB by itself
- `Qt/resources` adds about 24 MB
- `qtwebengine_locales` adds about 38 MB
- `QtWebChannel` should be reused from `qt6-main 6.9.2`
- `QtPositioning` should be reused from `qt6-positioning-uibcdf 6.9.2`

## Immediate Goal

Produce a first experimental local conda package for:

- `qt6-webengine-uibcdf 6.9.2`

Then re-run `pyside6-addons-uibcdf` with:

- `qt6-positioning-uibcdf`
- `qt6-webengine-uibcdf`

available in the host build env.

## Build Result (2026-03-31)

First `conda build` attempt succeeded on 2026-03-31.

- Output: `qt6-webengine-uibcdf-6.9.2-py313_0.conda` (80 MB)
- Location: `conda-bld/linux-64/`
- Build time: ~9:16
- All tests passed:
  - `libQt6WebEngineCore.so.6` present
  - `libQt6WebEngineQuick.so.6`, `libQt6WebEngineWidgets.so.6` present
  - `libQt6WebEngineQuickDelegatesQml.so.6` present
  - `QtWebEngineProcess` present
  - QML plugins present
  - resources and locales present
  - headers installed under `include/qt6/QtWebEngine{Core,Quick,Widgets}/`
  - cmake configs installed under `lib/cmake/Qt6WebEngine*/`

Dependency `qt6-positioning-uibcdf 6.9.2` was available via local conda-bld channel.

## Runtime Fix Build 1 (2026-07-02)

MolSysViewer standalone Qt validation exposed that the initial
`qt6-webengine-uibcdf-6.9.2-py313_0` package was not sufficient as an installed
runtime:

- `QtWebEngineProcess` was installed under `$PREFIX/libexec/QtWebEngineProcess`;
- WebEngine `.pak` resources were installed under `$PREFIX/resources`;
- locales were installed under `$PREFIX/translations/qtwebengine_locales`;
- Qt WebEngine did not auto-detect those paths in the split conda layout;
- Chromium then reached an ICU failure because the package did not include
  `resources/icudtl.dat`.

Build `py313_1` fixes the runtime payload and activation contract:

- package build number bumped from `0` to `1`;
- manifest now includes:
  - `Qt/resources/icudtl.dat`;
  - `Qt/resources/v8_context_snapshot.bin`;
- package tests now assert both files are installed;
- package tests assert the conda activation/deactivation scripts are installed;
- package tests include a direct `ctypes.CDLL('libQt6WebEngineCore.so.6')`
  smoke check;
- activation script sets:
  - `QTWEBENGINEPROCESS_PATH=$CONDA_PREFIX/libexec/QtWebEngineProcess`;
  - `QTWEBENGINE_RESOURCES_PATH=$CONDA_PREFIX/resources`;
  - `QTWEBENGINE_LOCALES_PATH=$CONDA_PREFIX/translations/qtwebengine_locales`;
  - `QTWEBENGINE_DISABLE_SANDBOX=1`;
- deactivation script restores the previous values.

Before rebuilding, the manifest was checked against the source runtime
`$QT6_WEBENGINE_UIBCDF_SOURCE_PREFIX` and all entries were present.
