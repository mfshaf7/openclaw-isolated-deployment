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

## Issue 001 — user-local global npm installs failed with `EACCES` under apt-managed Node

**Date:** 2026-03-17  
**Build stage:** workspace  
**Status:** Fixed  

### Symptom
Installing an optional user-local CLI tool with `npm install -g ...` failed under Ubuntu WSL.

### Observed error
```text
npm error code EACCES
npm error syscall mkdir
npm error path /usr/lib/node_modules/@openai
npm error errno -13
npm error Error: EACCES: permission denied, mkdir '/usr/lib/node_modules/@openai'
```

### Impact
Blocked operator CLI installation and invalidated the earlier assumption that apt-managed Node.js was sufficient for the workstation shell.

### Root cause hypothesis
Initial suspicion was a one-off permissions problem that might be bypassed with elevated privileges.

### Confirmed cause
Node.js and npm had been installed via apt, so global npm packages targeted root-owned directories under `/usr/lib/node_modules`.

### Fix applied
Removed apt-managed Node/npm, installed `nvm`, loaded it into the shell, installed LTS Node through `nvm`, then retried the global user-local CLI install without `sudo`.

```bash
sudo apt remove -y nodejs npm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
npm install -g <tool>
<tool> --help
```

### Verification
`node -v`, `npm -v`, and the chosen CLI help command should complete successfully from the user shell.

### Guide update required
`docs/wsl-codex-runbook.md`

### Notes
Do not normalize `sudo npm install -g ...` as the fix path for this repository.

---
