# Release Workflow

## Purpose

This document defines the maintenance workflow for updating the multi-repo deployment without accidental drift.

It exists because the deployment model spans:

- a deployment workspace
- a standalone bridge repository
- a standalone Telegram repository

Without a release workflow, operators can update one layer and forget to align the rest.

## Repositories

Use these roles:

- `openclaw-isolated-deployment`
  - deployment docs
  - deployment image inputs
  - `pc-control-openclaw-plugin/`
- `pc-control-bridge`
  - canonical bridge runtime source
  - canonical bridge scripts, config examples, and tests
- `openclaw-telegram-enhanced`
  - canonical Telegram source and repo docs

## Standard Update Order

When changing behavior that spans repos, use this order:

1. update the canonical component repository first
2. verify that component in isolation where possible
3. sync the deployment workspace if it carries a build copy
4. run workspace verifiers
5. rebuild the deployment image if needed
6. run end-to-end checks
7. only then push or tag the full set

## Telegram Change Workflow

For Telegram changes:

1. make the source change in `openclaw-telegram-enhanced`
2. commit and verify it there
3. sync the intended runtime files into:
   - `openclaw-isolated-deployment/openclaw-telegram-enhanced/`
4. run:

```bash
./deployment/verify-workspace-sync.sh
```

5. rebuild the bundled image
6. verify a real Telegram path such as:
   - file send
   - screenshot send
   - button-confirmed action

## Bridge Change Workflow

For bridge changes:

1. make the source change in `pc-control-bridge`
2. verify the bridge there
3. run:

```bash
./deployment/verify-bridge-workspace.sh
```

This confirms the deployment workspace did not accidentally grow its own runnable bridge copy.

4. verify the host-side bridge and the gateway-to-bridge path end to end

## Deployment-Only Change Workflow

For deployment/docs/plugin changes that belong only to `openclaw-isolated-deployment`:

1. update the deployment repo
2. verify image inputs and docs
3. if Telegram source is involved, run the workspace sync verifier
4. if bridge ownership assumptions are involved, run the bridge workspace verifier

## Required Verification Before Build

Run:

```bash
./deployment/verify-workspace-sync.sh
./deployment/verify-bridge-workspace.sh
```

These checks are meant to fail fast if:

- the embedded Telegram build copy drifted from the standalone Telegram repo
- junk like `node_modules/` is present in the embedded Telegram copy
- the deployment bridge folder stopped being documentation-only
- the standalone bridge repo is missing expected source directories

## Required Verification After Build

After building and deploying, verify real behavior instead of only startup health:

1. Telegram plugin loads
2. `pc-control` plugin loads
3. bridge is reachable from the gateway
4. one real read path works
5. one real send/export path works
6. one real mutating path works if enabled

## What Not To Do

Do not:

- edit the deployment Telegram copy and forget the standalone Telegram repo
- treat the deployment bridge folder as the bridge source tree
- copy local state, logs, or `node_modules/` into tracked build inputs
- declare success from `/healthz` alone without a real operation check
