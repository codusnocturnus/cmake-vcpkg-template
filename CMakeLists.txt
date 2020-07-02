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

list(APPEND
    CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake
)

project(top
    LANGUAGES CXX
)

set(EXTERNAL_VCPKG_DIR "" CACHE STRING "Path to an existing external vcpkg instance.")
include(vcpkg_utilities)
get_vcpkg(${EXTERNAL_VCPKG_DIR})
vcpkg_packagefile("${CMAKE_CURRENT_LIST_DIR}/vcpkgs.txt")

include(ExternalProject)
set_property(DIRECTORY
    PROPERTY
        EP_BASE hello
)
ExternalProject_Add(hello
    DEPENDS ${VCPKG_DEPENDENCIES}
    SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src
    INSTALL_COMMAND ""
    CMAKE_ARGS ${CL_ARGS};
               -DCMAKE_TOOLCHAIN_FILE=${VCPKG_DIR}/scripts/buildsystems/vcpkg.cmake
)
