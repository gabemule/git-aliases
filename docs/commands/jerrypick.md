# 🍒 Jerrypick Command

Provides an interactive way to cherry-pick commits from one branch to another, allowing for easy selection of multiple commits with a user-friendly interface.

## Usage

### Basic Usage

```bash
# Show help
git jerrypick -h

# Interactive mode with branch selection
git jerrypick

# From a specific branch
git jerrypick feature-branch

# Dry run mode
git jerrypick --dry-run feature-branch
```

### Options

- `-h` - Show help message
- `--dry-run` - Preview cherry-pick changes without applying them
- `[source_branch]` - Specify the source branch for cherry-picking (optional)

## Automatic Features

### 1. Branch Selection
If no source branch is provided, shows a list of available branches:
```bash
$ git jerrypick
Available branches:
> feature/user-auth
  bugfix/login-error
  develop
```

### 2. Commit Selection with Pagination
Displays commits from the selected branch with navigation:
```bash
Recent commits in feature/user-auth:
↑/↓ to navigate, Space to select/deselect, Enter to confirm, 'n' for next page, 'p' for previous page
> [x] abc123 - feat: add password reset functionality
  [ ] def456 - test: add unit tests for user authentication
  [x] ghi789 - style: improve login form UI
[1-5/20 commits]
```

### 3. Multiple Commit Selection
Allows selection of multiple commits using the spacebar:
```bash
Selected commits:
abc123 - feat: add password reset functionality
ghi789 - style: improve login form UI
```

## Interactive Usage

### Full Interactive Flow

```bash
$ git jerrypick
Available branches:
[Branch selection interface]

Selected source branch: feature/user-auth
Recent commits in feature/user-auth:
[Commit selection interface]

Cherry-picking selected commits...
Successfully applied selected commits to current branch.
```

### Dry Run Mode

```bash
$ git jerrypick --dry-run feature/user-auth
[DRY-RUN] Would cherry-pick: abc123 feat: add password reset functionality
[DRY-RUN] Would cherry-pick: ghi789 style: improve login form UI
```

## Error Handling

### Cherry-pick Conflict
```bash
$ git jerrypick
Cherry-picking: abc123 - feat: add password reset functionality
Conflict detected. Please resolve conflicts and run 'git cherry-pick --continue'
Or run 'git cherry-pick --abort' to cancel the operation
```

### Invalid Branch
```bash
$ git jerrypick non-existent-branch
Error: Branch 'non-existent-branch' does not exist
```

## Workflow Steps

1. Start the jerrypick process:
   ```bash
   git jerrypick
   ```
2. Select the source branch (if not specified)
3. Choose the commits to cherry-pick
4. Resolve any conflicts if they occur
5. Commit the changes (if not in dry-run mode)

## Related Commands

- [git start-branch](start-branch.md) - Create a new branch before cherry-picking
- [git cc](conventional-commit.md) - Commit changes after cherry-picking
- [git sync](sync.md) - Synchronize branches before or after cherry-picking
