# OpenClaw Isolated Deployment

This repository is a reference implementation for running **OpenClaw in a truly isolated local environment** instead of collapsing the assistant, host control, and operator tooling into one machine with one trust boundary.

It exists to solve a specific problem:

- keep the OpenClaw runtime isolated from the daily-use workstation
- keep host-PC control behind a narrow, explicit bridge
- keep Telegram and other user-facing control surfaces deterministic enough for real operations
- document the whole system so another operator can reproduce it without inheriting local folklore

This is not just a scratchpad for one machine. The goal is an explainable, reusable deployment model with clear trust boundaries.

## Why This Repository Exists

The default local story for personal assistants is usually some variation of:

- install everything on the main workstation
- connect channels directly
- grant broad local execution
- debug problems live in production

That works quickly, but it muddies the trust boundary. The runtime, the host, the operator shell, and the user-facing surface become the same place.

This repository takes the opposite approach:

- **OpenClaw runtime** lives in an isolated Ubuntu VM
- **Operator workflow** lives in WSL on the Windows workstation
- **Host-PC control** goes through a separate `pc-control-bridge`
- **Telegram behavior** is tightened so host actions stay deterministic and auditable

That separation is the whole reason this repository exists.

## What This Repository Contains

```text
openclaw-isolated-deployment/
├── README.md
├── docs/
│   ├── architecture-overview.md
│   ├── repository-map.md
│   ├── local-deployment-guide.md
│   ├── wsl-codex-runbook.md
│   ├── security-architecture-review.md
│   ├── pc-control-openclaw-model.md
│   └── ...
├── deployment/
│   ├── build-checklist.md
│   └── vm-baseline.md
├── pc-control-bridge/
├── pc-control-openclaw-plugin/
├── openclaw-telegram-enhanced/
└── ...
```

## Repository Roles

The repository is intentionally split into separate subprojects with separate responsibilities.

| Path | Purpose |
| --- | --- |
| `pc-control-bridge/` | Narrow host-control bridge that enforces policy, allowed roots, audits, and controlled host operations. |
| `pc-control-openclaw-plugin/` | Typed OpenClaw plugin that exposes the bridge as approved tools instead of generic shell access. |
| `openclaw-telegram-enhanced/` | Bundled Telegram replacement that adds deterministic `pc-control` routing, screenshots, media delivery, and confirmation flows. |
| `docs/` | System documentation: architecture, rationale, operator runbooks, known issues, and security review. |
| `deployment/` | Deployment-specific guidance, checklists, and runtime-facing configuration notes. |

Read the full repo map here:
- [repository-map.md](docs/repository-map.md)

## Architecture

```mermaid
flowchart LR
    User[Telegram / Web UI / Operator] --> Gateway[OpenClaw Gateway in isolated Ubuntu VM]
    Gateway --> TG[Bundled Telegram override]
    Gateway --> PCP[pc-control OpenClaw plugin]
    PCP --> Bridge[pc-control bridge on Windows/WSL host]
    Bridge --> Host[Windows host resources]
    Operator[WSL operator workspace] --> Gateway
    Operator --> Bridge
```

The important part is not the specific products. It is the separation of duties:

- the **Gateway** orchestrates
- the **Telegram override** controls channel behavior
- the **plugin** translates typed assistant intent into allowed operations
- the **bridge** enforces host policy
- the **host** is never the trust anchor for OpenClaw itself

Read the detailed architecture here:
- [architecture-overview.md](docs/architecture-overview.md)

## Isolation Model

The supported deployment model in this repository is:

**Windows workstation -> WSL operator workspace -> isolated Ubuntu VM -> Docker-based OpenClaw runtime -> explicit bridge back to the Windows host for narrow PC control**

This model is chosen because it gives clear answers to questions like:

- Where does the assistant runtime live?
- Where do secrets live?
- Where does host file access actually happen?
- What is the audit point for host-control requests?
- What is allowed to touch the primary workstation directly?

## Design Principles

- **Isolation before convenience**: the runtime should not default to living on the main workstation.
- **Typed host control over raw shell**: host access should go through explicit operations with policy and audit.
- **Deterministic user flows**: Telegram should not hallucinate tool plans for sensitive host actions.
- **Documentation follows reality**: if the implementation changes, the docs change in the same work.
- **Clear by default**: docs should explain why the system exists, not assume private local context.

## Current Scope

This repository currently documents and implements:

- isolated OpenClaw deployment patterns
- host bridge enforcement for file, health, export, and monitor actions
- Telegram confirmation and deterministic routing for `pc-control`
- self-heal and runtime verification patterns for the host bridge

It does **not** claim to be:

- a full production HA platform
- a general replacement for upstream OpenClaw docs
- a public multi-tenant service template

## Start Here

For someone new to this repository, the right reading order is:

1. [architecture-overview.md](docs/architecture-overview.md)
2. [repository-map.md](docs/repository-map.md)
3. [local-deployment-guide.md](docs/local-deployment-guide.md)
4. [security-architecture-review.md](docs/security-architecture-review.md)
5. [pc-control-openclaw-model.md](docs/pc-control-openclaw-model.md)

If you are rebuilding the operator workstation, then use:
- [wsl-codex-runbook.md](docs/wsl-codex-runbook.md)

## Documentation Standard

In this repository, a fix is not complete until:

1. the implementation is updated
2. the relevant documentation is updated
3. the docs explain both the **what** and the **why**

That rule exists because this repository is meant to be useful to the next operator, not only the original one.
