# Workspace Sync Policy

## Purpose

This document defines how the multi-repo workspace stays aligned.

It exists because this deployment model intentionally spans more than one repository:

- `openclaw-isolated-deployment`
- `openclaw-host-bridge`
- `openclaw-telegram-enhanced`

Without a clear sync policy, operators can end up with a build workspace that looks correct in Git but does not actually match the intended runtime composition.

## Canonical Sources

Use these ownership rules:

- `openclaw-isolated-deployment`
  - deployment docs
  - architecture docs
  - operator runbooks
  - `host-control-openclaw-plugin/`
  - bundled Telegram build copy under `openclaw-telegram-enhanced/`
- `openclaw-host-bridge`
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
3. sync the intended runtime files into the deployment workspace copy:

```bash
./deployment/sync-telegram-build-copy.sh
```

This sync helper copies only the shared Telegram runtime files and leaves the intentionally different repo-level files alone.
4. rebuild the bundled image from `openclaw-isolated-deployment`
5. verify behavior end to end

Do not treat the deployment workspace copy as an independent long-term fork unless that divergence is intentional and documented.

## Verification Command

Before building, run:

```bash
./deployment/sync-telegram-build-copy.sh
./deployment/verify-workspace-sync.sh
./deployment/verify-telegram-router-contract.sh
./deployment/verify-bridge-workspace.sh
./deployment/verify-host-control-contract.sh
```

This verifier checks the shared Telegram source tree between:

- `openclaw-isolated-deployment/openclaw-telegram-enhanced`
- the standalone `openclaw-telegram-enhanced` repository next to it

It intentionally ignores allowed differences such as:

- `README.md`
- `package.json`
- `docs/`
- `.gitignore`
- `LICENSE`
- `CONTRIBUTING.md`

It also fails if unwanted junk such as `node_modules/` is present in the deployment copy.

## Bridge Rule

The bridge does not follow the same duplication model.

For `openclaw-host-bridge`:

- the standalone repository is the runnable source tree
- the small `openclaw-host-bridge/` folder inside `openclaw-isolated-deployment` is documentation-oriented

Do not expect the deployment workspace copy to be enough to run or modify the bridge runtime.

Use:

```bash
./deployment/verify-bridge-workspace.sh
```

This verifier ensures:

- the deployment bridge folder remains documentation-only
- the standalone bridge repo exists next to the deployment workspace
- the standalone bridge repo still contains the expected runtime source directories

## Reproducible Workspace Shape

```text
~/projects/
├── openclaw-isolated-deployment/
├── openclaw-host-bridge/
└── openclaw-telegram-enhanced/
```

## Before Building

Before producing a deployment image, confirm:

1. `host-control-openclaw-plugin/` changes are committed in `openclaw-isolated-deployment`
2. `openclaw-telegram-enhanced` standalone changes are synced into the deployment workspace copy if needed
3. the Telegram deterministic router still requires explicit host-scoped intent and does not hijack normal chat
4. the bridge repository revision is the intended one for the host side
5. scaffold-only bridge capabilities are still hidden from the `host-control` plugin surface
6. no local-only junk like `node_modules/`, temp logs, or host placeholder directories are being mistaken for source

## What Not To Sync Blindly

Do not blindly copy:

- `.git/`
- `node_modules/`
- local logs
- temporary audit data
- machine-specific config files
- local state or exported credentials

Only sync intentional source, docs, and build inputs.

## Release Workflow

For the end-to-end update sequence, read:

- [release-workflow.md](release-workflow.md)
