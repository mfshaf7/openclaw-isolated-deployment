# OpenClaw Security Architecture Review

## Purpose

This document evaluates the current OpenClaw deployment from a cybersecurity architecture perspective and defines a **balanced** target state.

Balanced here means:

- preserve the current isolation model
- reduce avoidable risk
- avoid operator burden that would make the deployment annoying to use
- keep a clean path for adding a future `pc-control` host bridge

## Current deployment shape

Current pattern:

**Windows workstation -> WSL operator workspace -> isolated Ubuntu VM -> Docker-based OpenClaw runtime -> Telegram control plane**

This is already a stronger local trust boundary than:

- running OpenClaw directly on the main workstation
- exposing the gateway publicly
- granting unrestricted host shell access from day one

## What is good already

- OpenClaw runtime is isolated from the main workstation.
- The control surface is intentionally narrow: Telegram plus local web UI access.
- Telegram group usage is effectively disabled.
- Elevated mode is disabled.
- Exec approvals are enabled.
- Default exec security is allowlist-based rather than full access.
- Workspace skills can extend behavior without patching OpenClaw core.
- Gateway auth is token-based.
- Windows host firewall can be used as the real exposure boundary when Docker/WSL
  forwarding does not honor a localhost-only publish strategy.

## Current architectural gaps

### 1. Intended node-host execution path is configured but not present

The deployment is configured to prefer `host:"node"` with a named Windows host target, but there is currently no paired node exposing `system.run`.

Impact:

- host-scoped requests fall back toward runtime/container context
- operator expectations and actual trust path do not match
- built-in Windows host healthcheck capabilities cannot work as intended

### 2. Host-control use case does not yet have a supported trust boundary

The user wants host actions such as:

- inspect files
- organize folders
- export/send files
- inspect browser tabs

There is currently no official Windows host bridge in the deployment to support this.

Impact:

- pressure to patch OpenClaw core or overload runtime-local tools
- risk of confusing container state with host state

### 3. Runtime sandboxing is off

The current agent sandbox mode is off.

Impact:

- if a tool path is broadened later, there is less containment inside the OpenClaw runtime itself
- mistakes in future skills or tools have a larger blast radius inside the VM/container

This is acceptable for a controlled local phase, but it should be treated as a conscious tradeoff, not a hidden default.

### 4. Sensitive values are present in active runtime config

The live config contains operational secrets.

Impact:

- acceptable for the private runtime
- not acceptable for documentation, screenshots, code samples, or future publication

This is a documentation and handling risk more than a runtime design flaw.

## Balanced target model

The recommended balanced model is:

**OpenClaw stays isolated in the VM/container. A separate Windows-side bridge provides narrow, policy-enforced host operations.**

### Why this is the right balance

- keeps the current isolation story intact
- avoids arbitrary host shell by default
- supports real user tasks
- stays clean as a skill + bridge pattern
- gives a cleaner security review story than direct unrestricted remote execution

## Recommended trust boundaries

### Boundary 1: OpenClaw runtime

Role:

- orchestration
- user conversation
- approvals
- skill selection

Should not become the host trust anchor.

### Boundary 2: Windows host bridge

Role:

- enforcement point for host access
- path restrictions
- operation allowlist
- audit logging

This should be the trust anchor for PC control.

### Boundary 3: Delivery channel

Telegram should be treated as an exfiltration boundary.

Implication:

- file send/export must be a separately approved capability
- host control and data export should not be conflated

## Recommended v1 posture

### Keep

- isolated VM/container runtime
- Telegram DM control plane
- exec approvals
- allowlist-based execution defaults
- no public exposure

### Add

- `pc-control` skill
- Windows host bridge with narrow JSON API
- read-only default policy
- explicit export policy
- append-only audit logs
- gateway auth rate limiting
- Windows Firewall restrictions on forwarded OpenClaw ports

### Avoid for now

- arbitrary remote shell on the Windows host
- broad LAN exposure for the bridge
- automatic file export to Telegram
- browser session scraping beyond tab metadata
- deletion or destructive file ops in v1

## Practical low-friction recommendations

### Recommendation 1: Keep user friction low for read-only checks

Allow read-only host operations by default once the bridge is installed and authenticated.

Examples:

- health summary
- listing folders
- searching files
- reading file metadata
- listing browser tabs

This keeps the system useful without making every action painful.

### Recommendation 2: Require confirmations only where risk meaningfully changes

Require explicit confirmation for:

- moving files
- creating folders outside simple approved workflows
- staging files for Telegram
- inspecting page content rather than tab metadata

Do not require the same level of friction for harmless read-only queries.

### Recommendation 3: Separate organize from export

Treat:

- file organization
- file export to Telegram

as different permission classes.

This is important because users often want the first without implicitly granting the second.

### Recommendation 4: Do not patch OpenClaw core for local environment assumptions

Use:

- workspace skills
- a separate bridge
- local policy config

instead of custom core routing or host-specific assumptions.

### Recommendation 5: Treat Docker/WSL forwarding as an implementation detail, not the trust boundary

If `gateway.bind=loopback` or `127.0.0.1:hostPort:containerPort` publishing
breaks access in the actual Windows + WSL + Docker environment, do not force
that model just to satisfy a generic hardening rule.

Use the stronger practical boundary instead:

- authenticated gateway
- failed-auth rate limiting
- Windows Firewall on the forwarded ports

## Recommended next implementation steps

1. Build and test the Windows `openclaw-host-bridge` locally on the host.
2. Start with read-only operations only.
3. Add policy-controlled organize operations.
4. Add explicit export/staging operations last.
5. Reevaluate OpenClaw runtime sandboxing after the bridge exists.

## Current deployment reevaluation

From a balanced cybersecurity-architecture perspective, the current OpenClaw deployment should be treated as:

- good isolation at the runtime boundary
- incomplete at the host-control boundary
- acceptable for local use if host access stays behind `pc-control`

Recommended stance now:

- keep the isolated container/VM runtime
- keep Telegram DM approvals
- keep elevated mode disabled
- keep generic `exec` for container-local administration only
- prefer the `pc-control` plugin for host-facing actions

Recommended changes only after the bridge is live and stable:

- reconsider runtime sandbox hardening
- reconsider whether the misleading node-host setting should be removed or replaced
- add stronger export controls once file delivery is implemented

This avoids a common mistake: tightening the wrong layer while the actual host trust boundary is still undefined.

## Target end state

The desired end state is not maximum lockdown.

It is:

- isolated OpenClaw runtime
- low-friction read-only host insight
- deliberate approval for risky actions
- no hidden trust-boundary collapse
- a reusable skill architecture
