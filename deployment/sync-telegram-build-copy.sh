#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
PARENT="$(cd -- "$ROOT/.." && pwd)"
SRC="${OPENCLAW_TELEGRAM_REPO:-$PARENT/openclaw-telegram-enhanced}"
DST="$ROOT/openclaw-telegram-enhanced"

if [[ ! -d "$SRC" ]]; then
  echo "Missing canonical Telegram repo: $SRC" >&2
  exit 1
fi

if [[ ! -d "$DST" ]]; then
  echo "Missing deployment Telegram copy: $DST" >&2
  exit 1
fi

copy_paths=(
  allow-from.ts
  api.ts
  index.ts
  openclaw.plugin.json
  package-lock.json
  package.json
  runtime-api.ts
  setup-entry.ts
  src
  tsconfig.host-control-check.json
)

echo "Syncing Telegram build copy"
echo "  source      : $SRC"
echo "  destination : $DST"
echo

rm -rf "$DST/node_modules"

for rel in "${copy_paths[@]}"; do
  if [[ ! -e "$SRC/$rel" ]]; then
    echo "Missing required source path: $SRC/$rel" >&2
    exit 1
  fi
done

for rel in "${copy_paths[@]}"; do
  rm -rf "$DST/$rel"
  mkdir -p "$(dirname "$DST/$rel")"
  cp -a "$SRC/$rel" "$DST/$rel"
done

echo "Sync completed."
echo
"$ROOT/deployment/verify-workspace-sync.sh" "$ROOT"
