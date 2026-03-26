# WSL Operator Workstation Runbook

## Purpose

This runbook documents the **operator workstation setup** used to manage the isolated OpenClaw deployment from a Windows machine.

Despite the filename, this is not a “Codex install guide”. It is the workstation baseline for:

- editing docs and configs
- running validation commands
- maintaining deployment scripts
- interacting with the isolated runtime from a controlled shell

Codex CLI or any other editor/terminal tooling is optional on top of this baseline.

## What This Runbook Covers

- WSL Ubuntu installation
- shell and package baseline
- Node.js installation with `nvm`
- Git and workspace creation
- optional operator tooling notes
- common rebuild checks

## Why This Exists

The runtime is isolated on purpose. That means the workstation setup still matters, because it is the place where the operator:

- reads and edits the deployment repo
- runs maintenance scripts
- checks logs and health
- prepares changes before they are applied to the isolated runtime

If the workstation setup is ad hoc, the deployment becomes harder to rebuild and maintain.

## Windows Prerequisites

- Windows with WSL2 support enabled
- administrator access to install WSL
- internet access for packages and source checkouts

## Install Ubuntu WSL

Run in PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu
```

After first launch, create the normal Ubuntu username and password.

## Verify WSL

```powershell
wsl -l -v
```

Expected result:

- `Ubuntu` appears
- version is WSL2

## Start The Correct Shell

```powershell
wsl -d Ubuntu
```

## Base Packages

Run inside Ubuntu:

```bash
cd ~
sudo apt update
sudo apt install -y curl ca-certificates git build-essential
```

## Install Node.js With `nvm`

Use `nvm` rather than apt-managed Node. This avoids global npm permission problems and keeps the operator environment under the user profile.

### Remove apt-managed Node if needed

```bash
sudo apt remove -y nodejs npm
```

### Install `nvm`

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
```

### Install the current LTS Node

```bash
nvm install --lts
nvm use --lts
```

### Verify

```bash
node -v
npm -v
which node
which npm
```

## Create The Workspace

```bash
mkdir -p ~/projects
cd ~/projects
git clone <your-repo-url> openclaw-isolated-deployment
cd openclaw-isolated-deployment
pwd
```

Expected path:

```bash
/home/<your-user>/projects/openclaw-isolated-deployment
```

## Optional Operator Tooling

This repository does not require one specific editor or agent tool.

Common optional choices are:

- Codex CLI
- VS Code Remote WSL
- Neovim
- standard shell aliases and Git helpers

Those are operator preferences, not part of the deployment contract.

If you do install additional CLI tooling, keep it user-local and separate from the isolated runtime.

## First Working Checks

Run:

```bash
node -v
npm -v
git --version
pwd
ls -la
```

## Known Failure Mode: apt-managed Node and global npm permissions

### Symptom

Global npm installs fail with `EACCES` under system-owned directories such as `/usr/lib/node_modules`.

### Cause

Node/npm was installed with apt instead of `nvm`.

### Fix

Use `nvm` for the workstation shell environment and reinstall any optional operator CLI tools without `sudo`.

## Rebuild Record

When rebuilding the operator workstation, record:

- date
- Windows version
- WSL distro version
- Ubuntu username
- Node version
- npm version
- workspace path
- extra optional operator tools installed
- notes about anything that changed from the normal path

## Related Documents

- [README.md](/home/mfshaf7/projects/openclaw-isolated-deployment/README.md)
- [local-deployment-guide.md](/home/mfshaf7/projects/openclaw-isolated-deployment/docs/local-deployment-guide.md)
- [repository-map.md](/home/mfshaf7/projects/openclaw-isolated-deployment/docs/repository-map.md)
