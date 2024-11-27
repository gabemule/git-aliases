# 🔄 Mergetool Integration

Advanced mergetool integration in ChronoGit offers a robust solution for conflict resolution, significantly improving the development workflow.

## Overview

Mergetool integration in ChronoGit allows:
- Easy configuration of preferred merge tools
- Automatic launch of the merge tool during conflicts
- Support for various popular merge tools
- Custom configurations for each tool

## Workflow

1. **Configuration**: Use the `git chronogit` command to configure your preferred merge tool.
2. **Normal Development**: Continue your development as usual.
3. **Conflict Detection**: When a conflict is detected during operations like sync, jerrypick, or rollback, ChronoGit automatically:
   - Notifies about the conflict
   - Launches the configured merge tool (if auto-launch is enabled)
4. **Conflict Resolution**: Use the merge tool to resolve conflicts.
5. **Continuation**: After resolving conflicts, continue the original operation (e.g., `git sync --continue`).

## Configuration

To configure your merge tool:

1. Run the command:
   ```
   git chronogit
   ```
2. Select the option to configure the mergetool.
3. Choose your preferred tool from the list or specify a custom one.
4. Configure additional options, such as custom path or arguments.
5. Decide whether to enable automatic launch of the tool during conflicts.

## Configuration Examples

### 1. Configuring VSCode as Mergetool

```bash
git chronogit
# Select: Configure Mergetool
# Tool: vscode
# Custom Path: code
# Additional Arguments: --wait --merge $REMOTE $LOCAL $BASE $MERGED
# Auto-launch: Yes
```

After this configuration, VSCode will be launched automatically to resolve conflicts.

### 2. Configuring Meld

```bash
git chronogit
# Select: Configure Mergetool
# Tool: meld
# Custom Path: [leave blank if Meld is in PATH]
# Additional Arguments: [leave blank to use default settings]
# Auto-launch: Yes
```

### 3. Configuring KDiff3

```bash
git chronogit
# Select: Configure Mergetool
# Tool: kdiff3
# Custom Path: /usr/local/bin/kdiff3 [adjust as needed]
# Additional Arguments: --auto
# Auto-launch: Yes
```

## Usage

Once configured, the mergetool will be used automatically during operations that may generate conflicts:

1. **During Sync**:
   ```bash
   git sync
   # If conflicts occur, the mergetool will be launched automatically
   # After resolving, run:
   git sync --continue
   ```

2. **During Jerrypick**:
   ```bash
   git jerrypick
   # Select commits to cherry-pick
   # If conflicts occur, the mergetool will be launched
   # After resolving, the process will continue automatically
   ```

3. **During Rollback**:
   ```bash
   git rollback
   # If conflicts occur during the revert process, the mergetool will be launched
   # After resolving, run:
   git rollback --continue
   ```

## Tips and Best Practices

1. **Test your configuration**: After setting up, create a test conflict to ensure everything works as expected.
2. **Familiarize yourself with your tool**: Each mergetool has its own features. Take time to learn how to use your chosen tool efficiently.
3. **Stay updated**: Sync frequently to minimize large conflicts.
4. **Review carefully**: After resolving conflicts, always review changes before committing.
5. **Backup**: Before resolving complex conflicts, consider backing up your current state.

## Troubleshooting

- If the mergetool doesn't start automatically, check your configuration with `git chronogit`.
- Ensure the path to your merge tool is correct and accessible.
- For persistent issues, refer to the [troubleshooting documentation](../installation/troubleshooting.md).

## Related Commands

- [git sync](../commands/sync.md): Synchronizes your branch with the main branch and remote.
- [git jerrypick](../commands/jerrypick.md): Performs interactive cherry-picking of commits.
- [git rollback](../commands/rollback.md): Safely reverts changes in the main branch.
- [git chronogit](../commands/chronogit.md): Configures ChronoGit settings, including the mergetool.

## Related Documentation

- [Configuration Guide](../configuration/README.md)
- [Installation Guide](../installation/README.md)
- [Best Practices](best-practices.md)
- [Known Issues](../known-issues.md)
