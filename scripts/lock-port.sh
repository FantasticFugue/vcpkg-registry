#!/usr/bin/env bash
# Records the current contents of one port in versions/ and moves the baseline.
#
#   ./scripts/lock-port.sh <port>
#
# The port's version comes from its own vcpkg.json. The git-tree is taken from the
# index, so stage the port (or let this do it) and commit ports/ together with
# versions/ — vcpkg verifies that tree when it resolves the port.
set -euo pipefail

port=${1:?usage: lock-port.sh <port>}
root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"

version=$(python3 - "$port" <<'PY'
import json, sys
data = json.load(open(f"ports/{sys.argv[1]}/vcpkg.json"))
for key in ("version", "version-semver", "version-date", "version-string"):
    if key in data:
        print(data[key]); break
else:
    sys.exit("port has no version field")
PY
)

git add "ports/${port}"
tree=$(git write-tree --prefix="ports/${port}")
prefix=$(printf '%s' "${port}" | cut -c1)

python3 - "$port" "$version" "$tree" "$prefix" <<'PY'
import json, pathlib, sys
port, version, tree, prefix = sys.argv[1:5]

versions = pathlib.Path(f"versions/{prefix}-/{port}.json")
versions.parent.mkdir(parents=True, exist_ok=True)
data = json.loads(versions.read_text()) if versions.exists() else {"versions": []}
data["versions"] = [v for v in data["versions"] if v["version"] != version] + [
    {"version": version, "port-version": 0, "git-tree": tree}
]
versions.write_text(json.dumps(data, indent=4) + "\n")

baseline = pathlib.Path("versions/baseline.json")
data = json.loads(baseline.read_text())
data.setdefault("default", {})[port] = {"baseline": version, "port-version": 0}
baseline.write_text(json.dumps(data, indent=4) + "\n")
print(f"{port} {version} -> {tree}")
PY
