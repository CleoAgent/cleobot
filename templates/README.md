# CleoBot Templates

This directory contains templates for setting up new CleoBot agents.

## Workspace Templates

The `workspace/` directory contains template files for agent workspaces:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Workspace guidelines and protocols |
| `SOUL.md` | Agent identity and personality |
| `USER.md` | Information about the human user |
| `TOOLS.md` | Local tool configurations |
| `MEMORY.md` | Long-term memory template |
| `memory/` | Directory for daily memory files |

## Usage

### Automatic (Recommended)

Run the quick setup script:

```bash
./scripts/quick-setup.sh
```

This will automatically copy workspace templates if the workspace is empty.

### Manual

Copy templates to your workspace:

```bash
cp -r templates/workspace/* ~/.cleobot/workspace/
```

## Customization

After copying, customize each file:

1. **SOUL.md** - Define your agent's personality and values
2. **USER.md** - Add information about yourself
3. **TOOLS.md** - Document your API keys and preferences
4. **MEMORY.md** - Will be populated as your agent learns

## CLEO Integration

The templates include CLEO injection markers (`<!-- CLEO:START -->` / `<!-- CLEO:END -->`).

After copying templates, run:

```bash
cd ~/.cleobot/workspace
cleo init
cleo upgrade
```

This will inject CLEO task management instructions.

## Creating New Templates

To add custom templates:

1. Create files in `templates/workspace/`
2. Use clear markdown formatting
3. Include helpful comments
4. Test with `quick-setup.sh`
