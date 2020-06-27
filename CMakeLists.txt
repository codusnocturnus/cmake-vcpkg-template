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
    set(DEPENDENCIES)

    include(vcpkg_utilities)
    get_vcpkg()
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

