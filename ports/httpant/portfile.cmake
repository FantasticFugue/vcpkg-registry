# Build the current sibling checkout through the current overlay port.
get_filename_component(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../../httpant" ABSOLUTE)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls HTTPANT_ENABLE_TLS
        io HTTPANT_ENABLE_IO
        quic HTTPANT_ENABLE_QUIC
)
set(IO_BACKEND asio)
if("uring" IN_LIST FEATURES)
    set(IO_BACKEND uring)
endif()
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DHTTPANT_IO_BACKEND=${IO_BACKEND}
        -DBUILD_TESTING=OFF
        -DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/httpant PACKAGE_NAME httpant)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# httpant builds against an xclang tree (C++23 modules with the standard library
# as a module). A consumer picks it up through CMAKE_PREFIX_PATH, which a
# triplet sets; see the README.
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
