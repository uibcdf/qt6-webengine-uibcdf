if(TARGET Qt6::WebEngineQuick)
    return()
endif()

add_library(Qt6::WebEngineQuick SHARED IMPORTED)
set_target_properties(Qt6::WebEngineQuick PROPERTIES
    IMPORTED_LOCATION "${PACKAGE_PREFIX_DIR}/lib/libQt6WebEngineQuick.so.6"
    IMPORTED_SONAME "libQt6WebEngineQuick.so.6"
    INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineQuick;${PACKAGE_PREFIX_DIR}/include/qt6"
    INTERFACE_LINK_LIBRARIES "Qt6::Core;Qt6::Gui;Qt6::Qml;Qt6::Quick;Qt6::WebEngineCore;Qt6::WebChannelQuick"
    INTERFACE_QT_MAJOR_VERSION "6"
    _qt_module_include_name "QtWebEngineQuick"
    _qt_module_interface_name "WebEngineQuick"
    _qt_package_name "Qt6WebEngineQuick"
    _qt_package_version "6.9.2"
)

add_library(Qt6::WebEngineQuickPrivate INTERFACE IMPORTED)
set_target_properties(Qt6::WebEngineQuickPrivate PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineQuick;${PACKAGE_PREFIX_DIR}/include/qt6"
    INTERFACE_LINK_LIBRARIES "Qt6::WebEngineQuick"
)
