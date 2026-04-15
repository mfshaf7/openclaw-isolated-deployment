# Build Checklist

## Operator workspace
- [ ] Ubuntu WSL installed
- [ ] Ubuntu shell opened and verified
- [ ] Base packages installed
- [ ] Node.js installed through `nvm`
- [ ] Codex CLI installed and verified
- [ ] Workspace created at `~/projects/openclaw-isolated-deployment`

## Target VM
- [ ] VM created
- [ ] VM patched
- [ ] Non-root admin user created
- [ ] Docker installed
- [ ] Compose support verified
- [ ] VM baseline recorded

## OpenClaw deployment
- [ ] Official upstream source recorded (`github.com/openclaw/openclaw`)
- [ ] `.env` created inside target VM
- [ ] Persistent storage path confirmed
- [ ] Standalone `openclaw-telegram-enhanced` repo synced into deployment packaging copy with `./deployment/sync-telegram-build-copy.sh`
- [ ] `./deployment/verify-workspace-sync.sh` passes
- [ ] `./deployment/verify-telegram-router-contract.sh` passes
- [ ] `./deployment/verify-bridge-workspace.sh` passes
- [ ] `./deployment/verify-host-control-contract.sh` passes
- [ ] Managed plugin artifacts packaged through `./deployment/package-local-plugins.sh`
- [ ] Gateway image built through `./deployment/build-openclaw-local.sh` or an equivalent command path
- [ ] Telegram and host-control installed through `openclaw plugins install`, not copied directly into `/app/extensions`
- [ ] `gateway.auth.rateLimit` configured when `gateway.bind` stays beyond loopback
- [ ] Host firewall rules restrict OpenClaw ports if Docker/WSL cannot enforce localhost-only publish safely
- [ ] Startup logs captured
- [ ] Host localhost access confirmed
- [ ] First interaction validated

## Documentation discipline
- [ ] Deployment issues log updated
- [ ] Deployment guide updated after any method change
- [ ] Formatting checked for consistency
