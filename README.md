# Claude Code Plugins

mrclrchtrs marketplace for Claude Code plugins.

## Installation

Add this marketplace to Claude Code:

**From GitHub:**
```bash
/plugin marketplace add https://github.com/mrclrchtr/cc-marketplace
```

Install plugins:

```bash
/plugin install session@cc-marketplace
```

Restart Claude Code to activate plugins.

## Available Plugins

### Session
Session management system for documenting development work. Track progress, issues, solutions, and learnings in markdown files.

**Commands:**
- `/session-start [name]` - Start a new session
- `/session-update [notes]` - Add notes to current session
- `/session-end` - End session with summary
- `/session-list` - List all sessions
- `/session-current` - Show current session status
- `/session-load` - Load a previous session
- `/session-help` - Show help

## Documentation

- [Plugin Development Guide](https://code.claude.com/docs/en/plugins.md)
