Pinned OpenClaw base for this deployment: `v2026.3.23-2`

Current live image:
- `openclaw:local`

Local patch artifact:
- [openclaw-stable-preview-local.patch](/home/mfshaf7/projects/openclaw-isolated-deployment/docs/openclaw-stable-preview-local.patch)

Local Telegram override plugin:
- workspace copy: [telegram-override-plugin](/home/mfshaf7/projects/openclaw-isolated-deployment/telegram-override-plugin)
- current official deployment shape: bundled replacement at `/app/extensions/telegram`

Current plugin/runtime shape:
- `telegram` loads from the bundled image replacement
- `pc-control` is installed through managed plugin records in `plugins.installs`
- gateway auth uses token mode plus failed-auth rate limiting
- Windows Firewall enforces inbound blocks on ports `18789` and `18790`

Why this exists:
- `origin/main` did not build cleanly in this environment.
- The live deployment depends on local Telegram/runtime adjustments plus `pc-control` integration behavior.
- Future updates should start from a stable tag, then replay this patch deliberately instead of merging onto a moving `main`.

Minimum verification after any future update:
- Windows-side gateway health: `http://127.0.0.1:18789/healthz`
- Telegram plugin loads
- `pc-control` plugin loads
- `pc-control` skill is ready
- bridge health: `http://host.docker.internal:48721/healthz`
- screenshot send still works
- host file send still works
- Windows Firewall rules for `18789` and `18790` are still present if Docker/WSL
  localhost-only publishing remains unsupported

Known local core-touch points:
- `extensions/telegram/src/*`
- `src/agents/pi-embedded-subscribe.tools.ts`
- `scripts/tsdown-build.mjs`

Preferred long-term deployment shape:
- keep more behavior in the `pc-control` plugin/bridge
- keep Telegram custom behavior in a bundled plugin replacement image, not a config-loaded duplicate
- keep the core patch file small and reviewable
- keep host exposure controls at the Windows firewall layer unless the Docker/WSL
  platform is proven to support a stable localhost-only publish path

Refactor status:
- generic reply-layer drift was reverted back to the stable tag
- bundled Telegram patches were removed from the core image source tree
- Telegram custom behavior now loads from the bundled replacement in the deployment image
- remaining core-touching changes are only:
  - trusted local media for `pc_control_*`
  - the pinned stable-tag build warning gate in `scripts/tsdown-build.mjs`
