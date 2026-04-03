# Workspace Template Ownership

## Purpose

This document defines when a runtime workspace template belongs in `openclaw-isolated-deployment`.

## Rule

If a workspace must exist inside the bundled runtime image for production behavior to be correct, the template belongs in this repository.

Examples:

- dedicated topic/agent workspaces
- tracked skill files required by those workspaces
- deployment-specific `AGENTS.md` files that shape runtime behavior

These templates are deployment content, not plugin implementation details.

## Current tracked templates

- `deployment/workspaces/security-architecture/`

Materialized runtime target:

- `/home/node/.openclaw/workspace-security-architecture/`

## Why this repo owns them

This repository already owns:

- bundled gateway image composition
- deployment-specific runtime content
- Docker build inputs for production artifacts

That makes it the correct place to define workspaces that must be present in the final image.

## What does not belong here

Do not place these here unless they are required deployment content:

- generic Telegram plugin source logic
- prod digest metadata
- Argo promotion records
- host-only runtime state

## Build contract

If a workspace template is required for runtime correctness:

1. track it under `deployment/workspaces/`
2. copy it into the image in `deployment/Dockerfile.telegram-bundled.example`
3. enforce its presence from `platform-engineering` source-bundle validation

## Operational rule

Live edits under `~/.openclaw` are not an acceptable final state for deployment-owned workspaces.

If a workspace repair is first done live for recovery, the incident is not complete until:

- the template is tracked here
- the image is rebuilt
- the new digest is promoted through `platform-engineering`
