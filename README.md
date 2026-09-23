# qt6-webengine-uibcdf

Experimental UIBCDF Conda packaging of the native Qt WebEngine runtime used
by the optional MolSysViewer standalone Qt host. It reuses `qt6-main` and
`qt6-positioning-uibcdf` instead of duplicating those libraries.

The published 6.9.2 line is Linux/Python 3.13-era packaging. The
`python-3.14-qt-6.10.1` branch is an **unreleased Linux candidate** aligned
with Qt 6.10.1. WebEngine itself has no Python ABI dependency; the candidate
is tested with Python 3.14 because that is the next family integration target.
Its recipe obtains a checksum-pinned official PySide6 Addons wheel for the
runtime payload and the matching Qt WebEngine source for headers. It does not
compile Chromium from source.

See the [Python 3.14 transition checkpoint](devguide/python_3_14_transition.md)
and [issue #1](https://github.com/uibcdf/qt6-webengine-uibcdf/issues/1)
for provenance, local evidence, and remaining release gates. A local package
build alone does not establish that the complete Qt host is releasable.
