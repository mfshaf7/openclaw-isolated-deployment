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

for plugin_root in "${plugins[@]}"; do
  if [[ ! -f "$plugin_root/package.json" ]]; then
    echo "Missing package.json for plugin package: $plugin_root" >&2
    exit 1
  fi
  (cd "$plugin_root" && npm pack --pack-destination "$ARTIFACT_DIR" >/dev/null)
done

echo "Packaged plugin artifacts:"
find "$ARTIFACT_DIR" -maxdepth 1 -type f -name '*.tgz' -printf '  %f\n' | sort
