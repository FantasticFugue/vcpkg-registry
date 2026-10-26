# Include current package inputs in httpant's binary-cache identity.
if(PORT STREQUAL "httpant")
  get_filename_component(HTTPANT_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/../../httpant" ABSOLUTE)
  file(GLOB_RECURSE HTTPANT_SOURCE_FILES LIST_DIRECTORIES FALSE
    "${HTTPANT_SOURCE_DIR}/modules/*.cppm"
    "${HTTPANT_SOURCE_DIR}/import/*.ixx"
    "${HTTPANT_SOURCE_DIR}/cmake/*.cmake"
    "${HTTPANT_SOURCE_DIR}/cmake/*.in")
  list(SORT HTTPANT_SOURCE_FILES)
  list(APPEND VCPKG_HASH_ADDITIONAL_FILES ${HTTPANT_SOURCE_FILES}
    "${HTTPANT_SOURCE_DIR}/CMakeLists.txt"
    "${HTTPANT_SOURCE_DIR}/vcpkg.json"
    "${HTTPANT_SOURCE_DIR}/LICENSE")
endif()
