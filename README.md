# qt6-webengine-uibcdf

Experimental UIBCDF conda packaging repo for the Qt `WebEngine` runtime layer
needed by the provisional standalone Qt-for-Python family.

Current line:

- Qt runtime line: `6.9.2`
- target platform: Linux
- target Python family using it: Python `3.13`

This repo exists because:

- `pyside6-addons-uibcdf 6.9.2` needs `QtWebEngine`
- `qt6-main 6.9.2` from conda-forge does not provide it
- `qt6-positioning-uibcdf` already covers the smaller `QtPositioning` slice
- `qt6-main 6.9.2` already provides `Qt6WebChannel`, so this repo should not
  duplicate that layer unnecessarily
