# httpant is a C++23 module library, so the source is pinned by commit rather
# than by a release tarball: vcpkg verifies the checked-out tree against the
# `git-tree` in versions/h-/httpant.json, which is the same guarantee a tarball
# hash gives.
#
# Bump REF and the versions entry together: scripts/add-version.sh does both.
set(HTTPANT_REF "2619ae7a9c1e601e80718c6bdb2043f77ee0de26")

# The canonical source is GitHub. HTTPANT_GIT_URL points it at a mirror or a
# local checkout, which is how this registry is used offline or before the
# upstream repository is published.
if(DEFINED ENV{HTTPANT_GIT_URL})
    set(HTTPANT_GIT_URL "$ENV{HTTPANT_GIT_URL}")
endif()
if(NOT DEFINED HTTPANT_GIT_URL)
    set(HTTPANT_GIT_URL "https://github.com/tsurumi-yizhou/httpant.git")
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL "${HTTPANT_GIT_URL}"
    REF "${HTTPANT_REF}"
)

# Upstream submission: microsoft/vcpkg wants vcpkg_from_github with a tag and a
# tarball SHA512 instead. Replace the call above with this once httpant tags
# releases, and fill the hash from vcpkg's own error message:
#
# vcpkg_from_github(
#     OUT_SOURCE_PATH SOURCE_PATH
#     REPO tsurumi-yizhou/httpant
#     REF "v${VERSION}"
#     SHA512 <sha512 of the tag tarball>
#     HEAD_REF main
# )

# The engine is a feature, not a default: httpant ships as a sans-I/O library
# unless the consumer asks for httpant::io.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        io HTTPANT_ENABLE_IO
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTING=OFF
        -DENABLE_EXAMPLES=OFF
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
