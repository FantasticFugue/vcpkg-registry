vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF "v${VERSION}"
    SHA512 0b3c8f293a6fd7be15c67888a98df3e2a89a5314eef8fbb9b127e8be10a23c74be1df3beb3ff4da2b8e38ca9059ec43d741a4197e8b91a83c43877244097b037
    HEAD_REF master
    PATCHES
        fix-install.patch
        fix-uwp-crt.patch
        uwp-link-libs.diff
        no-werror.patch
        cmake4.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_from_github(
        OUT_SOURCE_PATH XDP_WINDOWS
        REPO microsoft/xdp-for-windows
        REF d372b52577a724e04fa4c06acb90bbfa4719fc25
        SHA512 a95c5c035ad623e6da2d5fcfd910e4d88dae352ff153b32e07f9b787d83fb6de2645e7c8eda61320569b5080a7c618020e566546841ce609acc5e034aae662c9
    )
    file(COPY "${XDP_WINDOWS}/published/external"
        DESTINATION "${QUIC_SOURCE_PATH}/submodules/xdp-for-windows/published")
endif()

set(QUIC_TLS_LIB schannel)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    # OpenSSL's own QUIC TLS interface (3.5 LTS), built from source and
    # linked statically into msquic.
    set(QUIC_TLS_LIB openssl)
    vcpkg_from_github(
        OUT_SOURCE_PATH OPENSSL_SOURCE_PATH
        REPO openssl/openssl
        REF openssl-3.5.9
        SHA512 ab29a6ed40dd8c74420b9bd19c5ac119b0f191aee72d555ba5a0601456155d39c809c77300d98c7e0bce607f32c1f7a83fc7f69f86b9909fe557bba3aa2e468f
    )
    file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/openssl")
    file(COPY "${OPENSSL_SOURCE_PATH}/" DESTINATION "${QUIC_SOURCE_PATH}/submodules/openssl")

    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH "${PERL}" DIRECTORY)
    vcpkg_add_to_path("${PERL_EXE_PATH}")
    vcpkg_replace_string("${QUIC_SOURCE_PATH}/submodules/CMakeLists.txt"
        "ProcessorCount(NPROCS)" "set(NPROCS ${VCPKG_CONCURRENCY})")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" QUIC_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${QUIC_SOURCE_PATH}"
    OPTIONS
        -DNUMA=OFF
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS_LIB=${QUIC_TLS_LIB}
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_PERF=OFF
        -DQUIC_BUILD_TEST=OFF
        "-DQUIC_BUILD_SHARED=${QUIC_BUILD_SHARED}"
        "-DQUIC_STATIC_LINK_CRT=${STATIC_CRT}"
        "-DQUIC_STATIC_LINK_PARTIAL_CRT=${STATIC_CRT}"
        "-DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

set(platform "")
if(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_IOS)
    set(platform "CX_PLATFORM_DARWIN")
elseif(NOT VCPKG_TARGET_IS_WINDOWS)
    set(platform "CX_PLATFORM_LINUX")
endif()
if(platform)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quic_platform.h"
        "#elif ${platform}"
        "#elif 1
#ifndef ${platform}
#define ${platform}
#endif")
elseif(VCPKG_TARGET_IS_UWP)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/quic_platform.h"
        "#elif _WIN32"
        "#elif 1
#ifndef QUIC_UWP_BUILD
#define QUIC_UWP_BUILD
#endif
#ifndef QUIC_RESTRICTED_BUILD
#define QUIC_RESTRICTED_BUILD
#endif")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${QUIC_SOURCE_PATH}/LICENSE" "${QUIC_SOURCE_PATH}/THIRD-PARTY-NOTICES")
