#!/bin/bash
# Rebuild and restart CleoBot
# Usage: ./scripts/docker-rebuild.sh [--no-cache]

set -e

CACHE_FLAG=""
if [ "$1" = "--no-cache" ]; then
    CACHE_FLAG="--no-cache"
fi

echo "🔨 Building CleoBot image..."
docker compose build $CACHE_FLAG

echo "🔄 Restarting gateway..."
docker compose down cleobot-gateway
docker compose up -d cleobot-gateway

echo "⏳ Waiting for startup..."
sleep 5

echo "📋 Status:"
docker compose ps cleobot-gateway

echo "✅ Rebuild complete"
