# 🛠️ Custom Configuration

Complete guide to all available ChronoGit configurations.

## Branch Configuration

### Main Branch

```bash
# Set main branch (default: production)
git config workflow.mainBranch main

# Repository-specific
git config --local workflow.mainBranch develop

# Global default
git config --global workflow.mainBranch main
```

### Branch Prefixes

```bash
# Feature branches (default: feature/)
git config workflow.featurePrefix "feat/"

# Bugfix branches (default: bugfix/)
git config workflow.bugfixPrefix "fix/"

# Hotfix branches (default: hotfix/)
git config workflow.hotfixPrefix "hotfix/"

# Release branches (default: release/)
git config workflow.releasePrefix "release/"

# Documentation branches (default: docs/)
git config workflow.docsPrefix "docs/"
```

## Ticket Configuration

### Ticket Pattern

```bash
# Set ticket pattern (default: ^[A-Z]+-[0-9]+$)
git config workflow.ticketPattern "^TEAM-[0-9]+$"

# Examples:
# Default: PROJ-123
# Custom: TEAM-456
```

### Branch Tickets

```bash
# Set ticket for current branch
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket PROJ-123

# Set ticket for specific branch
git config branch.feature/task.ticket PROJ-123

# Remove ticket
git config --unset branch.feature/task.ticket
```

## PR Configuration

### Target Branch

```bash
# Set default target (default: development)
git config workflow.defaultTarget main

# Repository-specific
git config --local workflow.defaultTarget develop
```

### PR Template

```bash
# Set custom template path (default: .github/pull_request_template.md)
git config workflow.prTemplatePath ".github/custom-template.md"
```

## Configuration Levels

### 1. Repository Level
In `.git/config`:
```ini
[workflow]
    # Branch settings
    mainBranch = main
    defaultTarget = development
    
    # Branch prefixes
    featurePrefix = feature/
    bugfixPrefix = fix/
    hotfixPrefix = hotfix/
    releasePrefix = release/
    docsPrefix = docs/
    
    # Ticket settings
    ticketPattern = "^[A-Z]+-[0-9]+$"
    
    # PR settings
    prTemplatePath = ".github/pull_request_template.md"
```

### 2. Global Level
In `~/.gitconfig`:
```ini
[workflow]
    # Global defaults
    mainBranch = main
    ticketPattern = "^[A-Z]+-[0-9]+$"
    defaultTarget = development
```

### 3. System Level
In `/etc/gitconfig`:
```ini
[workflow]
    # System-wide defaults
    mainBranch = main
    ticketPattern = "^[A-Z]+-[0-9]+$"
```

## Configuration Precedence

1. Repository config (highest)
2. Global config
3. System config (lowest)

## Viewing Configuration

### View All Settings

```bash
# All settings
git config --list | grep workflow

# Specific setting
git config workflow.mainBranch
```

### View Setting Source

```bash
# Show where setting is defined
git config --show-origin workflow.mainBranch
```

## Default Values

```ini
[workflow]
    # Branch defaults
    mainBranch = production
    defaultTarget = development
    
    # Branch prefix defaults
    featurePrefix = feature/
    bugfixPrefix = bugfix/
    hotfixPrefix = hotfix/
    releasePrefix = release/
    docsPrefix = docs/
    
    # Ticket defaults
    ticketPattern = "^[A-Z]+-[0-9]+$"
    
    # PR defaults
    prTemplatePath = .github/pull_request_template.md
```

## Examples

### 1. Custom Team Setup

```bash
# Main branch
git config workflow.mainBranch main

# Team ticket pattern
git config workflow.ticketPattern "^TEAM-[0-9]+$"

# Custom prefixes
git config workflow.featurePrefix "feat/"
git config workflow.bugfixPrefix "fix/"
```

### 2. Multiple Projects

```bash
# Project A (.git/config)
[workflow]
    mainBranch = main
    ticketPattern = "^PROJA-[0-9]+$"

# Project B (.git/config)
[workflow]
    mainBranch = master
    ticketPattern = "^PROJB-[0-9]+$"
```

### 3. Personal Defaults

```bash
# ~/.gitconfig
[workflow]
    mainBranch = main
    defaultTarget = development
    ticketPattern = "^[A-Z]+-[0-9]+$"
```

## Related Documentation

- [Installation Guide](../installation/README.md)
- [Command Reference](../commands/README.md)
- [Workflow Guide](../workflow/README.md)
- [Troubleshooting](../installation/troubleshooting.md)
