#!/bin/bash
# Restart CleoBot gateway container
# Usage: ./scripts/docker-restart.sh

set -e

echo "🔄 Restarting CleoBot gateway..."
docker compose restart cleobot-gateway

echo "⏳ Waiting for healthy status..."
sleep 5

# Check health
docker compose ps cleobot-gateway

echo "✅ Restart complete"
