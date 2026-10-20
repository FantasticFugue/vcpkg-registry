# A consumer of the installed port: no add_subdirectory, no httpant checkout.
cmake_minimum_required(VERSION 4.0)
project(consumer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_SCAN_FOR_MODULES ON)

find_package(httpant CONFIG REQUIRED)

add_executable(consumer main.cpp)
target_link_libraries(consumer PRIVATE httpant::httpant)
