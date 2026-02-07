#!/usr/bin/env bash
set -euo pipefail

cd /repo

export CLEOBOT_STATE_DIR="/tmp/cleobot-test"
export CLEOBOT_CONFIG_PATH="${CLEOBOT_STATE_DIR}/openclaw.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${CLEOBOT_STATE_DIR}/credentials"
mkdir -p "${CLEOBOT_STATE_DIR}/agents/main/sessions"
echo '{}' >"${CLEOBOT_CONFIG_PATH}"
echo 'creds' >"${CLEOBOT_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${CLEOBOT_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm openclaw reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${CLEOBOT_CONFIG_PATH}"
test ! -d "${CLEOBOT_STATE_DIR}/credentials"
test ! -d "${CLEOBOT_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${CLEOBOT_STATE_DIR}/credentials"
echo '{}' >"${CLEOBOT_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm openclaw uninstall --state --yes --non-interactive

test ! -d "${CLEOBOT_STATE_DIR}"

echo "OK"
