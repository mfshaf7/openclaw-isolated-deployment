#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
PARENT="$(cd -- "$ROOT/.." && pwd)"
PLUGIN_TOOLS="$ROOT/pc-control-openclaw-plugin/src/tools.mjs"
PLUGIN_TESTS="$ROOT/pc-control-openclaw-plugin/test/tools.test.mjs"
PLUGIN_CONFIG_TESTS="$ROOT/pc-control-openclaw-plugin/test/config.test.mjs"
CANON_BRIDGE="${PC_CONTROL_BRIDGE_REPO:-$PARENT/pc-control-bridge}"
BRIDGE_BROWSER_OPS="$CANON_BRIDGE/src/ops/browser.mjs"
BRIDGE_FS_OPS="$CANON_BRIDGE/src/ops/fs.mjs"

required_paths=(
  "$PLUGIN_TOOLS"
  "$PLUGIN_TESTS"
  "$PLUGIN_CONFIG_TESTS"
  "$CANON_BRIDGE"
  "$BRIDGE_BROWSER_OPS"
  "$BRIDGE_FS_OPS"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required path: $path" >&2
    exit 1
  fi
done

echo "Verifying pc-control contract surface"
echo "  plugin tools : $PLUGIN_TOOLS"
echo "  bridge repo  : $CANON_BRIDGE"
echo

if rg -n 'pc_control_browser_tab_inspect|pc_control_browser_tabs_list|pc_control_zip_for_export' "$PLUGIN_TOOLS" >/dev/null; then
  echo "Scaffold-only tool name still exposed in plugin surface" >&2
  exit 1
fi

if rg -n 'browser\\.tabs\\.inspect|browser\\.tabs\\.list|fs\\.zip_for_export' "$PLUGIN_TOOLS" >/dev/null; then
  echo "Plugin still references scaffold-only bridge operations" >&2
  exit 1
fi

if ! rg -n 'not implemented yet in the scaffold' "$BRIDGE_BROWSER_OPS" "$BRIDGE_FS_OPS" >/dev/null; then
  echo "Expected scaffold markers were not found in bridge sources" >&2
  exit 1
fi

node "$PLUGIN_TESTS"
node "$PLUGIN_CONFIG_TESTS"
node --test "$CANON_BRIDGE"/test/*.test.mjs

echo
echo "pc-control contract verification passed."
echo "Scaffold-only bridge operations remain hidden from the plugin surface."
