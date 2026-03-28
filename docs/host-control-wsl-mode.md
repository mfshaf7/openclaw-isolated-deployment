# Host Control WSL Mode

This document defines the current WSL-backed deployment mode for `host-control`.

## Scope

This mode is for:

- Windows host
- WSL2 installed
- OpenClaw running in an isolated container or VM
- host control provided by a WSL-backed `openclaw-host-bridge`

It is intentionally a **supported mode**, not a hidden local hack.

## Components

- ClawHub-style skill: `host-control`
- OpenClaw plugin: `host-control`
- Host bridge: `openclaw-host-bridge`
- Startup helpers in the standalone bridge repo:
  - `openclaw-host-bridge/scripts/start-openclaw-host-bridge.sh`
  - `openclaw-host-bridge/scripts/start-openclaw-host-bridge-daemon.sh`
  - `openclaw-host-bridge/scripts/start-openclaw-host-bridge-hidden.ps1`
  - `openclaw-host-bridge/scripts/register-openclaw-host-bridge-task.ps1`

## Prerequisites

- Windows 11 or recent Windows 10
- WSL2
- a Linux distro such as `Ubuntu`
- Node installed inside WSL for the bridge runtime
- OpenClaw gateway token available through the local OpenClaw state file
- Docker container able to reach the host bridge through `host.docker.internal`
- workspace layout that includes both:
  - `~/projects/openclaw-isolated-deployment`
  - `~/projects/openclaw-host-bridge`

## Supported trust model

- OpenClaw stays isolated
- the bridge is the trust boundary for host actions
- read-only operations are enabled first
- organize actions are optional
- export and browser inspection stay disabled by default

## Files to customize

### 1. Bridge policy

Start from:

- `openclaw-host-bridge/config/policy.wsl.example.json`

Customize:

- `allowed_roots`
- `staging_dir`
- `audit.dir`
- permission flags

### 2. WSL startup environment

The startup scripts support these environment variables:

- `HOST_CONTROL_ROOT`
- `HOST_CONTROL_BRIDGE_CONFIG`
- `HOST_CONTROL_NODE_BIN_DIR`
- `OPENCLAW_HOME`
- `OPENCLAW_CONFIG_PATH`

### 3. Windows launcher environment

The hidden launcher supports:

- `HOST_CONTROL_WSL_DISTRO`
- `HOST_CONTROL_ROOT`
- `HOST_CONTROL_WINDOWS_LAUNCHER`

## OpenClaw plugin profile

Install the plugin through the managed installer:

```bash
openclaw plugins install ./host-control-openclaw-plugin
```

That keeps `host-control` on the supported plugin-install path and avoids
untracked local plugin warnings.

Recommended starting profile:

```json
{
  "plugins": {
    "entries": {
      "host-control": {
        "enabled": true,
        "config": {
          "enabled": true,
          "bridgeUrl": "http://host.docker.internal:48721",
          "authTokenEnv": "OPENCLAW_GATEWAY_TOKEN",
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

For organize mode:

- set `allowWriteOperations: true`
- keep export and browser inspection off
- rely on `confirm: true` for mutating tool calls

## Positioning

This mode should be described as:

- `WSL-backed host bridge mode for Windows`

It should not be described as:

- native Windows service mode
- fully generic no-prerequisite host control

## Reproduction Notes

This mode is reproducible only if the standalone bridge repository is used as the runnable source tree.

That means:

- deployment and docs come from `openclaw-isolated-deployment`
- bridge scripts, config examples, and bridge runtime come from `openclaw-host-bridge`
- the OpenClaw plugin continues to come from `openclaw-isolated-deployment/host-control-openclaw-plugin`

## Known limitations

- requires WSL
- bridge lifecycle on Windows logon still depends on the local task/launcher path being validated in the target environment
- browser inspection is not complete
- export flow is not complete

## What makes this mode coherent

- no OpenClaw core drift
- host-specific values are configurable
- runtime scripts are documented
- the mode is explicit about prerequisites and limits
