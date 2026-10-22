vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO NVIDIA/stdexec
  REF c3cd08bbc5a49a585cb996278d2f76ddf7aac01f
  SHA512 a2ea82e650ab54808c5fcd4e1f1a93c889199ea30493cf1b5a009e26c3416633aefae47beea0c1693ff24b199e19b639cf6a273f85fe6dbd155edbcc87584d02
  PATCHES module-exports.patch)

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include"
  PATTERN "*.in" EXCLUDE)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/stdexec-config.cmake"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/stdexec")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
