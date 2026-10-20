include(CMakeFindDependencyMacro)
find_dependency(Threads)
if(NOT TARGET asio::asio)
  add_library(asio::asio INTERFACE IMPORTED)
  set_target_properties(asio::asio PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
    INTERFACE_COMPILE_DEFINITIONS ASIO_STANDALONE
    INTERFACE_LINK_LIBRARIES Threads::Threads)
endif()
