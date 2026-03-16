# OpenClaw Deployment Issues Log

Use this document to track every meaningful setup problem encountered during deployment.

## Operating rule

Every issue that materially changes the working deployment method must trigger:

1. an update to this issue log
2. an update to the authoritative deployment document

Do not treat documentation as a cleanup step for later.

## Issue entry template

```md
## Issue <number> — <short title>

**Date:** YYYY-MM-DD  
**Build stage:** workspace / VM prep / Docker install / config / startup / validation  
**Status:** Open / Investigating / Fixed / Deferred  

### Symptom
What failed in plain language?

### Observed error
Paste the exact error message, log line, or screenshot reference.

### Impact
What did this block or break?

### Root cause hypothesis
What did you initially think was wrong?

### Confirmed cause
What was actually wrong once verified?

### Fix applied
What exact change did you make?

### Verification
How did you prove the fix worked?

### Guide update required
Which document had to change because of this issue?

### Notes
Anything else worth preserving.
```

---

## Issue 001 — Entered the wrong WSL distro (`docker-desktop`)

**Date:** 2026-03-17  
**Build stage:** workspace  
**Status:** Fixed  

### Symptom
The shell prompt showed `docker-desktop:~#`, and normal Ubuntu setup commands such as `sudo apt update` did not behave as expected.

### Observed error
```text
-sh: sudo: not found
```

### Impact
Blocked the WSL setup path and made the environment unsuitable for installing Codex CLI the intended way.

### Root cause hypothesis
Initial thought was that `sudo` or base packages were missing from the Linux environment.

### Confirmed cause
The session was opened inside Docker Desktop’s internal WSL distro instead of a real Ubuntu WSL instance.

### Fix applied
Installed Ubuntu with WSL and launched it explicitly.

```powershell
wsl --install -d Ubuntu
wsl -l -v
wsl -d Ubuntu
```

### Verification
Prompt changed to a normal Ubuntu user shell such as `your-user@your-host:~$`.

### Guide update required
`docs/wsl-codex-runbook.md`

### Notes
This issue should stay in the repository because it is a realistic early trap on Windows systems that already have Docker Desktop installed.

---

## Issue 002 — `npm install -g @openai/codex` failed with `EACCES`

**Date:** 2026-03-17  
**Build stage:** workspace  
**Status:** Fixed  

### Symptom
Installing Codex CLI globally failed under Ubuntu WSL.

### Observed error
```text
npm error code EACCES
npm error syscall mkdir
npm error path /usr/lib/node_modules/@openai
npm error errno -13
npm error Error: EACCES: permission denied, mkdir '/usr/lib/node_modules/@openai'
```

### Impact
Blocked Codex CLI installation and invalidated the earlier assumption that apt-managed Node.js was sufficient.

### Root cause hypothesis
Initial suspicion was a one-off permissions problem that might be bypassed with elevated privileges.

### Confirmed cause
Node.js and npm had been installed via apt, so global npm packages targeted root-owned directories under `/usr/lib/node_modules`.

### Fix applied
Removed apt-managed Node/npm, installed `nvm`, loaded it into the shell, installed LTS Node through `nvm`, then retried the global Codex CLI install without `sudo`.

```bash
sudo apt remove -y nodejs npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
npm install -g @openai/codex
codex --help
```

### Verification
`node -v`, `npm -v`, and `codex --help` should complete successfully from the user shell.

### Guide update required
`docs/wsl-codex-runbook.md` and any Word/PDF runbook derived from it

### Notes
Do not normalize `sudo npm install -g ...` as the fix path for this repository.

---

## Issue 003 — Workspace naming became inconsistent across docs and repo guidance

**Date:** 2026-03-17  
**Build stage:** workspace  
**Status:** Fixed  

### Symptom
The runbook, repo bundle, and chat guidance used conflicting workspace paths.

### Observed error
Some guidance referred to:

```text
~/openclaw-lab/openclaw-isolated-deployment
```

while the intended direction shifted toward using a generic workspace root with a specific project folder.

### Impact
Created ambiguity about where the repository should live in WSL and made the documentation look internally inconsistent.

### Root cause hypothesis
The earlier naming decision used a project-specific workspace root, but later guidance treated the workspace root and project folder as separate concerns without fully updating all docs.

### Confirmed cause
The workspace naming convention changed, but the runbook, README, deployment guide, and bundle content were not revised together in the same update cycle.

### Fix applied
Standardized the path model as:

```text
~/projects/openclaw-isolated-deployment
```

Then updated the markdown docs, the runbook Word document, and the Git-ready repo bundle to match that single structure.

### Verification
All current repo guidance now points to the same workspace root and project folder naming standard.

### Guide update required
`README.md`, `docs/wsl-codex-runbook.md`, `docs/local-deployment-guide.md`, `deployment/build-checklist.md`, and the runbook `.docx`

### Notes
This issue should remain documented because it demonstrates the repository operating rule in practice: a path change is not complete until every authoritative artifact is updated.


## Issue 04 - Workspace root vs. project subfolder ambiguity

- **Status:** Resolved
- **Symptom:** Some instructions referenced `~/projects/openclaw-isolated-deployment` as the target path without clearly showing that `openclaw-isolated-deployment` had to be created as a subfolder under `~/projects`.
- **Risk:** Users could end up treating `~/projects` itself as the repo root or assume the project folder already existed.
- **Fix:** All active documents now show the explicit creation sequence below and include a path layout block.

```bash
mkdir -p ~/projects
cd ~/projects
mkdir -p openclaw-isolated-deployment
cd ~/projects/openclaw-isolated-deployment
```
