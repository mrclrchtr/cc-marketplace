---
name: session-current
description: Show the current active session status including duration and recent updates. Use when checking progress or session state.
disable-model-invocation: true
allowed-tools: Read
---

# Task

Show the current session status by:

1. Check if `.sessions/.current-session` exists
2. If no active session, inform user and suggest starting one
3. If active session exists:
   - Show session name and filename
   - Calculate and show duration since start
   - Show last few updates
   - Show current goals/tasks
   - Remind user of available commands

Keep the output concise and informative.
