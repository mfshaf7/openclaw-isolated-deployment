# openclaw-isolated-deployment Agent Notes

This repository is the reference architecture and isolated deployment model for
OpenClaw in this workspace.

It is not the active governed stage/prod build owner unless a pinned
environment contract explicitly points there.

## What This Repo Owns

- isolated deployment architecture docs
- deployment-model guidance
- reference workflows and model-scoped reference copies
- explanation of owner vs mirrored paths in the isolated design

## Read First

- `README.md`
- `docs/architecture-overview.md`
- `docs/repository-map.md`
- `docs/current-runtime-shape.md`
- `docs/workspace-sync-policy.md`
- `docs/release-workflow.md`
- `docs/workspace-template-ownership.md`

## Working Rules

- Prefer canonical-source fixes in the standalone owner repos first.
- Use this repo to explain the model, not to quietly regain ownership of the
  governed stage/prod build path.
- If docs here reference the active governed path, make sure they point to the
  current `openclaw-runtime-distribution` plus `platform-engineering` flow.
- If a reference copy is kept here, label it clearly as reference/model-scoped.

## Validation

- `./deployment/build-openclaw-local.sh`
- `./deployment/verify-telegram-router-contract.sh`
- `./deployment/verify-bridge-workspace.sh`
- `./deployment/verify-host-control-contract.sh`
