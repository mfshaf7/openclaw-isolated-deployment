#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
IMAGE_TAG="${OPENCLAW_LOCAL_IMAGE_TAG:-openclaw:local}"
BASE_IMAGE="${OPENCLAW_BASE_IMAGE:-openclaw:stable-preview}"
DOCKERFILE="${OPENCLAW_DOCKERFILE:-$ROOT/deployment/Dockerfile.telegram-bundled.example}"

if [[ ! -f "$DOCKERFILE" ]]; then
  echo "Missing Dockerfile: $DOCKERFILE" >&2
  exit 1
fi

echo "Preparing bundled OpenClaw image build"
echo "  root      : $ROOT"
echo "  dockerfile: $DOCKERFILE"
echo "  base image: $BASE_IMAGE"
echo "  output tag: $IMAGE_TAG"
echo

"$ROOT/deployment/sync-telegram-build-copy.sh" "$ROOT"
"$ROOT/deployment/verify-workspace-sync.sh" "$ROOT"
"$ROOT/deployment/verify-bridge-workspace.sh" "$ROOT"
"$ROOT/deployment/verify-pc-control-contract.sh" "$ROOT"

echo
echo "Building Docker image..."
docker build \
  --build-arg OPENCLAW_BASE_IMAGE="$BASE_IMAGE" \
  -f "$DOCKERFILE" \
  -t "$IMAGE_TAG" \
  "$ROOT"

echo
echo "Build completed: $IMAGE_TAG"
