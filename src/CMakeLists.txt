cmake_minimum_required(VERSION 3.17)

project(hello
    LANGUAGES CXX
)

find_package(fmt CONFIG REQUIRED)
add_executable(hello
    hellofmt.cpp
)
target_link_libraries(hello
    PRIVATE
        fmt::fmt
)
