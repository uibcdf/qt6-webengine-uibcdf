# Qt WebEngine 6.10.1 / Python 3.14 transition

Issue: [`uibcdf/qt6-webengine-uibcdf#1`](https://github.com/uibcdf/qt6-webengine-uibcdf/issues/1).
Status: isolated Linux candidate built and tested locally; no release or
channel upload.

## Source and package boundary

The candidate aligns with conda-forge `qt6-main=6.10.1` and the locally built
`qt6-positioning-uibcdf=6.10.1` candidate. The official
[`PySide6-Addons` 6.10.1 Linux x86-64 wheel](https://pypi.org/project/PySide6-Addons/6.10.1/)
supplies the WebEngine binary and runtime-resource payload. Its SHA-256 is
`330c229b58d30083a7b99ed22e118eb4f4126408429816a4044ccd0438ae81b4`.
The official [`qt/qtwebengine` v6.10.1](https://github.com/qt/qtwebengine/tree/v6.10.1)
source, peeled commit `28eb5425c6abef3938fb82a48427d45d1dd4e64f`,
supplies matching public headers. The pinned source archive has SHA-256
`05645440d4177efd3a67992f01c3af65258d43be16b95ab2bd8bb3447db6a155`.
Both are fetched and checked by the Conda recipe; no developer-specific
environment or mutable local PySide installation is a recipe input.

All 97 entries in the 6.9.2 WebEngine payload manifest were found in the
official 6.10.1 wheel. CMake package version references were updated to
6.10.1. This package contains native Qt libraries and resources, not a Python
extension, so its host and run requirements do not pin a Python ABI. The
package tests use Python 3.14 as the current integration probe.

## Local evidence and correction

The first corrected-source local Conda build completed its recipe tests,
including required libraries, QML plugins, ICU resources, helper process,
public headers, activation paths, and `ctypes` loading of WebEngineCore. An
independent offline Conda environment resolved its exact local artifact with
Python 3.14.7, conda-forge Qt 6.10.1, and the local Positioning 6.10.1
candidate. Resource-path checks and `ctypes` loading of WebEngineCore and
WebEngineWidgets passed.

The independent linkage audit also found libraries resolved from the Linux
host rather than the Conda environment, notably NSS, udev, GBM, XKB file,
and shared-memory fence libraries. These native run dependencies are now
declared explicitly. The final rebuilt package passed its Conda tests and
installed in a second clean offline environment with Python 3.14.7. Its
activated resource paths, helper-process path, WebEngineCore and
WebEngineWidgets library loads passed. The final linkage audit resolved NSS,
udev, GBM, XKB file, and shared-memory fence libraries from Conda; only
standard Linux system libraries such as `libc`, `libm`, and `libresolv`
remained host-provided. The final artifact is
`qt6-webengine-uibcdf-6.10.1-0.conda` for `linux-64`, with SHA-256
`e873fe2a72040716690187b0220cba6babf1835ae37ad9a157d350275025fcdf`.

The 6.9.2 activation hook also set
`QTWEBENGINE_DISABLE_SANDBOX=1` globally. This candidate removes that unsafe
default, with a package test and an independent clean-environment check. A
headless test that needs to disable the Chromium sandbox must do so
explicitly, not alter every consumer's environment.

## Remaining gates

1. Build the aligned `pyside6-addons-uibcdf` 6.10.1 package and exercise
   `QWebEngineView` and the MolSysViewer standalone host in a clean Python
   3.14 environment.
2. Expand platform and interpreter evidence, then stage the coherent Qt
   family before any release or promotion to the main Conda label.
