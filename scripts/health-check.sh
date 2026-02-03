#!/bin/bash
# CleoBot Health Check
# Usage: ./scripts/health-check.sh [url]

URL=${1:-"http://127.0.0.1:18789"}

echo "🏥 CleoBot Health Check"
echo "URL: $URL"
echo

# Check gateway health endpoint
echo -n "Gateway health: "
HEALTH=$(curl -s -o /dev/null -w "%{http_code}" "$URL/health" 2>/dev/null)

if [ "$HEALTH" = "200" ]; then
    echo "✅ OK"
else
    echo "❌ FAILED (HTTP $HEALTH)"
    exit 1
fi

# Check WebSocket connection (if ws endpoint exists)
echo -n "WebSocket: "
WS_CHECK=$(curl -s -o /dev/null -w "%{http_code}" -H "Upgrade: websocket" -H "Connection: Upgrade" "$URL" 2>/dev/null)
if [ "$WS_CHECK" = "426" ] || [ "$WS_CHECK" = "101" ]; then
    echo "✅ Available"
else
    echo "⚠️ May require upgrade"
fi

# Docker container check (if running in Docker)
if command -v docker &> /dev/null; then
    echo -n "Container: "
    CONTAINER=$(docker ps --filter "name=cleobot-gateway" --format "{{.Status}}" 2>/dev/null)
    if [ -n "$CONTAINER" ]; then
        echo "✅ $CONTAINER"
    else
        echo "⚠️ Not found"
    fi
fi

echo
echo "✅ Health check complete"
