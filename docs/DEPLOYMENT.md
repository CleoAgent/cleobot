# CleoBot Deployment Guide

## Prerequisites

- Docker and Docker Compose
- SSH access to deployment server
- Anthropic API key

## Quick Deployment (Docker)

### 1. Clone Repository

```bash
git clone https://github.com/CleoAgent/cleobot.git
cd cleobot
```

### 2. Configure Environment

```bash
# Copy example environment
cp .env.example .env

# Generate gateway token
CLEOBOT_GATEWAY_TOKEN=$(openssl rand -hex 24)
echo "CLEOBOT_GATEWAY_TOKEN=$CLEOBOT_GATEWAY_TOKEN" >> .env

# Add your API key
echo "ANTHROPIC_API_KEY=your-key-here" >> .env
```

### 3. Create Config Directory

```bash
mkdir -p ~/.cleobot/workspace

# Use optimized config
cp examples/configs/optimized.json ~/.cleobot/cleobot.json

# Or minimal config
# cp examples/configs/minimal.json ~/.cleobot/cleobot.json
```

### 4. Run with GHCR Image (Recommended)

```bash
# Pull latest image from GitHub Container Registry
docker compose pull

# Start the gateway
docker compose up -d cleobot-gateway
```

### 4b. Alternative: Build Locally

```bash
# Only if you need local modifications
docker build -t cleobot:local .

# Update .env to use local image
# CLEOBOT_IMAGE=cleobot:local

docker compose up -d cleobot-gateway
```

### 5. Verify

```bash
docker compose logs -f cleobot-gateway
```

Open `http://your-server:18789` to access webchat.

---

## LXC Container Deployment

### On the LXC Host (10.0.10.21)

```bash
# SSH to LXC
ssh root@10.0.10.21

# Navigate to cleobot directory
cd /opt/cleobot

# Update to latest (Option A: GHCR - Recommended)
docker compose pull
docker compose up -d cleobot-gateway

# OR update from source (Option B: Local Build)
git pull origin main
docker build -t cleobot:local .
docker compose down
docker compose up -d cleobot-gateway

# Check logs
docker compose logs -f
```

### SSH Key Setup

If SSH access is lost, add this public key to `/root/.ssh/authorized_keys`:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA33uyhn8atDbvSl1JwYr69mwyoFgqvLELaaX8FSo6ro node@e0ebd711c411
```

---

## Production with Doppler

### 1. Install Doppler

```bash
curl -Ls https://cli.doppler.com/install.sh | sh
doppler login
```

### 2. Setup Project

```bash
doppler setup --project cleobot --config prd
```

### 3. Run with Secrets

```bash
doppler run -- docker compose up -d
```

---

## Updating

### Option 1: Pull from GHCR (Recommended)

```bash
cd /opt/cleobot
docker compose pull
docker compose up -d
```

### Option 2: Rebuild from Source

```bash
cd /opt/cleobot
git pull origin main
docker build -t cleobot:local .
docker compose down
docker compose up -d
```

---

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose logs cleobot-gateway

# Check config
cat ~/.cleobot/cleobot.json | jq .

# Verify token
echo $CLEOBOT_GATEWAY_TOKEN
```

### Can't connect to webchat

1. Verify gateway is running: `docker ps`
2. Check port binding: `netstat -tlnp | grep 18789`
3. Verify firewall allows 18789

### Model errors

1. Verify API key: `curl -H "Authorization: Bearer $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages -d '{}'`
2. Check config model settings

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐
│    Telegram     │────▶│                  │
├─────────────────┤     │                  │
│    Discord      │────▶│  CleoBot Gateway │
├─────────────────┤     │                  │
│    Webchat      │────▶│    (Docker)      │
└─────────────────┘     └────────┬─────────┘
                                 │
                    ┌────────────┼────────────┐
                    ▼            ▼            ▼
              ┌──────────┐ ┌──────────┐ ┌──────────┐
              │ Anthropic│ │  CLEO    │ │ Workspace│
              │   API    │ │   CLI    │ │  Files   │
              └──────────┘ └──────────┘ └──────────┘
```

---

## References

- [Getting Started](./GETTING-STARTED.md)
- [Security Guide](./SECURITY.md)
- [CLEO Documentation](https://codluv.mintlify.app)
