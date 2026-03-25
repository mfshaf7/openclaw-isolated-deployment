# OpenClaw Telegram Override

This package replaces the bundled OpenClaw `telegram` channel plugin in deployments
that need `pc-control` aware Telegram behavior without carrying a broad OpenClaw
core fork.

The runtime plugin id remains `telegram`, but the supported deployment model is
to ship this directory as the bundled `telegram` plugin inside the OpenClaw
image or bundled plugin tree. Do not use `plugins.load.paths` as the production
override mechanism for a built-in channel replacement.

This companion plugin currently carries:
- forced host desktop screenshot handling through `pc-control`
- Telegram document delivery for screenshot media
- local exec-approval prose suppression for Telegram button flows

The package name should stay compatible with the manifest id to avoid loader
warnings. In this deployment workspace the package name is `telegram-plugin`.

Development note:

- a config-path or linked-path load can still be useful for short-lived local
  experiments
- it is not the supported long-lived deployment path for this repository
- the production target remains one bundled `telegram` plugin candidate in the
  image, not a duplicate-id override at runtime
