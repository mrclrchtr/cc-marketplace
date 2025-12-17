# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project: cc-marketplace

**You are an expert in Claude Code plugin development.** This is mrclrchtr's personal marketplace for Claude Code plugins.

## Repository Structure

```
cc-marketplace/
├── plugins/           # Plugin implementations
│   └── session/      # Session management plugin
│       ├── .claude-plugin/
│       │   └── plugin.json       # Plugin manifest
│       └── commands/             # Slash commands (*.md)
├── docs/             # Documentation and patterns
│   ├── command.md                # Slash command guide
│   ├── context.md                # Context gathering patterns
│   ├── optimization-patterns.md  # Optimization guide
│   ├── sub-agent.md              # Sub-agent patterns
│   └── claude-md.md              # CLAUDE.md guide
├── legacy/           # Legacy code (DO NOT MODIFY)
└── README.md         # Installation and usage
```

## Plugin Architecture

### Plugin Structure
Each plugin follows this structure:
```
plugins/{plugin-name}/
├── .claude-plugin/
│   └── plugin.json           # Required: Plugin manifest
└── commands/                 # Slash command files
    └── {command-name}.md     # Command implementation
```

### Plugin Manifest Format
Location: `plugins/{name}/.claude-plugin/plugin.json`

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Brief description of plugin functionality",
  "repository": "https://github.com/mrclrchtr/cc-marketplace",
  "author": {
    "name": "mrclrchtr",
    "url": "https://github.com/mrclrchtr"
  },
  "commands": [
    "./commands/command-name.md"
  ]
}
```

**Critical**: Command paths in `plugin.json` MUST be relative paths starting with `./commands/`

## Slash Command Development

Commands are markdown files in `plugins/{plugin-name}/commands/` directory.

### Command File Structure
```markdown
---
argument-hint: [optional args]    # Shows in autocomplete
description: Brief description     # Command summary
model: haiku|sonnet|opus          # Optional: Model selection
allowed-tools: Read,Edit,Bash     # Required if using !` bash execution
---

# Context
- Current time: !`date +%Y-%m-%d\ %I:%M\ %p`
- Other context as needed

# Task
Handle $ARGUMENTS and perform specific actions.
```

### Key Patterns

**Dynamic Context with Bash:**
- Syntax: `!`command`` executes bash and injects output
- Example: `!`date +%Y-%m-%d`` → `2025-12-17`
- **REQUIRED**: Must include `allowed-tools` with appropriate `Bash()` patterns

**Arguments:**
- Use `$ARGUMENTS` to access user input
- Example: `/command foo bar` → `$ARGUMENTS` = "foo bar"

**Model Selection:**
- `haiku` - Fast, simple tasks (status checks)
- `sonnet` - Balanced for most tasks (default)
- `opus` - Complex multi-step operations

**Tool Restrictions:**
- Limit tools to minimum needed for security
- Pattern: `Bash(git:*)`, `Bash(fd:*)`, `Edit(@src/**/*.js)`
- Each tool type needs separate pattern: `Bash(fd:*),Bash(rg:*),Bash(git:*)`

### Session Plugin Pattern
The session plugin demonstrates a complete workflow:

1. **session-start** - Initialize session file in `.sessions/` directory
2. **session-update** - Append timestamped updates with git/todo status
3. **session-end** - Generate comprehensive summary and clear current session
4. **session-current** - Show active session status
5. **session-list** - List all historical sessions
6. **session-load** - Load previous session
7. **session-help** - Display command reference

**State Management**: Uses `.sessions/.current-session` file to track active session filename.

## Development Commands

This is a documentation repository with no build process. Use standard file operations:

```bash
# Search for files
fd -t f -e md -e json

# Search content
rg "pattern" --type md

# List directory structure
eza -la plugins/

# View file
bat plugins/session/.claude-plugin/plugin.json
```

## Critical Rules

### Plugin Development
1. **Plugin Manifest**: Command paths MUST use `./commands/` relative paths
2. **Command Files**: Always include frontmatter with `description`
3. **Bash Execution**: Commands using `!` MUST include `allowed-tools` with appropriate Bash patterns
4. **State Files**: Session state files go in `.sessions/` (create if needed)
5. **Namespacing**: Use descriptive command names like `session-start` not just `start`

### Documentation
1. **Reference Docs**: Always check @docs/ for patterns before implementing
   - @docs/command.md - Complete command creation guide
   - @docs/optimization-patterns.md - Efficiency patterns
   - @docs/context.md - Context gathering commands
2. **Examples**: Use existing session plugin as reference implementation

### Legacy Code
1. **DO NOT MODIFY**: Files in `legacy/` directory are preserved for reference only
2. **NEW PLUGINS**: Always create in `plugins/{name}/` directory

## File References

When implementing plugins or commands, reference these cornerstone files:

- @plugins/session/.claude-plugin/plugin.json - Plugin manifest example
- @plugins/session/commands/session-start.md - Command pattern with state initialization
- @plugins/session/commands/session-update.md - Command pattern with state updates
- @plugins/session/commands/session-end.md - Command pattern with comprehensive summaries
- @docs/command.md - Complete guide to command development
- @docs/optimization-patterns.md - Performance and efficiency patterns

## Installation & Usage

**Add Marketplace:**
```bash
/plugin marketplace add https://github.com/mrclrchtr/cc-marketplace
```

**Install Plugin:**
```bash
/plugin install session@cc-marketplace
```

**Restart Required**: Restart Claude Code after installing plugins.

## Plugin Ideas & Patterns

### Common Plugin Types
- **Session/Task Management**: Document development work (see session plugin)
- **Code Analysis**: Analyze patterns, complexity, dependencies
- **Project Management**: Track issues, PRs, releases
- **Documentation**: Generate/update docs, ADRs, changelogs
- **Testing**: Run tests, generate test cases, coverage reports
- **Deployment**: Deploy, rollback, environment management

### State Management Patterns
- **Current State**: Use `.{plugin-name}/.current-*` files
- **History**: Store in `.{plugin-name}/` directory
- **Format**: Markdown for human-readable history

### Command Naming Conventions
- Use `{plugin-name}-{action}` format for clarity
- Examples: `session-start`, `session-end`, `deploy-staging`

## Optimization Principles

1. **Minimal Context**: Gather only essential information
2. **Right-Sized Model**: Use `haiku` for simple tasks, `opus` only when needed
3. **Tool Restrictions**: Limit to minimum required tools
4. **Parallel Execution**: Batch independent operations (max 7)
5. **Progressive Loading**: Check before loading large context

See @docs/optimization-patterns.md for detailed patterns.
