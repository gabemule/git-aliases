# ⚙️ ChronoGit Command

Interactive configuration manager for ChronoGit.

## Usage

```bash
git chronogit
```

Shows interactive menu:
```
ChronoGit Configuration

1) Show all configurations
2) Set configuration
3) Reset configuration
4) Exit
```

## Available Configurations

| Key | Default | Description |
|-----|---------|-------------|
| workflow.mainBranch | production | Main branch for repository |
| workflow.defaultTarget | development | Default target for PRs |
| workflow.ticketPattern | ^[A-Z]+-[0-9]+$ | Pattern for ticket references |
| workflow.featurePrefix | feature/ | Prefix for feature branches |
| workflow.bugfixPrefix | bugfix/ | Prefix for bugfix branches |
| workflow.hotfixPrefix | hotfix/ | Prefix for hotfix branches |
| workflow.releasePrefix | release/ | Prefix for release branches |
| workflow.docsPrefix | docs/ | Prefix for documentation branches |
| workflow.prTemplatePath | .github/pull_request_template.md | Path to PR template |

## Configuration Scopes

Each setting can be configured at different scopes:

- `global` - Applies to all repositories
- `local` - Applies to current repository
- `branch` - Applies to current branch

## Configuration Display

Each setting shows:
```
workflow.mainBranch - Main branch for repository
  Global:    main
  Local:     production
  Branch:    Not set
  Default:   production
  Effective: production (local)
```

The effective value follows this precedence:
1. Branch configuration (highest)
2. Local repository configuration
3. Global configuration
4. Default values (lowest)

## Interactive Usage

### 1. Show Configurations

1. Run `git chronogit`
2. Select `1) Show all configurations`
3. View current settings at all scopes
4. Press Enter to return to menu

### 2. Set Configuration

1. Run `git chronogit`
2. Select `2) Set configuration`
3. Choose configuration to set
4. Select scope (global/local/branch)
5. Enter new value
6. Press Enter to return to menu

### 3. Reset Configuration

1. Run `git chronogit`
2. Select `3) Reset configuration`
3. Choose configuration to reset
4. Select scope to reset
5. Press Enter to return to menu

## Examples

### Team Setup

```bash
# View current settings
git chronogit
# Select: 1) Show all configurations

# Set main branch
git chronogit
# Select: 2) Set configuration
# Choose: workflow.mainBranch
# Scope: global
# Value: main

# Set ticket pattern
git chronogit
# Select: 2) Set configuration
# Choose: workflow.ticketPattern
# Scope: global
# Value: ^TEAM-[0-9]+$
```

### Project Setup

```bash
# View project settings
git chronogit
# Select: 1) Show all configurations

# Set project branch prefixes
git chronogit
# Select: 2) Set configuration
# Choose: workflow.featurePrefix
# Scope: local
# Value: feat/
```

### Branch Setup

```bash
# View branch settings
git chronogit
# Select: 1) Show all configurations

# Set branch target
git chronogit
# Select: 2) Set configuration
# Choose: workflow.defaultTarget
# Scope: branch
# Value: production
```

## Related Commands

- [git start-branch](start-branch.md) - Uses branch configurations
- [git cc](conventional-commit.md) - Uses ticket pattern
- [git open-pr](open-pr.md) - Uses PR configurations
