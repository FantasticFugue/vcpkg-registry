# AGENTS.md — vcpkg registry

A registry is a version database, not a code repository. The rules follow from
that.

## Never edit what a consumer may have pinned

- A merged entry in `versions/h-/httpant.json` is immutable. vcpkg verifies the
  checked-out tree against `git-tree`; changing it changes what `baseline`
  consumers build, silently.
- `ports/httpant/portfile.cmake` must keep `HTTPANT_REF` in step with the newest
  versions entry. `scripts/add-version.sh` writes both; use it instead of editing
  by hand.
- Moving `versions/baseline.json` is a deliberate act: it changes the default
  version for everyone who tracks this registry's `main`.

## Adding a version

```sh
./scripts/add-version.sh <version> <commit>
vcpkg install httpant --overlay-ports=ports/httpant \
    --overlay-triplets=triplets --triplet x64-linux-xclang --dry-run
```

Commit the version bump on its own, so a consumer reading history can see which
httpant commit each registry commit refers to.

## Triplets

`triplets/` is part of the public interface. Changing a triplet changes how every
port in every consumer is built; treat it as a breaking change and note it in the
commit message.

## Upstream

The upstream PR is a copy of this port's logic, not a second opinion: when you
change `portfile.cmake` here, change the commented `vcpkg_from_github` block with
it, so the two never drift.
