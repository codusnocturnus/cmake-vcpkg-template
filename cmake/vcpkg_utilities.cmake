include(ExternalProject)
function (get_vcpkg)
    if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
        set(VCPKG_BUILD_CMD bootstrap-vcpkg.bat)
        set(VCPKG_BINARY "vcpkg.exe")
        set(OSNAME "windows")
    elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
        set(VCPKG_BUILD_CMD bootstrap-vcpkg.sh)
        set(VCPKG_BINARY "vcpkg")
        set(OSNAME "linux")
    endif()
    if("${CMAKE_SIZEOF_VOID_P}" EQUAL "4")
        set(PLATFORMNAME "x86")
    elseif("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(PLATFORMNAME "x64")
    endif()
    set(VCPKG_TRIPLET "${PLATFORMNAME}-${OSNAME}" PARENT_SCOPE)

    if(${ARGC} EQUAL 0)
        # create/use a local vcpkg instance
        ExternalProject_Add(vcpkg
            GIT_REPOSITORY https://github.com/microsoft/vcpkg.git
            GIT_TAG 2020.06
            CONFIGURE_COMMAND ""
            BUILD_COMMAND "<SOURCE_DIR>/${VCPKG_BUILD_CMD}"
            INSTALL_COMMAND ""
            UPDATE_COMMAND ""
            STEP_TARGETS build
            BUILD_BYPRODUCTS "<SOURCE_DIR>/${VCPKG_BINARY}"
        )
        ExternalProject_Get_Property(vcpkg SOURCE_DIR)
        set(VCPKG_DIR "${SOURCE_DIR}" PARENT_SCOPE)
        set(VCPKG_CMD "${SOURCE_DIR}/${VCPKG_BINARY}" PARENT_SCOPE)
        set(VCPKG_DEPENDENCIES "vcpkg" PARENT_SCOPE)
    else()
        # use an external/existing vcpkg instance
        add_custom_target(vcpkg)
        set(VCPKG_DIR "${ARGV0}" PARENT_SCOPE)
        set(VCPKG_CMD "${ARGV0}/${VCPKG_BINARY}" PARENT_SCOPE)
        set(VCPKG_DEPENDENCIES "vcpkg" PARENT_SCOPE)
    endif()
endfunction()

function (vcpkg_install PACKAGE_NAME)
    add_custom_command(
        OUTPUT "${VCPKG_DIR}/packages/${PACKAGE_NAME}_${VCPKG_TRIPLET}/BUILD_INFO"
        COMMAND ${VCPKG_CMD} install ${PACKAGE_NAME}:${VCPKG_TRIPLET}
        WORKING_DIRECTORY ${VCPKG_DIR}
        DEPENDS vcpkg
    )
    add_custom_target(
        get${PACKAGE_NAME}
        ALL
        DEPENDS "${VCPKG_DIR}/packages/${PACKAGE_NAME}_${VCPKG_TRIPLET}/BUILD_INFO"
    )
    list(APPEND VCPKG_DEPENDENCIES "get${PACKAGE_NAME}")
    set(VCPKG_DEPENDENCIES ${VCPKG_DEPENDENCIES} PARENT_SCOPE)
endfunction()

function (vcpkg_packagefile FILENAME)
    file(STRINGS ${FILENAME} filelist)
    foreach(filename ${filelist})
        vcpkg_install(${filename})
    endforeach()
    set(VCPKG_DEPENDENCIES ${VCPKG_DEPENDENCIES} PARENT_SCOPE)
endfunction()
