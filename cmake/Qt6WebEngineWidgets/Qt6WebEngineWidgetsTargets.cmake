if(TARGET Qt6::WebEngineWidgets)
    return()
endif()

add_library(Qt6::WebEngineWidgets SHARED IMPORTED)
set_target_properties(Qt6::WebEngineWidgets PROPERTIES
    IMPORTED_LOCATION "${PACKAGE_PREFIX_DIR}/lib/libQt6WebEngineWidgets.so.6"
    IMPORTED_SONAME "libQt6WebEngineWidgets.so.6"
    INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineWidgets;${PACKAGE_PREFIX_DIR}/include/qt6"
    INTERFACE_LINK_LIBRARIES "Qt6::Core;Qt6::Gui;Qt6::Widgets;Qt6::PrintSupport;Qt6::WebEngineCore"
    INTERFACE_QT_MAJOR_VERSION "6"
    _qt_module_include_name "QtWebEngineWidgets"
    _qt_module_interface_name "WebEngineWidgets"
    _qt_package_name "Qt6WebEngineWidgets"
    _qt_package_version "6.9.2"
)

add_library(Qt6::WebEngineWidgetsPrivate INTERFACE IMPORTED)
set_target_properties(Qt6::WebEngineWidgetsPrivate PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineWidgets;${PACKAGE_PREFIX_DIR}/include/qt6"
    INTERFACE_LINK_LIBRARIES "Qt6::WebEngineWidgets"
)
