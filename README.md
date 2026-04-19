# OpenClaw Isolated Deployment

This repository is retired.

It is no longer part of the active OpenClaw architecture, build, packaging, or
governed rollout path.

## Where The Content Moved

- platform-side OpenClaw architecture and owner model:
  - [platform-engineering/products/openclaw/architecture-and-owner-model.md](https://github.com/mfshaf7/platform-engineering/blob/main/products/openclaw/architecture-and-owner-model.md)
- platform-side OpenClaw runtime and operator docs:
  - [platform-engineering/products/openclaw/README.md](https://github.com/mfshaf7/platform-engineering/blob/main/products/openclaw/README.md)
- OpenClaw security architecture:
  - [security-architecture/docs/architecture/products/openclaw/README.md](https://github.com/mfshaf7/security-architecture/blob/main/docs/architecture/products/openclaw/README.md)
- host-control security posture:
  - [security-architecture/docs/architecture/domains/host-control.md](https://github.com/mfshaf7/security-architecture/blob/main/docs/architecture/domains/host-control.md)
- active governed runtime composition:
  - [openclaw-runtime-distribution/README.md](https://github.com/mfshaf7/openclaw-runtime-distribution/blob/main/README.md)

## Why It Was Retired

This repo used to mix:

- reference architecture
- local build seams
- copied source trees
- migration notes

That split no longer matched the real owner model and kept recreating drift.

The platform now uses:

- `platform-engineering/products/openclaw`
  - current platform-side OpenClaw architecture and operator model
- `security-architecture`
  - current OpenClaw security rationale and trust-boundary docs
- `openclaw-runtime-distribution`
  - active stage/prod runtime composition

## Current Rule

Do not route active work here.

Keep this repo only as a retirement stub until it is archived or removed.
