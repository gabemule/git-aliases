# ⚙️ Configuration Guide

ChronoGit provides various configuration options to customize your workflow.

## Quick Reference

```bash
# Branch Configuration
git config workflow.mainBranch main  # Set main branch
git config workflow.mainBranch       # View main branch

# Ticket Configuration
git config branch.feature/task.ticket PROJ-123  # Set ticket
git config branch.feature/task.ticket           # View ticket
```

## Available Aliases

```bash
# Branch Management
git start-branch  # Create new branch (full command)
git start        # Create new branch (short alias)

# Commits
git cc           # Create conventional commit

# Pull Requests
git open-pr      # Create pull request (full command)
git pr          # Create pull request (short alias)

# Testing
git test        # Run tests (shows interactive menu)
```

## Branch Configuration

### Main Branch

By default, ChronoGit uses 'production' as the main branch, but you can customize this per repository:

```bash
# Set custom main branch
git config workflow.mainBranch main

# View current setting
git config workflow.mainBranch
```

This affects:
- Branch creation source
- PR target selection
- Sync operations

### Branch Types

Available branch types:
- `feature/` - New features
- `bugfix/` - Non-critical fixes
- `hotfix/` - Critical fixes
- `release/` - Release preparation
- `docs/` - Documentation

## Ticket Configuration

### Branch Tickets

Each branch can have an associated ticket:

```bash
# Set ticket for current branch
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket PROJ-123

# View current branch's ticket
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket
```

This affects:
- Commit messages
- PR titles
- PR descriptions

### Ticket Overrides

You can override the branch ticket for single operations:

```bash
# Override for single commit
git cc -t PROJ-456

# Use branch ticket (default)
git cc
```

## Environment Setup

### Required Tools

1. Git
   ```bash
   git --version  # Check installation
   ```

2. GitHub CLI
   ```bash
   gh --version   # Check installation
   gh auth login  # Authenticate
   ```

### Optional Tools

1. SSH Key
   ```bash
   ssh -T git@github.com  # Test GitHub SSH
   ```

## File Structure

```
.
├── .gitconfig           # Git aliases
├── bin/                 # Command scripts
├── docs/               # Documentation
└── tests/              # Test files
```

## Custom Configuration

### Repository-specific Settings

Create a `.git/config` file in your repository:

```ini
[workflow]
    mainBranch = main
```

### Global Settings

Edit your global `.gitconfig`:

```ini
[include]
    path = /path/to/chronogit/.gitconfig

[workflow]
    mainBranch = main
    ticketPattern = "^[A-Z]+-[0-9]+$"
```

## Testing Configuration

Verify your configuration:

```bash
# Run verification tests
git test -v

# Check specific settings
git config --get include.path
git config --get workflow.mainBranch
```

## Related Documentation

- [Installation Guide](../installation/README.md)
- [Command Reference](../commands/README.md)
- [Workflow Guide](../workflow/README.md)
- [Troubleshooting](../installation/troubleshooting.md)
