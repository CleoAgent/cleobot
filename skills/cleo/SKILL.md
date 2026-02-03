# CLEO Task Management Skill

CLEO is a task management system designed for AI agents. Use this skill when you need to:
- Create, update, or complete tasks
- Track work in structured projects
- Manage epics and subtasks
- Query task status and dependencies

## Quick Reference

### Session Management
```bash
cleo session start "Working on feature X"
cleo session status
cleo session end --notes "Completed implementation"
```

### Task Operations
```bash
# List tasks
cleo list                    # All pending tasks
cleo list --status done      # Completed tasks
cleo list --label security   # Filter by label
cleo tree                    # Show hierarchy

# Create tasks
cleo add "Implement auth" --priority high --label security
cleo add "Add tests" --parent T001  # Create subtask

# Update tasks
cleo update T001 --status in-progress
cleo update T001 --notes "Started implementation"
cleo complete T001

# View details
cleo show T001
cleo deps T001               # Show dependencies
```

### Focus Mode
```bash
cleo focus T001              # Set current focus
cleo focus                   # Show current focus
cleo focus --clear           # Clear focus
```

### Analysis
```bash
cleo analyze                 # Task triage and priorities
cleo next                    # Suggest next task
cleo blockers                # Show blocked tasks
cleo stats                   # Project statistics
```

### Dashboard
```bash
cleo dash                    # Project overview
cleo phases                  # Phase progress
cleo history                 # Completion timeline
```

## Task Types

| Type | Description | Example |
|------|-------------|---------|
| `epic` | Large feature/initiative | "Authentication System" |
| `task` | Standard work item | "Implement JWT validation" |
| `subtask` | Small piece of a task | "Add token refresh logic" |

## Priorities

- `critical` - Blocking issues, security
- `high` - Important features
- `medium` - Standard work (default)
- `low` - Nice to have

## Best Practices

1. **Start sessions** before working on tasks
2. **Set focus** on current task for context
3. **Use hierarchy** - break epics into tasks into subtasks
4. **Add labels** for categorization (security, ui, api, etc.)
5. **Complete tasks** when done to track progress

## CLEO CLI in Container

CLEO CLI is installed at `/usr/local/bin/cleo`. Initialize in workspace:

```bash
cd /home/node/.cleobot/workspace
cleo init
```

## Documentation

Full docs: https://codluv.mintlify.app
