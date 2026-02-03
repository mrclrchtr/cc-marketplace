---
name: uncommitted
description: Critically review uncommitted git changes (staged + unstaged + untracked) before committing.
argument-hint: [path/glob]
allowed-tools: Bash(git:*), Bash(test:*), Bash(find:*), Bash(grep:*), Bash(wc:*), Read
---

# Context

- Branch: !`git branch --show-current 2>/dev/null || echo "(not a git repo)"`
- File status: !`git status --porcelain 2>/dev/null || echo "(not a git repo)"`
- Staged stats: !`git --no-pager diff --stat --cached 2>/dev/null || true`
- Unstaged stats: !`git --no-pager diff --stat 2>/dev/null || true`
- Recent commits: !`git --no-pager log --oneline -5 2>/dev/null || true`

# Task

Review uncommitted changes in the working tree.

- If `$ARGUMENTS` is provided, focus the review on those paths (treat it like a path or glob).
- Review **staged**, **unstaged**, and **untracked** files.
- Start with the stats above; then use `git diff` (and `git diff --cached`) to inspect the actual changes.

## Focus areas (prioritize actual problems)

- **Path accuracy**: Any moved/renamed files? Config/CI paths still correct?
- **Correctness**: Bugs, broken logic, missing edge handling at boundaries.
- **Completeness**: TODO/FIXME, commented-out code, debug artifacts, missing updates.
- **Consistency**: Lint/format violations, inconsistent naming, copy/paste duplication.
- **Security**: Secrets, unsafe shelling out, injection risks, overly-broad permissions.
- **Tests**: Are changes covered? Are tests meaningful (assert behavior, not implementation)?
- **Project rules**: If a `CLAUDE.md` exists, call out any violated constraints or needed updates.
- **Docs sync**: If behavior/config changed, note what docs need updating.

## Tests (ask first)

Detect likely test commands (from `package.json`, `Makefile`, common configs). **Do not run tests by default.**

- Propose the most likely test command(s).
- Ask the user whether to run them.
- If the user approves, run the chosen test command and report results.

## Output format

**Summary**
- 2-3 lines describing the changes and overall assessment

**Critical Issues**
- Only blocking problems that MUST be fixed (broken CI paths, missing files, failing logic)
- Include specific files and line numbers when possible

**Improvements (Should Address)**
- Non-blocking but important issues

**Suggested Tests**
- Command(s) to run and why

**Test Results** (only if tests were run)
- Command executed: [exact command]
- Pass/Fail status
- Any new failures introduced by changes

Be direct. Focus on actual issues, not hypothetical edge cases.
