get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

include(CMakeFindDependencyMacro)

if(NOT Qt6_FOUND)
    find_dependency(Qt6 6.9.2)
endif()

find_dependency(Qt6Core 6.9.2)
find_dependency(Qt6Gui 6.9.2)
find_dependency(Qt6Widgets 6.9.2)
find_dependency(Qt6PrintSupport 6.9.2)
find_dependency(Qt6WebEngineCore 6.9.2)

if(NOT DEFINED Qt6WebEngineWidgets_FOUND)
    set(Qt6WebEngineWidgets_FOUND TRUE)
endif()

if(NOT QT_NO_CREATE_TARGETS AND Qt6WebEngineWidgets_FOUND)
    include("${CMAKE_CURRENT_LIST_DIR}/Qt6WebEngineWidgetsTargets.cmake")
endif()

if(TARGET Qt6::WebEngineWidgets)
    set(Qt6WebEngineWidgets_LIBRARIES "Qt6::WebEngineWidgets")
    set(Qt6WebEngineWidgets_INCLUDE_DIRS
        "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineWidgets"
        "${PACKAGE_PREFIX_DIR}/include/qt6")
    if(TARGET Qt6::WebEngineWidgetsPrivate)
        get_target_property(Qt6WebEngineWidgets_PRIVATE_INCLUDE_DIRS
                            Qt6::WebEngineWidgetsPrivate
                            INTERFACE_INCLUDE_DIRECTORIES)
    endif()
    set(_Qt6WebEngineWidgets_MODULE_DEPENDENCIES "Core;Gui;Widgets;PrintSupport;WebEngineCore")
endif()
