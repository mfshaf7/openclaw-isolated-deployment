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
  - `host-control-openclaw-plugin/`
- `openclaw-host-bridge`
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
3. sync the intended runtime files into the deployment copy:

```bash
./deployment/sync-telegram-build-copy.sh
```

This sync helper copies only the shared runtime files used by the bundled image path. It does not overwrite the intentionally different deployment-copy files such as:

- `README.md`
- `package.json`
- `docs/`
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

1. make the source change in `openclaw-host-bridge`
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
./deployment/sync-telegram-build-copy.sh
./deployment/verify-workspace-sync.sh
./deployment/verify-telegram-router-contract.sh
./deployment/verify-bridge-workspace.sh
./deployment/verify-host-control-contract.sh
```

Or use the bundled wrapper:

```bash
./deployment/build-openclaw-local.sh
```

This wrapper:

1. syncs the Telegram build copy
2. runs both workspace verifiers
3. verifies that the exposed `host-control` tool surface does not leak scaffold-only bridge capabilities
4. builds the bundled image with the Telegram replacement

These checks are meant to fail fast if:

- the embedded Telegram build copy drifted from the standalone Telegram repo
- the Telegram deterministic router became too broad and started hijacking normal conversation
- junk like `node_modules/` is present in the embedded Telegram copy
- the deployment bridge folder stopped being documentation-only
- the standalone bridge repo is missing expected source directories
- the `host-control` plugin still exposes scaffold-only bridge operations such as browser inspection or zip export

## Required Verification After Build

After building and deploying, verify real behavior instead of only startup health:

1. Telegram plugin loads
2. `host-control` plugin loads
3. bridge is reachable from the gateway
4. one real read path works
5. one real send/export path works
6. one real mutating path works if enabled

## Bundled Image Build Command

The standard bundled image build path is:

```bash
./deployment/build-openclaw-local.sh
```

Optional environment overrides:

```bash
OPENCLAW_LOCAL_IMAGE_TAG=openclaw:local \
OPENCLAW_BASE_IMAGE=ghcr.io/openclaw/openclaw:latest \
./deployment/build-openclaw-local.sh
```

## What Not To Do

Do not:

- edit the deployment Telegram copy and forget the standalone Telegram repo
- treat the deployment bridge folder as the bridge source tree
- copy local state, logs, or `node_modules/` into tracked build inputs
- declare success from `/healthz` alone without a real operation check
