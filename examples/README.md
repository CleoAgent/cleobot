# CleoBot Examples

This directory contains example configurations for different use cases.

## Configuration Files

Located in `configs/`:

| File | Description |
|------|-------------|
| `minimal.json` | Bare minimum to get started - just sets the model |
| `telegram-only.json` | Telegram bot integration with sensible defaults |
| `optimized.json` | Full model tiering, caching, and cost optimization |

## Usage

Copy the appropriate config to your CleoBot config directory:

```bash
# Option 1: During quick setup
./scripts/quick-setup.sh

# Option 2: Manual copy
cp examples/configs/optimized.json ~/.cleobot/cleobot.json
```

## Configuration Tips

### Start Simple
Begin with `minimal.json` and add features as needed.

### Model Tiering
Use different models for different tasks:
- **Opus** - Complex reasoning, creative work
- **Sonnet** - Main conversations, code generation  
- **Haiku** - Heartbeats, quick classification tasks

### Caching
Enable prompt caching for Anthropic models to reduce costs:
```json
{
  "params": {
    "cacheRetention": "long"
  }
}
```

### Security
Always set a strong gateway token:
```bash
openssl rand -hex 24
```

## More Examples

For a complete configuration reference, see:
- [Getting Started](../docs/GETTING-STARTED.md)
- [Security Guide](../docs/SECURITY.md)
