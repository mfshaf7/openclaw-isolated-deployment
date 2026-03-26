# pc-control OpenClaw Plugin

This plugin exposes the host bridge as **typed OpenClaw tools**.

It exists so OpenClaw can work with host-PC operations through a narrow, explicit adapter instead of relying on generic shell execution or channel-specific hacks.

## Why This Exists

In the isolated deployment model:

- OpenClaw runtime lives in an isolated VM/container
- host-PC access is enforced by `pc-control-bridge`
- user-facing channels such as Telegram need predictable tool behavior

This plugin is the contract between OpenClaw and the bridge.

## Architecture Role

```mermaid
flowchart LR
    Gateway[OpenClaw Gateway]
    Plugin[pc-control plugin]
    Bridge[pc-control bridge]
    Host[Windows host]

    Gateway --> Plugin --> Bridge --> Host
```

The plugin translates assistant intent into typed bridge calls with explicit permission groupings and confirmation semantics.

## What The Plugin Does

It provides:

- bridge-backed OpenClaw tools
- confirmation policy handling
- path normalization and alias rewrites
- Telegram-friendly media results for file export and screenshots
- bridge and recovery client wiring

It does **not** own:

- host path enforcement
- audit logging
- channel rendering policy

Those belong to the bridge and channel layers.

## Tool Groups

### Read-only by default

- `pc_control_health_check`
- `pc_control_find_in_allowed_roots`
- `pc_control_fs_list`
- `pc_control_list_host_folder`
- `pc_control_fs_search`
- `pc_control_find_host_files`
- `pc_control_fs_read_meta`

### Hidden until `allowWriteOperations: true`

- `pc_control_fs_mkdir`
- `pc_control_fs_move`

### Hidden until `allowExportOperations: true`

- `pc_control_stage_for_telegram`
- `pc_control_send_file_to_telegram`
- `pc_control_capture_desktop_screenshot`
- `pc_control_send_desktop_screenshot_to_telegram`

## Example Config

```json
{
  "plugins": {
    "entries": {
      "pc-control": {
        "enabled": true,
        "config": {
          "enabled": true,
          "bridgeUrl": "http://host.docker.internal:48721",
          "authTokenEnv": "PC_CONTROL_BRIDGE_TOKEN",
          "timeoutMs": 10000,
          "allowWriteOperations": false,
          "allowAdminOperations": false,
          "allowExportOperations": false,
          "allowBrowserInspect": false
        }
      }
    }
  }
}
```

The bridge token should come from the environment variable named by `authTokenEnv`.

## Install

Use the managed installer path:

```bash
openclaw plugins install ./pc-control-openclaw-plugin
```

That keeps plugin provenance under OpenClaw’s normal install records instead of relying on ad hoc copies.

## Operational Model

This plugin is designed around three ideas:

1. read-only host insight should be easy
2. mutating host actions should be deliberate
3. export to Telegram should stay separate from ordinary file organization

That is why the plugin is split across read, organize, export, browser-inspect, and admin-style actions.
That is why the plugin is split across read, organize, and export actions.

Scaffold-only bridge capabilities such as browser inspection and zip export are intentionally not exposed here until the bridge implements them fully and they have their own tests.

## Tests

Tests live under:

- [config.test.mjs](test/config.test.mjs)
- [tools.test.mjs](test/tools.test.mjs)

Run:

```bash
node test/config.test.mjs
node test/tools.test.mjs
```

## Related Documents

- [README.md](../pc-control-bridge/README.md)
- [README.md](../openclaw-telegram-enhanced/README.md)
- [pc-control-openclaw-model.md](../docs/pc-control-openclaw-model.md)
- [architecture-overview.md](../docs/architecture-overview.md)
