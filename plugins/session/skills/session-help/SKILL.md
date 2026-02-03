---
name: session-help
description: Show help and reference for the session management system. Use when learning how sessions work or available commands.
disable-model-invocation: true
---

Show help for the session management system:

## Session Management Commands

The session system helps document development work for future reference.

### Available Commands:

- `/session:session-start [name]` - Start a new session with optional name
- `/session:session-update [notes]` - Add notes to current session
- `/session:session-end` - End session with comprehensive summary
- `/session:session-list` - List all session files
- `/session:session-current` - Show current session status
- `/session:session-help` - Show this help

### How It Works:

1. Sessions are markdown files in `.sessions/`
2. Files use `YYYY-MM-DD-HHMM-name.md` format
3. Only one session can be active at a time
4. Sessions track progress, issues, solutions, and learnings

### Best Practices:

- Start a session when beginning significant work
- Update regularly with important changes or findings
- End with thorough summary for future reference
- Review past sessions before starting similar work

### Example Workflow:

```
/session:session-start refactor-auth
/session:session-update Added Google OAuth restriction
/session:session-update Fixed Next.js 15 params Promise issue
/session:session-end
```
