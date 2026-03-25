# PC Control OpenClaw Plugin

This plugin exposes typed OpenClaw tools that forward approved operations to the `pc-control-bridge`.

Install it through:

```bash
openclaw plugins install ./pc-control-openclaw-plugin
```

Using the managed installer is the supported clean path because it writes
`plugins.installs` provenance records. Avoid copying this plugin into
`~/.openclaw/extensions` by hand for long-lived deployments.

For a containerized OpenClaw runtime talking to a Windows-side or WSL-side
bridge, the usual bridge URL is:

- `http://host.docker.internal:48721`

## Default behavior

The plugin is designed for a balanced deployment posture:

- read-only tools are available by default
- write tools are hidden unless explicitly enabled
- export tools are hidden unless explicitly enabled
- browser tab inspection is hidden unless explicitly enabled

This keeps normal host insight smooth without turning host control into unrestricted remote execution.

## Tool groups

Read-only by default:

- `pc_control_health_check`
- `pc_control_fs_list`
- `pc_control_fs_search`
- `pc_control_fs_read_meta`
- `pc_control_browser_tabs_list`

Hidden until `allowWriteOperations: true`:

- `pc_control_fs_mkdir`
- `pc_control_fs_move`

When enabled, these still require `confirm: true` in the tool call.

Hidden until `allowExportOperations: true`:

- `pc_control_zip_for_export`
- `pc_control_stage_for_telegram`

When enabled, these still require `confirm: true` in the tool call.

Hidden until `allowBrowserInspect: true`:

- `pc_control_browser_tab_inspect`

When enabled, this still requires `confirm: true` in the tool call.

## Example config

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
          "allowExportOperations": false,
          "allowBrowserInspect": false
        }
      }
    }
  }
}
```

The bridge token should be supplied through the environment variable named by
`authTokenEnv`.

Write tools can be enabled for organize mode, but they still require `confirm: true` in the tool call.
