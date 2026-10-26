# AGENTS.md — vcpkg ports

Consumers use the current `ports/` directory through `overlay-ports`.
The httpant port installs the current sibling `../httpant` source tree.
Keep package source changes in httpant and packaging changes here.

## Existing versions

Update the current port and its existing version entry. Run
`./add-port-version <port>` to refresh that entry's `git-tree`; the helper
preserves the version and revision and stages the port directory.
Creating versions requires explicit user approval.

## Cache inputs

Triplets include `httpant-source.cmake` so current httpant source files
participate in the package cache key. Keep that input list aligned with the
files installed by the port.

## Validation

Use the consumer's existing build directory and its selected validation
channel. Reuse completed checks when their inputs are unchanged.
Read `README.md` for the workspace layout and consumer configuration.
