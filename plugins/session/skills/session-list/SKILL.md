---
name: session-list
description: List all development sessions with their titles and dates. Use when reviewing past work or finding a specific session.
disable-model-invocation: true
allowed-tools: Read,Glob
---

# Task

List all development sessions by:

1. Check if `.sessions/` directory exists
2. List all `.md` files (excluding hidden files and `.current-session`)
3. For each session file:
   - Show the filename
   - Extract and show the session title
   - Show the date/time
   - Show first few lines of the overview if available
4. If `.sessions/.current-session` exists, highlight which session is currently active
5. Sort by most recent first

Present in a clean, readable format.
