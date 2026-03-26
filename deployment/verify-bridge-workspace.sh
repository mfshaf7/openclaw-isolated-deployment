#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
PARENT="$(cd -- "$ROOT/.." && pwd)"
DEPLOY_BRIDGE="$ROOT/pc-control-bridge"
CANON_BRIDGE="${PC_CONTROL_BRIDGE_REPO:-$PARENT/pc-control-bridge}"

if [[ ! -d "$DEPLOY_BRIDGE" ]]; then
  echo "Missing deployment bridge folder: $DEPLOY_BRIDGE" >&2
  exit 1
fi

if [[ ! -d "$CANON_BRIDGE" ]]; then
  echo "Missing canonical bridge repo: $CANON_BRIDGE" >&2
  exit 1
fi

if [[ ! -f "$DEPLOY_BRIDGE/README.md" ]]; then
  echo "Expected bridge README not found in deployment workspace" >&2
  exit 1
fi

unexpected="$(
  find "$DEPLOY_BRIDGE" -mindepth 1 -maxdepth 1 ! -name 'README.md' -printf '%f\n' | sort
)"

if [[ -n "$unexpected" ]]; then
  echo "Unexpected files or directories found in deployment bridge folder:" >&2
  echo "$unexpected" >&2
  echo >&2
  echo "The deployment workspace bridge folder is documentation-oriented only." >&2
  echo "Runnable bridge code must stay in the standalone pc-control-bridge repository." >&2
  exit 1
fi

required_paths=(
  "$CANON_BRIDGE/src"
  "$CANON_BRIDGE/test"
  "$CANON_BRIDGE/config"
  "$CANON_BRIDGE/scripts"
)

missing=0
for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing expected bridge repo path: $path" >&2
    missing=1
  fi
done

if [[ $missing -ne 0 ]]; then
  echo >&2
  echo "Canonical bridge repo is incomplete." >&2
  exit 1
fi

echo "Bridge workspace verification passed."
echo "  deployment bridge folder: $DEPLOY_BRIDGE"
echo "  canonical bridge repo   : $CANON_BRIDGE"
