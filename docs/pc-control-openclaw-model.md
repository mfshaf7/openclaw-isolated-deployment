# PC Control OpenClaw Model

## Purpose

This document defines how the current OpenClaw deployment should evolve to support `pc-control` without collapsing the isolation boundary.

It is intentionally balanced:

- useful for the operator
- conservative where risk changes materially
- not so strict that normal read-only actions become annoying

## Current state

The current deployment has:

- isolated OpenClaw runtime in a VM/container
- Telegram as the primary user-facing control channel
- allowlist-based exec posture
- no official Windows host companion path for this deployment model

That means host-PC control must not be modeled as a normal OpenClaw local capability.

## Recommended target state

### 1. OpenClaw remains the orchestrator

OpenClaw should:

- receive the user's request
- decide whether `pc-control` applies
- call a typed adapter surface
- present approvals and summaries

OpenClaw should not become the direct host enforcement point.

### 2. The host bridge is the enforcement point

The Windows `openclaw-host-bridge` should own:

- operation allowlist
- path restrictions
- export restrictions
- audit logging
- authentication

### 3. The user experience should be tiered

#### Tier A: Smooth read-only experience

Should feel close to immediate:

- health checks
- file listing
- file search
- metadata inspection

#### Tier B: Deliberate file changes

Should require a clear preview and confirmation:

- folder creation
- moving or organizing files

#### Tier C: Deliberate export

Should require the clearest confirmation:

- zipping files for export
- sending/staging files for Telegram

## Recommended OpenClaw-side implementation

The preferred OpenClaw-side shape is a **typed adapter**, not raw transport access.

Recommended operations:

- `pc_control.health_check`
- `pc_control.fs_list`
- `pc_control.fs_search`
- `pc_control.fs_read_meta`
- `pc_control.fs_mkdir`
- `pc_control.fs_move`
- `pc_control.stage_for_telegram`

These can be implemented by:

- an OpenClaw plugin tool, or
- an MCP adapter that forwards to the bridge

## Why this is better than raw shell

- easier to reason about in a security review
- easier to audit
- easier to maintain as a reusable pattern
- lower operator burden for read-only actions
- lower blast radius if the model makes a bad call

## Recommended runtime posture changes

### Keep as-is

- isolated container/VM deployment
- Telegram DM approvals
- no public exposure
- `tools.elevated.enabled: false`

### Adjust over time

- add a dedicated `pc_control` adapter path instead of trying to force host access through generic `exec`
- keep `commands.nativeSkills` enabled so `/skill pc-control` remains easy to invoke
- do not treat `tools.exec.host: node` as the host-PC control path unless a real paired node exists
- consider sandbox hardening after the host bridge exists, but do not introduce friction prematurely

## Recommended plugin profile

The OpenClaw-side adapter should be enabled with a low-friction default profile:

```json
{
  "plugins": {
    "entries": {
      "pc-control": {
        "enabled": true,
        "config": {
          "enabled": true,
          "bridgeUrl": "http://127.0.0.1:48721",
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

This profile keeps the useful read-only tools visible:

- `pc_control_health_check`
- `pc_control_fs_list`
- `pc_control_fs_search`
- `pc_control_fs_read_meta`

And it keeps higher-risk tools hidden until they are deliberately enabled.

## Recommended current deployment stance

For the current isolated deployment, the balanced recommendation is:

- keep generic `exec` available for container-local administration
- do not present generic `exec` as the normal path for host-PC actions
- use `pc-control` for host insight and later host organization/export
- enable write operations only after the bridge policy is tested on the real Windows host
- enable export only after file-send and screenshot paths are proven on the real bridge

Scaffold-only bridge features such as browser tab inspection and zip export must stay hidden from the plugin surface until the bridge implements them fully and they have their own tests.

This avoids the two common failure modes:

- making the system too strict to be useful
- making host access so broad that the isolation story becomes mostly cosmetic

## Security posture statement

The right posture for this deployment is not "maximum restriction everywhere."

It is:

- strict trust boundaries
- narrow host capabilities
- low-friction read-only operations
- explicit confirmation where risk changes
- no hidden local-environment hacks

## Next implementation step

Build the OpenClaw-side adapter that maps typed `pc-control` actions to the host bridge, then test the flow with read-only operations first.
