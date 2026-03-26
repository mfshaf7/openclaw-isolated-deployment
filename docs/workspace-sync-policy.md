# Workspace Sync Policy

## Purpose

This document defines how the multi-repo workspace stays aligned.

It exists because this deployment model intentionally spans more than one repository:

- `openclaw-isolated-deployment`
- `pc-control-bridge`
- `openclaw-telegram-enhanced`

Without a clear sync policy, operators can end up with a build workspace that looks correct in Git but does not actually match the intended runtime composition.

## Canonical Sources

Use these ownership rules:

- `openclaw-isolated-deployment`
  - deployment docs
  - architecture docs
  - operator runbooks
  - `pc-control-openclaw-plugin/`
  - bundled Telegram build copy under `openclaw-telegram-enhanced/`
- `pc-control-bridge`
  - runnable bridge source
  - bridge scripts
  - bridge config examples
  - bridge tests
- `openclaw-telegram-enhanced`
  - canonical Telegram source
  - Telegram repo docs
  - Telegram package metadata
  - Telegram standalone test/docs layout

## Important Distinction

The Telegram code appears in two places on purpose:

1. the standalone repository:
   - `~/projects/openclaw-telegram-enhanced`
2. the deployment workspace copy:
   - `~/projects/openclaw-isolated-deployment/openclaw-telegram-enhanced`

These two copies do not serve the same role:

- the standalone repo is the canonical source repository
- the deployment workspace copy is the image-build input used by the bundled Telegram replacement path

That means operators must keep them aligned deliberately.

## Safe Sync Rule

When updating Telegram source:

1. make the code/doc change in the standalone `openclaw-telegram-enhanced` repository first
2. verify it there
3. copy the intended runtime files into the deployment workspace copy
4. rebuild the bundled image from `openclaw-isolated-deployment`
5. verify behavior end to end

Do not treat the deployment workspace copy as an independent long-term fork unless that divergence is intentional and documented.

## Bridge Rule

The bridge does not follow the same duplication model.

For `pc-control-bridge`:

- the standalone repository is the runnable source tree
- the small `pc-control-bridge/` folder inside `openclaw-isolated-deployment` is documentation-oriented

Do not expect the deployment workspace copy to be enough to run or modify the bridge runtime.

## Reproducible Workspace Shape

```text
~/projects/
├── openclaw-isolated-deployment/
├── pc-control-bridge/
└── openclaw-telegram-enhanced/
```

## Before Building

Before producing a deployment image, confirm:

1. `pc-control-openclaw-plugin/` changes are committed in `openclaw-isolated-deployment`
2. `openclaw-telegram-enhanced` standalone changes are copied into the deployment workspace copy if needed
3. the bridge repository revision is the intended one for the host side
4. no local-only junk like `node_modules/`, temp logs, or host placeholder directories are being mistaken for source

## What Not To Sync Blindly

Do not blindly copy:

- `.git/`
- `node_modules/`
- local logs
- temporary audit data
- machine-specific config files
- local state or exported credentials

Only sync intentional source, docs, and build inputs.
