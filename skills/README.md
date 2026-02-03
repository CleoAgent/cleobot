# CleoBot Skills

Skills extend CleoBot's capabilities by providing specialized tools and instructions.

## Available Skills

### Core Skills

| Skill | Description |
|-------|-------------|
| **cleo** | CLEO task management integration |
| **coding-agent** | Code generation and analysis |
| **github** | GitHub operations |
| **healthcheck** | System health monitoring |

### Communication

| Skill | Description |
|-------|-------------|
| discord | Discord operations |
| slack | Slack workspace interaction |
| imsg | iMessage (macOS) |
| bluebubbles | BlueBubbles iMessage bridge |

### Productivity

| Skill | Description |
|-------|-------------|
| apple-notes | Apple Notes management |
| apple-reminders | Apple Reminders |
| obsidian | Obsidian vault operations |
| notion | Notion integration |
| things-mac | Things 3 task manager |
| trello | Trello boards |

### Media

| Skill | Description |
|-------|-------------|
| openai-image-gen | AI image generation |
| openai-whisper-api | Speech transcription |
| sag | Text-to-speech (ElevenLabs) |
| video-frames | Video frame extraction |

### Utilities

| Skill | Description |
|-------|-------------|
| weather | Weather forecasts |
| local-places | Local business search |
| canvas | Canvas rendering |
| camsnap | Camera snapshots |

## Using Skills

Skills are loaded automatically when their SKILL.md is in the workspace's skills directory.

### Example: Enable CLEO Skill

```bash
# Copy skill to workspace (if not using bundled)
cp -r skills/cleo ~/.cleobot/skills/

# Or reference in config
# Skills in the bundled skills/ directory are auto-discovered
```

### Skill Structure

Each skill contains:

```
skill-name/
├── SKILL.md        # Instructions for the agent
├── scripts/        # Optional helper scripts
└── templates/      # Optional templates
```

## Creating Skills

See the [skill-creator](./skill-creator) skill for guidance on creating new skills.

## CLEO Skill

The **cleo** skill provides task management integration:

```bash
cleo dash           # Project dashboard
cleo list           # View tasks
cleo add "Task"     # Create task
cleo complete T001  # Mark done
cleo focus T001     # Set focus
```

This is the recommended skill for structured project work with CleoBot.
