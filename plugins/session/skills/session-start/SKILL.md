---
name: session-start
description: Start a new development session with optional name. Use when beginning significant work or wanting to track progress.
argument-hint: [session-name]
disable-model-invocation: true
allowed-tools: Bash(date:*),Read,Write
---

# Context
- Date and Time: !`date -Idate -Ihours -Iminutes -Iseconds`

# Task

If `$ARGUMENTS` is provided, use it to determine a applicable session name; otherwise, use a timestamp only.

Start a new development session by creating a session file in `.sessions/` with the format `YYYY-MM-DD-HHMM-$ARGUMENTS.md` (or just `YYYY-MM-DD-HHMM.md` if no name provided).

The session file should begin with:
1. Session name and timestamp as the title
2. Session overview section with start time
3. Goals section (ask user for goals if not clear)
4. Empty progress section ready for updates

After creating the file, create or update `.sessions/.current-session` to track the active session filename.

Confirm the session has started and remind the user they can:
- Update it with `/session:session-update`
- End it with `/session:session-end`
