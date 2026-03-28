# OpenClaw Update Notes

## Purpose

This document records how the isolated deployment tracks upstream OpenClaw and what must be checked when the base runtime is updated.

It exists because this workspace is not a stock upstream deployment. The runtime has local deployment layers that must be preserved deliberately during upgrades.

## Current Baseline

- pinned OpenClaw base: `v2026.3.23-2`
- current local image: `openclaw:local`

## Local Runtime Shape

The current deployment shape is:

- upstream OpenClaw as the base runtime
- bundled Telegram replacement in the image
- managed `pc-control` plugin install
- authenticated gateway with rate limiting
- Windows firewall as part of the practical host exposure boundary

## Local Change Areas To Recheck During Updates

These are the places where updates can affect this deployment model:

- bundled Telegram replacement behavior
- `pc-control` plugin compatibility
- bridge reachability and auth assumptions
- local media handling for `pc_control_*` flows
- build-time behavior in the local image path

Known local core-touch points currently include:

- `extensions/telegram/src/*`
- `src/agents/pi-embedded-subscribe.tools.ts`
- `scripts/tsdown-build.mjs`

## Deployment-Specific Components

- Telegram override workspace copy:
  - [openclaw-telegram-enhanced](../openclaw-telegram-enhanced)
- managed OpenClaw plugin:
  - [pc-control-openclaw-plugin](../pc-control-openclaw-plugin)
- host enforcement layer:
  - [openclaw-host-bridge](../openclaw-host-bridge)

Canonical source-of-truth split:

- `pc-control-openclaw-plugin/` is maintained in this repository
- `openclaw-host-bridge/` runtime source is maintained in the standalone bridge repository
- `openclaw-telegram-enhanced/` runtime source is maintained in the standalone Telegram repository, with a deployment copy kept here for bundled image builds

## Upgrade Approach

When updating the base runtime:

1. start from a stable upstream tag, not a moving branch
2. rebuild the image with the bundled Telegram replacement
3. verify the managed `pc-control` plugin still loads
4. verify bridge reachability from the gateway
5. verify at least one real Telegram host-control action, not just health endpoints

Standard build path:

```bash
./deployment/build-openclaw-local.sh
```

## Minimum Verification After An Update

The minimum acceptable verification set is:

- Windows-side gateway health works
- Telegram plugin loads
- `pc-control` plugin loads
- bridge health works from the gateway container
- Telegram screenshot still works
- Telegram file send still works
- deterministic `pc-control` routing still works
- host firewall controls are still present if the runtime still depends on them

## Current Direction

The preferred long-term direction remains:

- keep more host behavior in the `pc-control` bridge/plugin layers
- keep Telegram-specific behavior in the Telegram replacement
- keep direct core-touching changes as small and reviewable as possible

## Notes

This document should be updated whenever the local runtime baseline changes or when a new upstream version requires deployment-specific adaptation.
