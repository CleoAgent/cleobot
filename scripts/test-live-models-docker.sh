#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${CLEOBOT_IMAGE:-${CLAWDBOT_IMAGE:-openclaw:local}}"
CONFIG_DIR="${CLEOBOT_CONFIG_DIR:-${CLAWDBOT_CONFIG_DIR:-$HOME/.cleobot}}"
WORKSPACE_DIR="${CLEOBOT_WORKSPACE_DIR:-${CLAWDBOT_WORKSPACE_DIR:-$HOME/.cleobot/workspace}}"
PROFILE_FILE="${CLEOBOT_PROFILE_FILE:-${CLAWDBOT_PROFILE_FILE:-$HOME/.profile}}"

PROFILE_MOUNT=()
if [[ -f "$PROFILE_FILE" ]]; then
  PROFILE_MOUNT=(-v "$PROFILE_FILE":/home/node/.profile:ro)
fi

echo "==> Build image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" -f "$ROOT_DIR/Dockerfile" "$ROOT_DIR"

echo "==> Run live model tests (profile keys)"
docker run --rm -t \
  --entrypoint bash \
  -e COREPACK_ENABLE_DOWNLOAD_PROMPT=0 \
  -e HOME=/home/node \
  -e NODE_OPTIONS=--disable-warning=ExperimentalWarning \
  -e CLEOBOT_LIVE_TEST=1 \
  -e CLEOBOT_LIVE_MODELS="${CLEOBOT_LIVE_MODELS:-${CLAWDBOT_LIVE_MODELS:-all}}" \
  -e CLEOBOT_LIVE_PROVIDERS="${CLEOBOT_LIVE_PROVIDERS:-${CLAWDBOT_LIVE_PROVIDERS:-}}" \
  -e CLEOBOT_LIVE_MODEL_TIMEOUT_MS="${CLEOBOT_LIVE_MODEL_TIMEOUT_MS:-${CLAWDBOT_LIVE_MODEL_TIMEOUT_MS:-}}" \
  -e CLEOBOT_LIVE_REQUIRE_PROFILE_KEYS="${CLEOBOT_LIVE_REQUIRE_PROFILE_KEYS:-${CLAWDBOT_LIVE_REQUIRE_PROFILE_KEYS:-}}" \
  -v "$CONFIG_DIR":/home/node/.cleobot \
  -v "$WORKSPACE_DIR":/home/node/.cleobot/workspace \
  "${PROFILE_MOUNT[@]}" \
  "$IMAGE_NAME" \
  -lc "set -euo pipefail; [ -f \"$HOME/.profile\" ] && source \"$HOME/.profile\" || true; cd /app && pnpm test:live"
