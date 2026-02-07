# Contributing to CleoBot

Welcome! 🧠

CleoBot is a fork of [CleoBot](https://github.com/openclaw/openclaw), enhanced with [CLEO](https://codluv.mintlify.app) cognitive scaffolding.

## Quick Links

- **GitHub:** https://github.com/CleoAgent/cleobot
- **Upstream:** https://github.com/openclaw/openclaw
- **CLEO Docs:** https://codluv.mintlify.app

## How to Contribute

1. **Bugs & small fixes** → Open a PR!
2. **New features** → Open an issue first to discuss
3. **CLEO Integration** → PRs improving CLEO integration are especially welcome

## Before You PR

```bash
# Install dependencies
pnpm install

# Build
pnpm build
pnpm ui:build

# Run checks
pnpm check

# Run tests
pnpm test
```

- Test locally with your CleoBot instance
- Keep PRs focused (one thing per PR)
- Describe what & why

## Project Structure

```
cleobot/
├── src/              # TypeScript source
│   ├── agents/       # Agent logic
│   ├── cli/          # CLI commands
│   ├── config/       # Configuration
│   └── gateway/      # Gateway server
├── ui/               # Webchat UI (Lit)
├── docs/             # Documentation
├── examples/         # Config examples
├── templates/        # Workspace templates
├── skills/           # Agent skills
└── scripts/          # Helper scripts
```

## Key Differences from CleoBot

- **Branding:** `CLEOBOT_*` env vars, `.cleobot` directories
- **CLEO CLI:** Bundled in Docker image
- **Skills:** Includes CLEO task management skill
- **Templates:** Ready-to-use workspace templates

## Upstream Sync

We periodically sync with upstream CleoBot. If you want a feature that exists in CleoBot but not CleoBot, let us know!

## AI-Generated Code Welcome! 🤖

Built with Claude, Gemini, or other AI tools? Awesome!

## License

MIT - same as upstream CleoBot.

---

*Thank you for contributing!*
