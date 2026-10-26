# Fughetta vcpkg ports

Current overlay ports for `httpant`, `stdexec`, `asio`, `llhttp`, `msquic` (2.6.3 with OpenSSL 3.5.9),
`c-ares` (1.34.9), `reflectcpp` (0.26.2), and `sqlite3` (3.54.1),
with xclang triplets for the workspace's C++ projects.

## Consume

Keep `httpant`, `vcpkg-registry`, and the consuming project beside each other.
The consumer's `vcpkg-configuration.json` selects the current port directory:

```json
{
    "overlay-ports": ["../vcpkg-registry/ports"]
}
```

The `httpant` port reads the sibling `../httpant` checkout. Its existing version
is `0.2.0`, revision `0`. The port installs module sources and CMake package
files; the consuming project's compiler builds those modules.

Triplets include `triplets/httpant-source.cmake`, which adds current httpant
module, import, CMake, manifest, and license files to the package cache key.
Changes to those inputs invalidate the cached package through
[VCPKG_HASH_ADDITIONAL_FILES](https://learn.microsoft.com/en-us/vcpkg/users/triplets#vcpkg_hash_additional_files).

The consuming projects' Git-ignored local presets record `XCLANG_ROOT`,
`VCPKG_ROOT`, the target, and triplet. Configure from the consuming project's
directory with `cmake --preset <name>`; no shell exports or extra `-D` arguments
are required.

Trader lives beside this repository, so its overlay path is
`../vcpkg-registry/ports`. It selects `httpant[io]` on the default asio
mechanism. Trader's toolchain selects host C APIs and xclang's C++ modules and
static runtimes for its dependencies. See [Trader's README](../trader/README.md)
for its build and current validation limits.

## Update a current port

Edit `ports/<name>/` and refresh the existing version record:

```sh
./add-port-version httpant
```

The helper updates the matching entry's `git-tree`, preserving the version,
revision, and number of entries. It stages the port directory. Creating a
version requires explicit user approval.

Consumers read overlay ports directly. The version records remain metadata
for the existing entries.

## Layout

| Path | Contents |
| --- | --- |
| `ports/` | Current package definitions |
| `versions/` | Existing version records |
| `triplets/` | Target settings and source-cache inputs |

The reviewed stdexec port supplies the public execution-module exports and
retains the `STDEXEC::stdexec` CMake target.

The service and gateway debug presets configured successfully.
