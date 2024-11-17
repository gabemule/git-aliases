# Git Workflow Documentation 📚

## Available Commands

### 🌿 git start-branch
Creates standardized branches with ticket tracking.
```bash
git start-branch -t PROJ-123
```
[Full Documentation](commands/start-branch.md) | [Planned Improvements](improvements/update-start-branch.md)

### ✍️ git cc
Creates conventional commits with ticket references.
```bash
git cc
```
[Full Documentation](commands/conventional-commit.md) | [Planned Improvements](improvements/update-conventional-commit.md)

### 🔍 git open-pr
Streamlines PR creation process.
```bash
git open-pr
```
[Full Documentation](commands/open-pr.md) | [Planned Improvements](improvements/update-open-pr.md)

## Future Commands

See our [improvements documentation](improvements/README.md) for upcoming features:
- [Sync Command](improvements/sync-command.md) - Branch synchronization
- [Rollback Command](improvements/rollback-command.md) - Safe production rollbacks
- [Review Command](improvements/review-command.md) - PR review workflow
- [Workspace Command](improvements/workspace-command.md) - Workspace state management
- [Standup Command](improvements/standup-command.md) - Work summary generation

## Directory Structure

```
docs/
├── README.md               # This file
├── commands/              # Current command documentation
│   ├── start-branch.md
│   ├── conventional-commit.md
│   └── open-pr.md
└── improvements/          # Future improvements
    ├── README.md         # Improvements overview
    ├── update-*.md       # Current command improvements
    └── *-command.md      # New command proposals
```

## Quick Links

- [Installation Guide](../README.md#-installation)
- [Configuration Guide](../README.md#%EF%B8%8F-custom-configuration)
- [Troubleshooting](../README.md#-troubleshooting)
- [Best Practices](../README.md#-best-practices)
