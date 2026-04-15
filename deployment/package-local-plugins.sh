#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
ARTIFACT_DIR="${OPENCLAW_PLUGIN_ARTIFACTS_DIR:-$ROOT/deployment/.build/plugin-artifacts}"

mkdir -p "$ARTIFACT_DIR"
rm -f "$ARTIFACT_DIR"/*.tgz

"$ROOT/deployment/sync-telegram-build-copy.sh" "$ROOT"
"$ROOT/deployment/verify-workspace-sync.sh" "$ROOT"
"$ROOT/deployment/verify-telegram-router-contract.sh" "$ROOT"
"$ROOT/deployment/verify-bridge-workspace.sh" "$ROOT"
"$ROOT/deployment/verify-host-control-contract.sh" "$ROOT"

echo
echo "Packaging managed OpenClaw plugins..."
echo "  output dir: $ARTIFACT_DIR"

plugins=(
  "$ROOT/openclaw-telegram-enhanced"
  "$ROOT/host-control-openclaw-plugin"
)

assert_packlist_is_publishable() {
  local plugin_root="$1"
  local pack_manifest
  pack_manifest="$(cd "$plugin_root" && npm pack --json --dry-run)"
  python3 - "$plugin_root" <<'PACKJSON' <<<"$pack_manifest"
import json
import sys

plugin_root = sys.argv[1]
entries = json.load(sys.stdin)
if not entries:
    raise SystemExit(f"npm pack --json --dry-run returned no entries for {plugin_root}")
files = [item.get('path', '') for item in entries[0].get('files', [])]
disallowed = sorted(
    path for path in files
    if path.startswith('test/')
    or '/test/' in path
    or path.startswith('__tests__/')
    or '.test.' in path
)
if disallowed:
    print(f"Managed plugin packlist for {plugin_root} includes non-runtime files:", file=sys.stderr)
    for path in disallowed:
        print(f"- {path}", file=sys.stderr)
    raise SystemExit(1)
PACKJSON
}

for plugin_root in "${plugins[@]}"; do
  if [[ ! -f "$plugin_root/package.json" ]]; then
    echo "Missing package.json for plugin package: $plugin_root" >&2
    exit 1
  fi
  assert_packlist_is_publishable "$plugin_root"
  (cd "$plugin_root" && npm pack --pack-destination "$ARTIFACT_DIR" >/dev/null)
done

echo "Packaged plugin artifacts:"
find "$ARTIFACT_DIR" -maxdepth 1 -type f -name '*.tgz' -printf '  %f\n' | sort
