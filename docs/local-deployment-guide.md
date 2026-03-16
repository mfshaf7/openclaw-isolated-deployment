# OpenClaw Local Deployment Guide

## 1. Purpose

This document defines the **authoritative local deployment path** for this repository.

It assumes a privacy-first build where OpenClaw does **not** run directly on the primary workstation. Instead, the workstation is used for the documentation and operator workflow, while the runtime itself is isolated inside a dedicated Ubuntu virtual machine.

This guide is not a generic install note. It is the controlled implementation path that should be kept current as real deployment issues are discovered and fixed.

## 2. Fixed deployment model

The deployment pattern for this project is:

**Windows workstation -> Ubuntu WSL workspace for documentation / Codex CLI -> dedicated Ubuntu VM -> Docker-based OpenClaw runtime -> localhost-style host access only**

### Why this model is fixed

This structure gives a stronger privacy and containment story than:

- native host installation on the primary workstation
- loosely managed Docker on the main host
- public tunneling during early setup

It also creates a clear trust boundary that is easier to explain, document, and rebuild.

## 3. Non-goals

This guide does not claim to deliver:

- enterprise-ready production architecture
- public internet exposure
- high availability
- broad connector activation from day one
- a guarantee that local deployment is inherently safe

The local phase exists to establish a controlled baseline only.

## 4. Required companion rule

Every time troubleshooting changes the deployment path, update the documentation in the same session.

That means:

- record the issue in `docs/deployment-issues.md`
- update this guide if the known-good method changed

A fix is not complete until both are done.

## 5. Baseline assumptions

Recommended starting point for the target VM:

- Ubuntu Server LTS
- 2–4 vCPU
- 4–8 GB RAM
- 40+ GB disk
- NAT or host-only networking
- Docker Engine installed inside the VM
- only the minimum required application port forwarded

Track the real values in `deployment/vm-baseline.md`.

## 6. Workspace naming standard

Use the following workspace naming consistently:

- workspace root: `~/projects`
- project root: `~/projects/openclaw-isolated-deployment`

Use the generic workspace root `~/projects`, but keep the project folder name specific as `openclaw-isolated-deployment`.

### Workspace and Repository Layout

```text
~/projects/
└── openclaw-isolated-deployment/
```

Both levels must be created explicitly.

## 7. Build workflow

### Step 1 — Prepare the operator workspace

Use the WSL/Codex runbook first so the documentation and troubleshooting environment is stable.

Reference: [`docs/wsl-codex-runbook.md`](wsl-codex-runbook.md)

### Step 2 — Prepare the target VM

- Create a dedicated Ubuntu VM.
- Patch the OS fully.
- Create a non-root administrative user.
- Record hypervisor, CPU, RAM, disk, network mode, and forwarded ports.
- Avoid mixing unrelated services into this VM.

### Step 3 — Install Docker inside the VM

- Install Docker Engine and Compose support.
- Confirm the runtime starts cleanly.
- Record Docker version and install method.

### Step 4 — Create the deployment workspace inside the VM

```bash
mkdir -p ~/projects
cd ~/projects
mkdir -p openclaw-isolated-deployment
cd ~/projects/openclaw-isolated-deployment
```

### Step 5 — Obtain OpenClaw from a trusted source

- Clone or download OpenClaw from the official upstream source you trust.
- Record the release, tag, image, or commit used.
- Do not start from random mirrors for the first build.

### Step 6 — Create runtime configuration

- Copy `deployment/.env.example` to a real `.env` inside the VM only.
- Populate the minimum required values only.
- Do not enable optional connectors until baseline runtime works.
- Do not store real secrets in markdown, scripts, or version-controlled compose files.

### Step 7 — Prepare storage

- Define where persistent state lives.
- Confirm Docker volumes or directories are writable.
- Confirm logs can be located later.
- Record any path ownership adjustments required.

### Step 8 — Start the stack

Start OpenClaw using the documented Docker-based method appropriate to the upstream project.

Preserve at minimum:

- command used
- container status output
- startup logs
- bound ports
- first warnings or errors

### Step 9 — Validate baseline function

At minimum confirm:

- containers stay up without fatal restart loops
- host access works through localhost-style forwarding
- the UI loads
- one baseline interaction works
- logs are readable
- state location is known

### Step 10 — Update evidence and issue log

After each meaningful attempt:

- add evidence under `evidence/` if safe to keep
- update `docs/deployment-issues.md`
- update this guide if the official path changed

## 8. Networking standard

The preferred local pattern is:

- VM uses **NAT** or **host-only** networking
- only the minimum required application port is forwarded
- the host accesses the service through `http://localhost:<forwarded-port>`
- no broad LAN exposure
- no public tunnel during the initial phase

This keeps the runtime private and makes the execution boundary clear.

## 9. Secrets handling rules

- never commit `.env`
- keep real values only inside the VM
- use `.env.example` only for placeholders and documentation
- do not hardcode tokens into scripts or compose files
- scrub logs before publishing if they contain sensitive values

## 10. Definition of done for the local phase

The local phase is complete when:

- OpenClaw runs inside the isolated VM
- host access works through localhost-style forwarding
- runtime restart behavior is understood
- persistent state location is known
- issues encountered are documented
- the build can be repeated from notes rather than memory
