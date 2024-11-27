# 🔙 Rollback Command

Provides a safe and interactive way to revert changes in the main branch, creating a new branch for review before applying the rollback, with automatic conflict resolution using the configured mergetool.

## Usage

### Basic Usage

```bash
# Show help
git rollback -h

# Interactive mode
git rollback

# Dry run mode
git rollback --dry-run

# Skip verification
git rollback --skip-verify

# Continue after resolving conflicts
git rollback --continue
```

### Options

- `-h` - Show help message
- `--dry-run` - Preview rollback changes without creating branch
- `--skip-verify` - Skip verification step
- `--continue` - Continue rollback after resolving conflicts

## Automatic Features

### 1. Main Branch Detection
Uses the configured main branch from git config:
```bash
$ git rollback
Using main branch: production (configured in git config)
```

### 2. Commit Selection with Pagination
Displays recent commits with navigation:
```bash
Recent changes in production:
↑/↓ to navigate, Enter to select, 'n' for next page, 'p' for previous page
> abc123 - feat: add user authentication (2 days ago) by dev1
  def456 - fix: correct login validation (1 day ago) by dev2
  ghi789 - style: update button colors (1 hour ago) by dev3
[1-5/20 commits]
```

### 3. Automatic Branch Creation
Creates a new branch for the rollback:
```bash
Creating rollback branch...
Rollback branch created: rollback/production_20230615_143022
```

### 4. Automatic Conflict Resolution
When conflicts occur during the rollback process, the configured mergetool is automatically launched:
```bash
Conflict detected in file: src/auth/login.js
Launching configured mergetool...
```

## Interactive Usage

### Full Interactive Flow

```bash
$ git rollback
Using main branch: production (configured in git config)
Recent changes in production:
[Commit selection interface]

Select commit hash to rollback to: abc123
Creating rollback branch...
Reverting changes...
Rollback branch created: rollback/production_20230615_143022
Please review changes and merge through PR process
```

### Dry Run Mode

```bash
$ git rollback --dry-run
[DRY-RUN] Would create branch: rollback/production_20230615_143022
[DRY-RUN] Would revert commits from abc123 to HEAD
```

### Continuing After Conflict Resolution

```bash
$ git rollback --continue
Continuing rollback process...
Rollback completed successfully
```

## Error Handling

### Fetch Failed
```bash
$ git rollback
Error: Failed to fetch latest changes
```

### Revert Failed
```bash
$ git rollback
Error: Failed to revert changes
Conflict detected. Launching configured mergetool...
Please resolve conflicts using the mergetool.
After resolving, run 'git rollback --continue'
```

### Push Failed
```bash
$ git rollback
Error: Failed to push rollback branch
```

## Verification

The command includes a verification step:
```bash
Verifying changes...
Changes to be reverted:
 M src/auth/login.js
 M src/styles/buttons.css
✓ Clean rollback possible
```

## Workflow Steps

1. Start the rollback process:
   ```bash
   git rollback
   ```
2. Select the commit to rollback to
3. If conflicts occur, use the automatically launched mergetool to resolve them
4. Continue the rollback process after conflict resolution:
   ```bash
   git rollback --continue
   ```
5. Review the changes in the rollback branch
6. Create a PR to merge the rollback:
   ```bash
   git pr -t production
   ```
7. After review and approval, merge the rollback PR

## Related ChronoGit Commands

- [git chronogit](chronogit.md) - Configure settings
- [git cc](conventional-commit.md) - Create conventional commits
- [git jerrypick](jerrypick.md) - Cherry-pick commits interactively
- [git open-pr](open-pr.md) - Create PR for the rollback
- [git start-branch](start-branch.md) - Create new branches
- [git sync](sync.md) - Synchronize branches before rollback
- [git workspace](workspace.md) - Manage and switch between different workspaces

## Useful Built-in Commands

- [git stash](https://git-scm.com/docs/git-stash) - Temporarily store modified, tracked files
- [git status](https://git-scm.com/docs/git-status) - Show the working tree status
- [git log](https://git-scm.com/docs/git-log) - Show commit logs
- [git diff](https://git-scm.com/docs/git-diff) - Show changes between commits, commit and working tree, etc
- [git mergetool](https://git-scm.com/docs/git-mergetool) - Run merge conflict resolution tools to resolve merge conflicts

## Related Documentation

- [Mergetool Integration](../workflow/mergetool-integration.md): Detailed guide on mergetool integration and configuration
