# Developer guide

For the current five-package 6.10.1 staging and public-release decision,
start with the [Addons family release route](https://github.com/uibcdf/pyside6-addons-uibcdf/blob/python-3.14-qt-6.10.1/devguide/qt_6_10_1_release_route.md).
This candidate's GitHub workflow stages only; its old direct-to-main shell
uploader is disabled. These changes are not a staged or public release claim.

This directory records the local packaging and maintenance recipe for
`qt6-webengine-uibcdf`.

Primary entrypoint:

- [Python 3.14 / Qt 6.10.1 transition](python_3_14_transition.md) — current
  candidate, local evidence, and release gates.
- [6.9.2 bootstrap](bootstrap_6.9.2.md) — historical design and build
  observations; consult it for a specific question, not as the current recipe.

For the aligned family's local build order, channel provenance, interpreter
matrix, and disk-space precautions, see the
[Addons family build practices](https://github.com/uibcdf/pyside6-addons-uibcdf/blob/python-3.14-qt-6.10.1/devguide/qt_family_build_practices.md).
