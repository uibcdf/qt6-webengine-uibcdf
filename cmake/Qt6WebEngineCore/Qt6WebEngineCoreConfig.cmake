get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

include(CMakeFindDependencyMacro)

if(NOT Qt6_FOUND)
    find_dependency(Qt6 6.9.2)
endif()

find_dependency(Qt6Core 6.9.2)
find_dependency(Qt6Gui 6.9.2)
find_dependency(Qt6Network 6.9.2)
find_dependency(Qt6PrintSupport 6.9.2)
find_dependency(Qt6WebChannel 6.9.2)

if(NOT DEFINED Qt6WebEngineCore_FOUND)
    set(Qt6WebEngineCore_FOUND TRUE)
endif()

if(NOT QT_NO_CREATE_TARGETS AND Qt6WebEngineCore_FOUND)
    include("${CMAKE_CURRENT_LIST_DIR}/Qt6WebEngineCoreTargets.cmake")
endif()

if(TARGET Qt6::WebEngineCore)
    set(Qt6WebEngineCore_LIBRARIES "Qt6::WebEngineCore")
    set(Qt6WebEngineCore_INCLUDE_DIRS
        "${PACKAGE_PREFIX_DIR}/include/qt6/QtWebEngineCore"
        "${PACKAGE_PREFIX_DIR}/include/qt6")
    if(TARGET Qt6::WebEngineCorePrivate)
        get_target_property(Qt6WebEngineCore_PRIVATE_INCLUDE_DIRS
                            Qt6::WebEngineCorePrivate
                            INTERFACE_INCLUDE_DIRECTORIES)
    endif()
    set(_Qt6WebEngineCore_MODULE_DEPENDENCIES "Core;Gui;Network;PrintSupport;WebChannel")
endif()
