if(NOT TARGET STDEXEC::stdexec)
  add_library(STDEXEC::stdexec INTERFACE IMPORTED)
  set_target_properties(STDEXEC::stdexec PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_CURRENT_LIST_DIR}/../../include"
    INTERFACE_COMPILE_FEATURES cxx_std_20)
endif()
