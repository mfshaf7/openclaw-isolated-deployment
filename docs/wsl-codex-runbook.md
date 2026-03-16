# WSL + Codex CLI Runbook

## 1. Purpose

This runbook documents the **operator-side setup** used to manage this project from a Windows workstation.

It exists so the documentation and operator workspace can be rebuilt cleanly if the local environment is lost, changed, or rebuilt.

The runbook covers:

- WSL Ubuntu installation
- launching the Ubuntu shell
- base package installation
- Node.js installation with `nvm`
- Codex CLI installation
- workspace creation at `~/projects/openclaw-isolated-deployment`
- early failure modes already encountered

## 2. Why this runbook exists

A deployment repository becomes fragile if it depends on memory or ad hoc terminal history.

This runbook exists to make the operator environment repeatable and to preserve setup details that changed the correct path.

## 3. Windows prerequisites

- Windows with WSL2 support enabled
- internet access for package downloads
- ability to open PowerShell as Administrator

## 4. Install Ubuntu WSL

Run this in **PowerShell as Administrator**:

```powershell
wsl --install -d Ubuntu
```

During first launch, Ubuntu will prompt for a default Unix username and password.

## 5. Verify available WSL distros

Run in PowerShell:

```powershell
wsl -l -v
```

Expected outcome:

- `Ubuntu` appears as an installed distro

## 6. Start the correct shell

Launch Ubuntu explicitly:

```powershell
wsl -d Ubuntu
```

A normal Ubuntu prompt should look similar to:

```bash
your-user@your-host:~$
```

## 7. Install base packages inside Ubuntu

Run in Ubuntu:

```bash
cd ~
sudo apt update
sudo apt install -y curl ca-certificates git
```

## 8. Install Node.js using nvm

The correct method for this repository is **nvm-based Node installation**, not apt-managed global Node, because global npm installs later failed with `EACCES` under the apt-managed path.

### Remove apt-managed Node if already installed

```bash
sudo apt remove -y nodejs npm
```

### Install nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
```

### Load nvm into the current shell

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
```

### Install latest LTS Node

```bash
nvm install --lts
nvm use --lts
```

### Verify Node and npm

```bash
node -v
npm -v
which node
which npm
```

## 9. Install Codex CLI

Run in Ubuntu after Node is managed by `nvm`:

```bash
npm install -g @openai/codex
```

Verify installation:

```bash
codex --help
```

## 10. Create the project workspace

Run in Ubuntu:

```bash
mkdir -p ~/projects
cd ~/projects
mkdir -p openclaw-isolated-deployment
cd ~/projects/openclaw-isolated-deployment
pwd
```

Expected path:

```bash
/home/<your-user>/projects/openclaw-isolated-deployment
```

## 11. First working checks

Run:

```bash
node -v
npm -v
codex --help
pwd
ls -la
```

## 12. Known issue 1 — npm global install `EACCES`

### Symptom
This failed:

```bash
npm install -g @openai/codex
```

with an `EACCES` error attempting to write under `/usr/lib/node_modules`.

### Cause
Node/npm had been installed using apt, so global npm installs targeted root-owned system directories.

### Fix
Use `nvm` to manage Node under the user profile, then reinstall Codex CLI globally without `sudo`.

## 13. Operating rule after setup

For this project, every time the deployment troubleshooting path changes:

- update `docs/deployment-issues.md`
- update the authoritative guide if the build method changed
- check formatting for consistency before considering the change complete

## 14. Run record template

Keep a record for each rebuild:

- Date:
- Windows version:
- WSL distro version:
- Ubuntu username:
- Node version:
- npm version:
- Codex CLI version or install verification result:
- Workspace path:
- Notes:
