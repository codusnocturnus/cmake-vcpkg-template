# cmake-vcpkg-template

![CI](https://github.com/codusnocturnus/cmake-vcpkg-template/workflows/CI/badge.svg)

A template for using vcpkg to provide packages for CMake projects.

Features:
- manages (vcpkg, ExternalProject) dependencies and main project separately, so dependencies are available to the main project when it is configured
- manages vcpkg
  - get_vcpkg() - installs a local vcpkg instance
  - get_vcpkg(_/path/to/vcpkg_) - links vcpkg functions to a separately-installed vcpkg instance
    - can be specified on the CMake command line via -DEXTERNAL_VCPKG_DIR=_/path/to/vcpkg_
  - vcpkg_install(_packagename_) - installs _packagename_, using the vcpkg "triplet" appropriate for the current build configuration
  - vcpkg_packagefile(_filename_) - reads a list of packages from _filename_, and installs each
