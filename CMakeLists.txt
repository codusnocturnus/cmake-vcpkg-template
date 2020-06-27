cmake_minimum_required(VERSION 3.17)
# MUST be done before call to 'project'
get_cmake_property(vars CACHE_VARIABLES)
foreach(var ${vars})
  get_property(currentHelpString CACHE "${var}" PROPERTY HELPSTRING)
    if("${currentHelpString}" MATCHES "No help, variable specified on the command line." OR "${currentHelpString}" STREQUAL "")
        # message("${var} = [${${var}}]  --  ${currentHelpString}") # uncomment to see the variables being processed
        list(APPEND CL_ARGS "-D${var}=${${var}}")
    endif()
endforeach()
option(DO_SUPERBUILD "" ON)
list(APPEND
    CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake
)
if (DO_SUPERBUILD)
    project(Superbuild
        LANGUAGES CXX
    )
    set(PROJECT_ROOT ${CMAKE_CURRENT_LIST_DIR})
    set(CMAKE_CXX_STANDARD 20)
    set(CMAKE_CXX_STANDARD_REQUIRED true)

    set(DEPENDENCIES)

    include(ExternalProject)

    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
        set(VCPKG_BUILD_CMD bootstrap-vcpkg.bat)
        set(VCPKG_BINARY vcpkg.exe)
        set(OSNAME "windows")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        set(VCPKG_BUILD_CMD bootstrap-vcpkg.sh)
        set(VCPKG_BINARY vcpkg)
        set(OSNAME "linux")
    endif()
    if("${CMAKE_SIZEOF_VOID_P}" EQUAL "4")
        set(PLATFORMNAME "x86")
    elseif("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(PLATFORMNAME "x64")
    endif()
    set(VCPKG_TRIPLET "${PLATFORMNAME}-${OSNAME}")

    ExternalProject_Add(vcpkg
        GIT_REPOSITORY https://github.com/microsoft/vcpkg.git
        GIT_TAG 2020.06
        CONFIGURE_COMMAND ""
        BUILD_COMMAND "<SOURCE_DIR>/${VCPKG_BUILD_CMD}"
        INSTALL_COMMAND ""
        STEP_TARGETS build
        BUILD_BYPRODUCTS "<SOURCE_DIR>/vcpkg"
    )
    ExternalProject_Get_Property(vcpkg SOURCE_DIR)
    set(VCPKG_DIR "${SOURCE_DIR}")
    set(VCPKG_CMD "${VCPKG_DIR}/${VCPKG_BINARY}")
    list(APPEND DEPENDENCIES vcpkg)

    add_custom_command(
        OUTPUT "${VCPKG_DIR}/packages/fmt_${VCPKG_TRIPLET}/BUILD_INFO"
        COMMAND ${VCPKG_CMD} install fmt:${VCPKG_TRIPLET}
        WORKING_DIRECTORY ${VCPKG_DIR}
        DEPENDS vcpkg-build
    )
    add_custom_target(
        getfmt
        ALL
        DEPENDS "${VCPKG_DIR}/packages/fmt_${VCPKG_TRIPLET}/BUILD_INFO"
    )
    list(APPEND DEPENDENCIES getfmt)

    set_property(DIRECTORY
        PROPERTY
            EP_BASE hello
    )
    ExternalProject_Add(hello
        DEPENDS ${DEPENDENCIES}
        SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src
        BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/hello
        INSTALL_COMMAND ""
        CMAKE_ARGS ${CL_ARGS};
                   -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>;
                   -DCMAKE_TOOLCHAIN_FILE=${VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake
    )
    return()
else()
    project(Secondary
        LANGUAGES NONE
    )
    add_subdirectory(src)
endif()

