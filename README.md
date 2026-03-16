# openclaw-isolated-deployment

Privacy-first deployment workspace for building, troubleshooting, and documenting an **isolated local OpenClaw deployment**.

This repository is opinionated on purpose. It does not treat OpenClaw as a quick local install on the primary workstation. It treats it as a system that should be:

- isolated from the daily-use host
- documented as it is built
- reproducible after failure or rebuild
- honest about errors, assumptions, and non-goals
- structured for later publication on GitHub

## Deployment standard used here

The baseline used by this repository is fixed as follows:

- **Workspace root:** `~/projects`
- **Project root:** `~/projects/openclaw-isolated-deployment`
- **Primary host:** Windows workstation with WSL Ubuntu for documentation and Codex CLI workflow
- **Deployment target:** dedicated Ubuntu virtual machine
- **Runtime:** Docker-based OpenClaw deployment inside the VM
- **Networking:** NAT or host-only with minimal forwarding only
- **Access path:** host browser to localhost-style forwarded port
- **Exposure level:** no public exposure during the local phase
- **Secrets handling:** real values stored only inside the VM, never in source control

This repository exists to support that exact model.

## Repository operating rule

For this project, **a fix is not complete until the documentation is updated too**.

Every meaningful change in approach should result in two updates:

1. the issue log is updated with the failure, diagnosis, and fix
2. the authoritative guide is updated so the known-good path stays current

This prevents the repository from drifting away from reality.

## Repository structure

```text
.
├── README.md
├── .gitignore
├── docs/
│   ├── local-deployment-guide.md
│   ├── wsl-codex-runbook.md
│   ├── deployment-issues.md
│   ├── architecture-notes-template.md
│   └── production-migration-notes.md
├── deployment/
│   ├── .env.example
│   ├── build-checklist.md
│   ├── docker-compose.override.example.yml
│   └── vm-baseline.md
└── evidence/
    ├── screenshots/
    ├── logs/
    └── validation-notes/
```

## Start order

1. Follow [`docs/wsl-codex-runbook.md`](docs/wsl-codex-runbook.md) to prepare the Windows + WSL + Codex CLI workspace.
2. Fill in [`deployment/vm-baseline.md`](deployment/vm-baseline.md) with the real target VM details.
3. Use [`docs/local-deployment-guide.md`](docs/local-deployment-guide.md) as the authoritative deployment path.
4. Record every breakage in [`docs/deployment-issues.md`](docs/deployment-issues.md).
5. Fold confirmed fixes back into the guide immediately.

## Current known issues already captured

This repository already includes one early setup failure:

- `npm install -g @openai/codex` failing with `EACCES` under apt-managed Node.js

Those are included because real deployment repositories should preserve operational truth, not just the final happy path.

## Publishing discipline

Before pushing publicly:

- remove real tokens, usernames, internal paths, hostnames, and private IPs
- scrub screenshots and logs for secrets
- keep only reproducible findings
- make sure issue entries are useful to another operator, not just your own machine

## Included downloadable runbook

If you want the richer Word version alongside the markdown docs, place the latest runbook document under a separate release asset or `docs-assets/` folder rather than making the repository depend on `.docx` as the primary source of truth.
