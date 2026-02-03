#!/bin/bash
# Quick docker logs viewer for CleoBot
# Usage: ./scripts/docker-logs.sh [lines]

LINES=${1:-100}

docker compose logs -f --tail "$LINES" cleobot-gateway
