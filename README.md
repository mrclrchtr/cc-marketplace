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
/plugin install review@cc-marketplace
```

Restart Claude Code to activate plugins.

## Available Plugins

### Session
Session management system for documenting development work. Track progress, issues, solutions, and learnings in markdown files.

**Commands:**
- `/session:session-start [name]` - Start a new session
- `/session:session-update [notes]` - Add notes to current session
- `/session:session-end` - End session with summary
- `/session:session-list` - List all sessions
- `/session:session-current` - Show current session status
- `/session:session-load` - Load a previous session
- `/session:session-help` - Show help

### Review
Critical review helpers for local/uncommitted changes.

**Skills:**
- `/review:uncommitted [path/glob]` - Review staged + unstaged + untracked changes before committing

## Documentation

- [Plugin Development Guide](https://code.claude.com/docs/en/plugins.md)
