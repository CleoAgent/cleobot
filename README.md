# 🧠 CleoBot — AI Agent with CLEO Brain

<p align="center">
  <strong>Cognitive Layer for Externalized Operations</strong>
</p>

<p align="center">
  <a href="https://github.com/CleoAgent/cleobot"><img src="https://img.shields.io/github/stars/CleoAgent/cleobot?style=for-the-badge" alt="GitHub Stars"></a>
  <a href="https://github.com/CleoAgent/cleobot/releases"><img src="https://img.shields.io/github/v/release/CleoAgent/cleobot?include_prereleases&style=for-the-badge" alt="GitHub release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="MIT License"></a>
</p>

**CleoBot** is an AI agent framework that gives Claude (and other LLMs) persistent memory, task management, and multi-channel communication. Built on [OpenClaw](https://github.com/openclaw/openclaw), enhanced with [CLEO](https://codluv.mintlify.app) cognitive scaffolding.

## Features

- 🧠 **CLEO Brain** — Integrated task management with structured reasoning (RCSD/IVTR protocols)
- 💬 **Multi-Channel** — Telegram, Discord, WhatsApp, Signal, Slack, iMessage, and more
- 🔧 **Extensible Tools** — File operations, web search, browser control, code execution
- 💾 **Persistent Memory** — Workspace files, daily notes, long-term memory
- 🔐 **Security First** — Non-root Docker, Doppler secrets, gateway auth
- ⚡ **Model Tiering** — Use Opus for complex tasks, Haiku for heartbeats, optimize costs

## Quick Start

```bash
# Clone the repo
git clone https://github.com/CleoAgent/cleobot.git
cd cleobot

# Setup environment
cp .env.example .env
# Edit .env with your ANTHROPIC_API_KEY and CLEOBOT_GATEWAY_TOKEN

# Create config directory
mkdir -p ~/.cleobot/workspace
cp examples/configs/minimal.json ~/.cleobot/cleobot.json

# Build and run
docker compose build
docker compose up -d cleobot-gateway
```

Open `http://localhost:18789` in your browser.

📖 See [Getting Started](docs/GETTING-STARTED.md) for detailed instructions.

## Authentication

CleoBot features a built-in authentication system for secure web UI access:

**First Run:**
- Visit `http://localhost:18789`
- You'll see a setup wizard
- Create your admin username and password
- System generates an API key for programmatic access

**Login:**
- Username/password authentication
- 30-day session cookies
- API keys for scripts and integrations

**API Endpoints:**
- `POST /api/auth/setup` — Create first admin
- `POST /api/auth/sign-in` — User login
- `GET /api/auth/session` — Check authentication
- `POST /api/auth/sign-out` — Logout

**Legacy Compatibility:**
- Old gateway tokens still work
- Set `CLEOBOT_GATEWAY_TOKEN` for backward compatibility

📖 See [Authentication Guide](docs/AUTH.md) for details.

## Configuration

CleoBot uses JSON configuration files. Example configs in `examples/configs/`:

| Config | Use Case |
|--------|----------|
| `minimal.json` | Bare minimum to get started |
| `telegram-only.json` | Telegram bot integration |
| `optimized.json` | Full model tiering and caching |

### Model Tiering (Recommended)

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

## CLEO Integration

CleoBot includes the CLEO CLI for task management:

```bash
# In the container
cleo init                    # Initialize task tracking
cleo add "My first task"     # Create a task
cleo list                    # View tasks
cleo dash                    # Project dashboard
```

📖 See [CLEO Documentation](https://codluv.mintlify.app) for full reference.

## Security

- 🔐 **Gateway Auth** — Always set `CLEOBOT_GATEWAY_TOKEN`
- 🐳 **Non-Root** — Runs as `node` user (uid 1000)
- 🔒 **Doppler** — Recommended for production secrets

📖 See [Security Guide](docs/SECURITY.md) for best practices.

## Environment Variables

Required:
- `ANTHROPIC_API_KEY` — Your Anthropic API key
- `CLEOBOT_GATEWAY_TOKEN` — Gateway authentication (generate: `openssl rand -hex 24`)

Optional:
- `TELEGRAM_BOT_TOKEN` — For Telegram integration
- `DISCORD_BOT_TOKEN` — For Discord integration
- `BRAVE_API_KEY` — For web search
- `AGENTMAIL_API_KEY` — For AI email

## Project Structure

```
cleobot/
├── src/                    # TypeScript source
├── ui/                     # Webchat UI (Lit)
├── docs/                   # Documentation
├── examples/configs/       # Example configurations
├── skills/                 # Agent skills
└── docker-compose.yml      # Container orchestration
```

## Development

```bash
# Install dependencies
pnpm install

# Build
pnpm build
pnpm ui:build

# Run locally
node dist/index.js gateway --bind loopback
```

## Credits

CleoBot is a fork of [OpenClaw](https://github.com/openclaw/openclaw), enhanced with CLEO cognitive scaffolding.

- **OpenClaw** — The original personal AI assistant framework
- **CLEO** — Task management system for AI agents

## License

MIT License — see [LICENSE](LICENSE) for details.

---

*Built by [Cleo](https://github.com/CleoAgent) 🧠*
