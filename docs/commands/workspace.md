# 🗂️ Workspace Command

The `git workspace` command allows developers to save and restore complete workspace states, including staged changes, unstaged changes, and untracked files. It's perfect for context switching or handling interruptions.

## Usage

```bash
git workspace <action> [name]
```

### Actions

- `save <name>`: Save the current workspace state
- `restore <name>`: Restore a saved workspace state
- `list`: List all saved workspaces

### Options

- `-h`: Show help message

## Examples

1. Save current workspace state:
   ```bash
   git workspace save feature-auth
   ```

2. Restore a saved workspace:
   ```bash
   git workspace restore feature-auth
   ```

3. List all saved workspaces:
   ```bash
   git workspace list
   ```

## Features

1. **Complete State Saving**
   - Saves current branch
   - Preserves staged changes
   - Preserves unstaged changes
   - Includes untracked files

2. **Multiple Named Workspaces**
   - Save different states with unique names
   - Easy switching between tasks

3. **Branch Preservation**
   - Automatically switches to the saved branch on restore

4. **Separation of Changes**
   - Maintains distinction between staged and unstaged changes

## Workflow

1. Save your current workspace before switching tasks:
   ```bash
   git workspace save current-task
   ```

2. Switch to a different branch or task as needed.

3. When ready to return to the previous task, restore the workspace:
   ```bash
   git workspace restore current-task
   ```

## Best Practices

1. Use descriptive names for your workspaces to easily identify them later.
2. Regularly clean up old or unused workspaces to save disk space.
3. Be cautious when restoring workspaces on top of existing work to avoid conflicts.
4. Use `git workspace list` to keep track of your saved workspaces.

## Related ChronoGit Commands

- [git chronogit](chronogit.md): Configure workspace settings
- [git cc](conventional-commit.md): Create commits in your workspace
- [git jerrypick](jerrypick.md): Cherry-pick commits into your workspace
- [git open-pr](open-pr.md): Create PR from your workspace
- [git rollback](rollback.md): Safely revert changes in your workspace
- [git start-branch](start-branch.md): Create a new branch before saving a workspace
- [git stash](https://git-scm.com/docs/git-stash): Built-in Git command for stashing changes
- [git sync](sync.md): Synchronize your branch before saving or after restoring a workspace

## Useful Built-in Commands

- [git stash](https://git-scm.com/docs/git-stash) - Temporarily store modified, tracked files
- [git status](https://git-scm.com/docs/git-status) - Show the working tree status
- [git log](https://git-scm.com/docs/git-log) - Show commit logs
- [git diff](https://git-scm.com/docs/git-diff) - Show changes between commits, commit and working tree, etc
