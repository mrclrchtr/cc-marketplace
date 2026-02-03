---
name: session-load
description: Load a previous session to review its content. Use when resuming work or reviewing past sessions.
argument-hint: [session-name]
disable-model-invocation: true
allowed-tools: Read,Glob
---

# Load a session

> CRITICAL: This command is READ-ONLY.
> NEVER modify, edit, or update any session file content.

## Context

- Sessions: @.sessions/

## Preflight

- If `$ARGUMENTS` is provided:
Set `$SESSION_NAME` to `$ARGUMENTS`, ensuring it is a valid session filename with `.md` extension.

- If `$ARGUMENTS` is not provided
Set `$SESSION_NAME` to the current session name from `.sessions/.current-session`, if it exists.
If it does not exist, STOP and prompt the user to specify a session name.

## Task

1. Take the `$SESSION_NAME` and check if a file exists at `.sessions/$SESSION_NAME`.
2. If the session file does **not** exist:
   - Notify the user that the session was not found.
   - List all available `.md` session files located in the `.sessions/` directory.
   - Prompt the user to choose from the list.
3. If the session file **does** exist:
   - Update the current session pointer by writing the `$SESSION_NAME` filename to `.sessions/.current-session`.
4. Read the session file content.
5. Check for running Background Bash Shells.

## Output

```markdown
Loaded the session `$SESSION_NAME` successfully. Here is a summary of the session:

    <session content summary>

Let's continue working on this session.
```
