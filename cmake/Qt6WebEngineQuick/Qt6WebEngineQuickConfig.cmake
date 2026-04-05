get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

include(CMakeFindDependencyMacro)

if(NOT Qt6_FOUND)
    find_dependency(Qt6 6.9.2)
endif()

find_dependency(Qt6Core 6.9.2)
find_dependency(Qt6Gui 6.9.2)
find_dependency(Qt6Qml 6.9.2)
find_dependency(Qt6Quick 6.9.2)
find_dependency(Qt6WebEngineCore 6.9.2)
find_dependency(Qt6WebChannelQuick 6.9.2)

if(NOT DEFINED Qt6WebEngineQuick_FOUND)
    set(Qt6WebEngineQuick_FOUND TRUE)
endif()

if(NOT QT_NO_CREATE_TARGETS AND Qt6WebEngineQuick_FOUND)
    include("${CMAKE_CURRENT_LIST_DIR}/Qt6WebEngineQuickTargets.cmake")
endif()

if(TARGET Qt6::WebEngineQuick)
    set(Qt6WebEngineQuick_LIBRARIES "Qt6::WebEngineQuick")
    set(Qt6WebEngineQuick_INCLUDE_DIRS
        "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineQuick"
        "${PACKAGE_PREFIX_DIR}/include/qt6")
    if(TARGET Qt6::WebEngineQuickPrivate)
        get_target_property(Qt6WebEngineQuick_PRIVATE_INCLUDE_DIRS
                            Qt6::WebEngineQuickPrivate
                            INTERFACE_INCLUDE_DIRECTORIES)
    endif()
    set(_Qt6WebEngineQuick_MODULE_DEPENDENCIES "Core;Gui;Qml;Quick;WebEngineCore;WebChannelQuick")
endif()
