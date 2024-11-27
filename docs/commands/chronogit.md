# ⚙️ ChronoGit Command

Interactive configuration manager for ChronoGit. Provides a user-friendly way to view and manage all workflow settings.

## Usage

```bash
# Show help
git chronogit -h

# Start interactive configuration
git chronogit
```

## Options

- `-h` - Show help message

## Interactive Menu

```
ChronoGit Configuration

1) Show all configurations
2) Set configuration
3) Reset configuration
4) Exit
```

## Configuration Scopes

Each setting can be configured at different scopes:

- `global` - Applies to all repositories
- `local` - Applies to current repository
- `branch` - Applies to current branch

## Configuration Display

Each setting shows its values across all scopes and the effective value:

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

## Interactive Usage

### 1. Show Configurations

1. Run `git chronogit`
2. Select `1) Show all configurations`
3. View current settings at all scopes:
   - Global (applies to all repositories)
   - Local (applies to current repository)
   - Branch (applies to current branch)
   - Default (built-in defaults)
   - Effective (currently active value)
4. Press Enter to return to menu

### 2. Set Configuration

1. Run `git chronogit`
2. Select `2) Set configuration`
3. Choose configuration to set:
   - Main branch
   - Default target
   - Branch prefixes
   - etc.
4. Select scope:
   - Global (for all repositories)
   - Local (for current repository)
   - Branch (for current branch)
5. Enter new value
6. Press Enter to return to menu

### 3. Reset Configuration

1. Run `git chronogit`
2. Select `3) Reset configuration`
3. Choose configuration to reset
4. Select scope to reset:
   - Global
   - Local
   - Branch
5. Press Enter to return to menu

## Examples

### Team Setup

```bash
# Start configuration
git chronogit

# Set main branch
1. Select: 2) Set configuration
2. Choose: workflow.mainBranch
3. Select scope: global
4. Enter: main

# Set ticket pattern
1. Select: 2) Set configuration
2. Choose: workflow.ticketPattern
3. Select scope: global
4. Enter: ^TEAM-[0-9]+$
```

### Project Setup

```bash
# View project settings
git chronogit
Select: 1) Show all configurations

# Set project branch prefixes
1. Select: 2) Set configuration
2. Choose: workflow.featurePrefix
3. Select scope: local
4. Enter: feat/
```

### Branch Setup

```bash
# View branch settings
git chronogit
Select: 1) Show all configurations

# Set branch target
1. Select: 2) Set configuration
2. Choose: workflow.defaultTarget
3. Select scope: branch
4. Enter: production
```

## Related ChronoGit Commands

- [git cc](conventional-commit.md) - Commit changes after cherry-picking
- [git jerrypick](jerrypick.md) - Cherry-pick commits interactively
- [git open-pr](open-pr.md) - Create PR with commit history
- [git rollback](rollback.md) - Safely revert changes in the main branch
- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git sync](sync.md) - Synchronize your branch with the main branch and remote
- [git workspace](workspace.md) - Manage and switch between different workspaces

## Useful Built-in Commands

- [git stash](https://git-scm.com/docs/git-stash) - Temporarily store modified, tracked files
- [git status](https://git-scm.com/docs/git-status) - Show the working tree status
- [git log](https://git-scm.com/docs/git-log) - Show commit logs
- [git diff](https://git-scm.com/docs/git-diff) - Show changes between commits, commit and working tree, etc
