# Fughetta vcpkg registry

A [vcpkg git registry](https://learn.microsoft.com/vcpkg/users/registries) for
the Fughetta family. It carries one port today, `httpant`, plus the xclang
triplets that port needs.

Two consumers, one source of truth:

| Path | Consumer |
| --- | --- |
| this registry (self-hosted) | our own projects, private CI, anyone who wants the current commit |
| `microsoft/vcpkg` (upstream) | everyone else; a PR against the official catalogue |

The portfile is written so the upstream submission is a small, reviewable diff
rather than a second implementation.

## Layout

```
ports/httpant/          portfile.cmake, vcpkg.json, usage
versions/               baseline.json + h-/httpant.json (the git-tree vcpkg verifies)
triplets/               xclang triplets: x64/arm64 × linux/osx/windows
scripts/add-version.sh  records a new httpant commit in all three files at once
examples/               a consumer manifest and CMakeLists for smoke testing
```

## Consuming it

In a project's `vcpkg-configuration.json`:

Today the registry is local-only: nothing is pushed, and a consumer points at the
directory instead of a URL. The git registry form works with any git checkout,
local or hosted, so only the `repository` value changes when it is published:

```json
{
    "default-registry": {
        "kind": "git",
        "repository": "https://github.com/microsoft/vcpkg",
        "baseline": "818beed257310e1319826eb887651ba7ed61a29a"
    },
    "registries": [
        {
            "kind": "git",
            "repository": "file:///home/yizhou/Fughetta/vcpkg-registry",
            "baseline": "<a commit of this registry>",
            "packages": ["httpant"]
        }
    ]
}
```

The registry's `baseline` must name a commit of *this* repository, and that
commit's `versions/baseline.json` decides which httpant version a consumer gets.
Bumping a port therefore has two steps: add the version (see below) and move the
consumer's baseline.

xclang triplets ship here because `httpant` is a C++23 module library: it needs
a compiler that scans modules and a standard library available as a module. Point
vcpkg at them and export the compiler tree:

```sh
export XCLANG_ROOT=/path/to/xclang
vcpkg install httpant --triplet x64-linux-xclang --overlay-triplets=triplets
```

## Adding a version

```sh
./scripts/add-version.sh 0.2.0 <httpant commit>
```

It writes the version into `ports/httpant/vcpkg.json`, pins `HTTPANT_REF` in the
portfile, appends the entry to `versions/h-/httpant.json` with the **git-tree of
`ports/httpant`** — what vcpkg verifies when it reads this registry, and the
reason the port and its version entry land in one commit — and moves
`versions/baseline.json` to the new version. The upstream source hash and the
port-directory tree are two different things; the script computes both.

Then check the plan resolves before committing:

```sh
vcpkg install httpant --overlay-ports=ports/httpant \
    --overlay-triplets=triplets --triplet x64-linux-xclang --dry-run
```

Never edit an entry that has been merged: vcpkg hashes the tree, and a rewritten
history silently changes what a pinned consumer builds. Add a version; do not
retouch one.

## What the port needs, and where it stands

`httpant` is a C++23 module library, so the port does two unusual things:

1. **It installs sources, not BMIs** (`share/httpant/modules`, `share/httpant/import`).
   BMIs are compiler-specific; `httpant-config.cmake` rebuilds the three targets
   (`httpant`, `httpant-io`, `httpant-imports`) in the consumer's build from
   those sources.
2. **It requires xclang.** `find_package(xclang CONFIG)` must succeed and the
   standard library must be available as a module. The triplets here supply the
   compiler; export `XCLANG_ROOT` and the triplet passes it through. That
   requirement is deliberate — it is what the library is built on, not an
   oversight — and it is also the main thing to argue about in an upstream PR.

Verified locally: the port builds and installs for `x64-linux-xclang`, and a
consumer builds `import httpant;` plus `import httpant.io;` against the installed
package. Building it needs the source, so a machine that cannot reach GitHub over
git sets `HTTPANT_GIT_URL` to a local checkout — the portfile honours it and
defaults to the GitHub URL.

## Path to `microsoft/vcpkg`

The official catalogue wants a tag, a tarball and a SHA512. `portfile.cmake`
carries the `vcpkg_from_github` block to swap in, commented, at the point of use.
When `httpant` starts tagging releases:

1. Tag `v0.2.0` in `httpant`.
2. Replace `vcpkg_from_git` with `vcpkg_from_github(REPO … REF "v${VERSION}"
   SHA512 <hash>)`; take the hash from vcpkg's own error message.
3. Run `vcpkg x-add-version httpant` against a `microsoft/vcpkg` checkout, which
   writes that repository's `versions/h-/httpant.json` — the git-tree entry here
   is for this registry and does not transfer.
4. Open the PR with `vcpkg install httpant` passing on the standard triplets.

Step 4 is the real gate: the official catalogue builds with its own compilers,
so an `xclang` requirement has to become either an `xclang` port or a documented
`supports` restriction. Plan for that conversation before promising upstream
availability.
