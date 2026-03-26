#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
PARENT="$(cd -- "$ROOT/.." && pwd)"
DEPLOY_TG="$ROOT/openclaw-telegram-enhanced"
CANON_TG="${OPENCLAW_TELEGRAM_REPO:-$PARENT/openclaw-telegram-enhanced}"

if [[ ! -d "$DEPLOY_TG" ]]; then
  echo "Missing deployment Telegram copy: $DEPLOY_TG" >&2
  exit 1
fi

if [[ ! -d "$CANON_TG" ]]; then
  echo "Missing canonical Telegram repo: $CANON_TG" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

build_manifest() {
  local base="$1"
  (
    cd "$base"
    find . -type f \
      ! -path './.git/*' \
      ! -path './docs/*' \
      ! -path './node_modules/*' \
      ! -name 'README.md' \
      ! -name 'package.json' \
      ! -name '.gitignore' \
      ! -name 'LICENSE' \
      ! -name 'CONTRIBUTING.md' \
      | sort
  )
}

build_manifest "$DEPLOY_TG" >"$tmpdir/deploy.manifest"
build_manifest "$CANON_TG" >"$tmpdir/canon.manifest"

echo "Comparing shared Telegram source trees"
echo "  deployment copy: $DEPLOY_TG"
echo "  canonical repo : $CANON_TG"
echo

if ! diff -u "$tmpdir/deploy.manifest" "$tmpdir/canon.manifest"; then
  echo
  echo "Shared file list differs. Sync is not safe." >&2
  exit 1
fi

failed=0
while IFS= read -r rel; do
  if ! cmp -s "$DEPLOY_TG/$rel" "$CANON_TG/$rel"; then
    echo "Content differs: $rel" >&2
    failed=1
  fi
done <"$tmpdir/deploy.manifest"

if find "$DEPLOY_TG" -path '*/node_modules/*' -o -name 'node_modules' | grep -q .; then
  echo "Unexpected node_modules found in deployment Telegram copy" >&2
  failed=1
fi

if [[ $failed -ne 0 ]]; then
  echo
  echo "Workspace sync verification failed." >&2
  exit 1
fi

echo "Workspace sync verification passed."
echo "Allowed differences intentionally ignored:"
echo "  README.md"
echo "  package.json"
echo "  docs/"
echo "  .gitignore"
echo "  LICENSE"
echo "  CONTRIBUTING.md"
