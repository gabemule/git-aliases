# 🔄 Git Sync Command

The `git sync` command is a comprehensive solution for branch synchronization that combines updating from the main branch, syncing with remote, and sharing changes in a single command with flexible control through flags.

## Usage

```bash
git sync [options]
```

## Options

- `--continue`: Resume sync after conflict resolution
- `--no-update`: Skip updating from main branch
- `--no-pull`: Skip pulling from remote
- `--no-push`: Skip pushing to remote
- `--dry-run`: Show what would be done without making changes
- `-h`: Show help message

## Examples

1. Full sync (update from main, sync with remote, push):
   ```bash
   git sync
   ```

2. Update from main but don't push:
   ```bash
   git sync --no-push
   ```

3. Only sync with remote (skip main branch update):
   ```bash
   git sync --no-update
   ```

4. Preview changes without executing:
   ```bash
   git sync --dry-run
   ```

5. After resolving conflicts:
   ```bash
   git sync --continue
   ```

## Workflow

The sync command performs three operations in this order:
1. Update from main branch (get updates from main)
2. Pull from remote (get updates from your branch)
3. Push to remote (share your changes)

This order ensures:
- You first get main branch updates
- Then sync with your remote branch
- Finally share your changes

## Features

1. **Branch Management**
   - Updates from configured main branch
   - Syncs with remote branch
   - Handles stashing automatically
   - Preserves local changes

2. **Safety Features**
   - Dry-run mode for previewing changes
   - Flexible control with various flags
   - Automatic conflict detection

3. **Conflict Handling**
   - Automatic mergetool integration
   - Clear conflict status messages
   - Progress tracking
   - State preservation

4. **Mergetool Integration**
   - Automatically launches configured mergetool on conflicts
   - Uses mergetool settings from chronogit configuration
   - Supports custom mergetool paths and arguments

## Best Practices

1. Always run `git sync --dry-run` before actual sync to preview changes.
2. Resolve conflicts promptly when they occur.
3. Use `git sync --no-push` to review changes before sharing.
4. Regularly sync your branch to avoid large divergences.
5. Configure your preferred mergetool using `git chronogit` for seamless conflict resolution.

## Troubleshooting

- If sync fails due to conflicts, resolve them and use `git sync --continue`.
- If you encounter unexpected behavior, check the [known issues](../known-issues.md) document.
- For more detailed troubleshooting, refer to the [troubleshooting guide](../installation/troubleshooting.md).
- If you're having issues with the mergetool, ensure it's properly configured using `git chronogit`.

## Related ChronoGit Commands

- [git chronogit](chronogit.md): Configure settings
- [git cc](conventional-commit.md): Create conventional commits
- [git jerrypick](jerrypick.md): Cherry-pick commits interactively
- [git open-pr](open-pr.md): Open pull requests
- [git rollback](rollback.md): Safely revert changes in the main branch
- [git start-branch](start-branch.md): Create new branches
- [git workspace](workspace.md): Manage and switch between different workspaces

## Useful Built-in Commands

- [git stash](https://git-scm.com/docs/git-stash) - Temporarily store modified, tracked files
- [git status](https://git-scm.com/docs/git-status) - Show the working tree status
- [git log](https://git-scm.com/docs/git-log) - Show commit logs
- [git diff](https://git-scm.com/docs/git-diff) - Show changes between commits, commit and working tree, etc
- [git mergetool](https://git-scm.com/docs/git-mergetool) - Run merge conflict resolution tools to resolve merge conflicts

## Related Documentation

- [Mergetool Integration](../workflow/mergetool-integration.md): Detailed guide on mergetool integration and configuration
