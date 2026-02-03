# Getting Started with CleoBot

CleoBot is an AI agent framework that gives Claude (and other LLMs) persistent memory, tools, and messaging integrations.

## Quick Start (5 minutes)

### 1. Prerequisites

- Docker and Docker Compose
- An Anthropic API key (or OAuth subscription)
- (Optional) Telegram bot token for messaging

### 2. Clone and Configure

```bash
git clone https://github.com/CleoAgent/cleobot.git
cd cleobot

# Copy example environment
cp .env.example .env

# Edit .env with your credentials
nano .env
```

**Required:** Set at least `ANTHROPIC_API_KEY` and `CLEOBOT_GATEWAY_TOKEN` (generate with `openssl rand -hex 24`).

### 3. Create Config Directory

```bash
mkdir -p ~/.cleobot/workspace
cp examples/configs/minimal.json ~/.cleobot/cleobot.json
```

### 4. Build and Run

```bash
docker compose build
docker compose up -d cleobot-gateway
```

### 5. Connect

Open the webchat at `http://localhost:18789` (or your server IP).

---

## Configuration

CleoBot uses JSON configuration. See `examples/configs/` for templates:

| Config | Use Case |
|--------|----------|
| `minimal.json` | Bare minimum to get started |
| `telegram-only.json` | Telegram bot integration |
| `optimized.json` | Token optimization with model tiering |

### Model Tiering (Recommended)

For cost efficiency, use different models for different tasks:

- **Opus** - Complex reasoning, creative work
- **Sonnet** - Main conversations, code generation
- **Haiku** - Heartbeats, quick tasks

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-5",
        "fallbacks": ["anthropic/claude-haiku-4-5"]
      },
      "heartbeat": {
        "model": "anthropic/claude-haiku-4-5"
      }
    }
  }
}
```

### Prompt Caching

Enable caching to reduce costs on repeated context:

```json
{
  "agents": {
    "defaults": {
      "models": {
        "anthropic/claude-sonnet-4-5": {
          "params": { "cacheRetention": "long" }
        }
      }
    }
  }
}
```

---

## Secrets Management

### Option 1: Environment Variables

Set secrets in `.env` file (not committed to git).

### Option 2: Doppler (Recommended)

For production, use [Doppler](https://doppler.com) for secrets management:

```bash
# Install Doppler CLI
curl -Ls https://cli.doppler.com/install.sh | sh

# Setup project
doppler setup

# Run CleoBot with Doppler
doppler run -- docker compose up -d
```

---

## Channels

### Telegram

1. Create a bot with [@BotFather](https://t.me/BotFather)
2. Set `TELEGRAM_BOT_TOKEN` in your environment
3. Enable in config:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing"
    }
  }
}
```

### Other Channels

CleoBot supports Discord, WhatsApp, Signal, iMessage, and more. See the full documentation for details.

---

## CLEO Integration

CleoBot works with [CLEO](https://codluv.mintlify.app) for task management:

```bash
# Install CLEO CLI
curl -fsSL https://github.com/kryptobaseddev/cleo/releases/latest/download/install.sh | bash

# Initialize in workspace
cd ~/.cleobot/workspace
cleo init
```

---

## Troubleshooting

### Gateway not starting?

Check logs: `docker compose logs cleobot-gateway`

### Can't connect to webchat?

Ensure port 18789 is accessible and `CLEOBOT_GATEWAY_TOKEN` matches your config.

### Model errors?

Verify your `ANTHROPIC_API_KEY` is valid and has credits.

---

## Next Steps

- Read the [full documentation](https://github.com/CleoAgent/cleobot/docs)
- Join the community on [Discord](https://discord.com/invite/clawd)
- Explore [skills and plugins](https://clawhub.com)
