# Current Runtime Shape

This document records the current deployment shape that has been validated in
the live environment.

It is intentionally sanitized. It describes the runtime structure another
operator should reproduce, without embedding operator-specific secrets, tokens,
or personal filesystem details.

## Current Live Shape

The current deployment is operating as:

- one healthy `openclaw:local` gateway container
- bundled Telegram runtime loaded from `/app/extensions/telegram`
- OpenClaw state bind-mounted into the container from the host OpenClaw home
- OpenClaw workspace bind-mounted into the container from the same host state tree
- host control handled by a separate WSL-backed bridge stack
- Windows logon startup handled by `PlatformCoreHostStack`
- WSL `systemd` owns the host bridge and recovery services inside `Platform-Core`

## Container Runtime Shape

Current validated assumptions:

- the main runtime is the gateway container
- Telegram is bundled into the image/runtime plugin directory, not installed ad hoc at runtime
- host-facing operations use the `host-control` path rather than generic container-local shell access
- the gateway uses authenticated requests when calling the bridge and recovery endpoints

What should be reproducible:

- container image tag equivalent to `openclaw:local`
- bundled Telegram replacement present
- OpenClaw state mounted into the container
- gateway health and plugin load working before host-control validation begins

## Host-Side Runtime Shape

Current validated assumptions:

- Windows host runs the `PlatformCoreHostStack` scheduled task
- that task launches WSL and starts `openclaw-host-stack.target`
- `systemd` inside WSL starts:
  - `openclaw-host-bridge.service`
  - `openclaw-host-recovery.service`
- recovery can restart/repair the bridge without rebuilding the runtime image

## Runtime Paths That Matter

These paths matter conceptually and should exist in equivalent form:

- host OpenClaw home directory
- host OpenClaw workspace directory
- bundled Telegram runtime directory inside the container
- standalone `openclaw-host-bridge` source repo in the operator workspace
- standalone `openclaw-telegram-enhanced` source repo in the operator workspace
- deployment workspace copy of `openclaw-telegram-enhanced` used for bundled image builds

This document does not freeze operator-specific absolute paths. Use equivalent
paths in another environment.

## Verification Standard

A reproduced deployment should validate all of:

1. gateway container healthy
2. bundled Telegram runtime loaded
3. bridge `/healthz` reachable from the gateway
4. recovery `/healthz` reachable from the gateway
5. `host status` works in the host-control Telegram topic
6. `self heal` works in the host-control Telegram topic
7. Windows logon/startup path brings back the host stack after restart

## What Stays Local

The following should remain local and should not be committed:

- gateway auth tokens
- recovery/bridge auth tokens when represented as raw values
- operator-specific filesystem paths
- local OpenClaw config values that identify a personal environment
- live proposal stores, session logs, and audit output

## Relationship To The Other Repositories

- `openclaw-isolated-deployment` documents the full deployment shape
- `openclaw-host-bridge` owns the runnable host bridge and recovery scripts
- `openclaw-telegram-enhanced` owns the canonical Telegram runtime source

When the live deployment is patched directly, all relevant changes must be
backported into the appropriate source repo and the deployment workspace copy.
