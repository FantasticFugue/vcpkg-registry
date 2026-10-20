#!/usr/bin/env bash
# Records a new httpant version in this registry.
#
#   ./scripts/add-version.sh 0.2.0 <commit>
#
# Updates, in one commit's worth of changes:
#   ports/httpant/vcpkg.json     version / port-version
#   ports/httpant/portfile.cmake HTTPANT_REF
#   versions/h-/httpant.json     the git-tree vcpkg will verify
#   versions/baseline.json       the version the registry defaults to
#
# The git-tree is read from the httpant checkout, which defaults to the sibling
# directory and can be overridden with HTTPANT_SRC.
set -euo pipefail

port=httpant
version=${1:?usage: add-version.sh <version> <commit>}
commit=${2:?usage: add-version.sh <version> <commit>}
src=${HTTPANT_SRC:-../httpant}
root=$(cd "$(dirname "$0")/.." && pwd)

# Two hashes, two meanings: `sha` pins the upstream source in the portfile, and
# `tree` is what vcpkg verifies when it reads this registry — the tree of the
# *port directory* in this repository's history, taken from the index so a port
# change and its version entry can land in one commit.
sha=$(git -C "$src" rev-parse "$commit")
git -C "$root" add "ports/${port}"
tree=$(git -C "$root" write-tree --prefix="ports/${port}")
cd "$root"

python3 - "$version" "$sha" "$tree" <<'PY'
import json, pathlib, re, sys
version, sha, tree = sys.argv[1:4]

manifest = pathlib.Path("ports/httpant/vcpkg.json")
data = json.loads(manifest.read_text())
data["version"] = version
manifest.write_text(json.dumps(data, indent=4) + "\n")

portfile = pathlib.Path("ports/httpant/portfile.cmake")
text = portfile.read_text()
text, n = re.subn(r'set\(HTTPANT_REF "[0-9a-f]+"\)', f'set(HTTPANT_REF "{sha}")', text)
if n != 1:
    sys.exit("portfile: HTTPANT_REF not found")
portfile.write_text(text)

entry = {"version": version, "port-version": 0, "git-tree": tree}
versions = pathlib.Path("versions/h-/httpant.json")
data = json.loads(versions.read_text())
data["versions"] = [v for v in data["versions"] if v["version"] != version] + [entry]
versions.write_text(json.dumps(data, indent=4) + "\n")

baseline = pathlib.Path("versions/baseline.json")
data = json.loads(baseline.read_text())
data["default"]["httpant"] = {"baseline": version, "port-version": 0}
baseline.write_text(json.dumps(data, indent=4) + "\n")
print(f"httpant {version} -> {sha[:12]} (tree {tree[:12]})")
PY

cat <<MSG

Now verify, then commit:

    vcpkg install ${port} --overlay-ports=ports/${port} --x-manifest-root=examples

Consumers pick this registry up by \`baseline\` — see README.md.
MSG
