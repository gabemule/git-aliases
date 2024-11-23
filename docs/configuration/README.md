# ⚙️ Configuration Guide

ChronoGit provides various configuration options to customize your workflow.

## Quick Reference

```bash
# View all configurations
git chronogit

# Set configuration
git chronogit
# Select: 2) Set configuration
# Choose setting to modify
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

# Configuration
git chronogit    # Manage workflow settings

# Testing
git test        # Run tests (shows interactive menu)
```

## Branch Configuration

### Main Branch

By default, ChronoGit uses 'production' as the main branch, but you can customize this:

```bash
# View current configuration
git chronogit
# Select: 1) Show all configurations

# Change main branch
git chronogit
# Select: 2) Set configuration
# Choose: workflow.mainBranch
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

Each prefix can be customized using the chronogit command.

## Ticket Configuration

### Branch Tickets

Each branch automatically stores its associated ticket when created with `git start-branch`. The ticket is then used for:
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
├── .gitconfig           # Git configuration
├── bin/                 # Command scripts
├── docs/               # Documentation
└── tests/              # Test files
```

## Configuration Files

### .gitconfig

The workflow settings can be configured at different levels:

#### 1. Global (~/.gitconfig)
For settings that apply to all repositories:
```ini
[workflow]
    # Branch settings
    mainBranch = production
    defaultTarget = development
    
    # Branch prefixes
    featurePrefix = feature/
    bugfixPrefix = bugfix/
    hotfixPrefix = hotfix/
    releasePrefix = release/
    docsPrefix = docs/
    
    # Ticket settings
    ticketPattern = ^[A-Z]+-[0-9]+$
    
    # PR settings
    prTemplatePath = .github/pull_request_template.md
```

#### 2. Local (.git/config)
For repository-specific settings:
```ini
[workflow]
    # Override global settings for this repository
    mainBranch = main
    defaultTarget = staging
    ticketPattern = ^TEAM-[0-9]+$
```

#### 3. Branch
For branch-specific settings:
```ini
[branch "feature/task"]
    # Settings specific to this branch
    ticket = PROJ-123
```

### Configuration Precedence

When a setting is requested, it's resolved in this order:
1. Branch configuration (if applicable)
2. Local repository configuration
3. Global configuration
4. Default values

To manage these settings at any level, use:
```bash
git chronogit
# Select: 2) Set configuration
# Choose setting to modify
# Select scope (global/local/branch)
```

See [chronogit command](../commands/chronogit.md) for detailed configuration options.

## Testing Configuration

Verify your configuration:

```bash
# Run verification tests
git test -v

# View current settings
git chronogit
```

## Related Documentation

- [Installation Guide](../installation/README.md)
- [Command Reference](../commands/README.md)
- [Workflow Guide](../workflow/README.md)
- [Troubleshooting](../installation/troubleshooting.md)
