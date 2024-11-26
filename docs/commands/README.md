# 🛠️ ChronoGit Commands

ChronoGit provides a set of powerful Git commands to streamline your workflow. Each command is designed to be intuitive and follows consistent patterns.

## Available Commands

### [🌿 Branch Creation](start-branch.md)
```bash
# Show help
git start -h

# Full command
git start-branch -t PROJ-123

# Short alias
git start -t PROJ-123
```
Creates new branches with standardized naming and ticket tracking.

**Key Features:**
- Clean, descriptive branch names
- Automatic ticket reference storage
- Branch type selection (feature, bugfix, etc.)
- Source branch control
- Stash handling

### [✍️ Conventional Commits](conventional-commit.md)
```bash
# Show help
git cc -h

# Interactive mode
git cc

# With message
git cc -m "implement feature"
```
Creates standardized commits following the Conventional Commits specification.

**Key Features:**
- Interactive type selection
- Scope support
- Breaking change detection
- Ticket reference handling
- Auto-push option

### [🔍 Pull Requests](open-pr.md)
```bash
# Show help
git pr -h

# Full command
git open-pr

# Short alias
git pr
```
Streamlines PR creation with automatic ticket reference inclusion.

**Key Features:**
- Target branch selection
- Template support
- Draft PR support
- Ticket reference handling
- Browser integration

### [🔄 Branch Synchronization](sync.md)
```bash
# Show help
git sync -h

# Full sync
git sync

# Sync without pushing
git sync --no-push
```
Synchronizes the current branch with the main branch and remote.

**Key Features:**
- Updates from main branch
- Syncs with remote branch
- Handles stashing automatically
- Conflict resolution support
- Dry-run option for safety

## Common Patterns

All commands follow these consistent patterns:

### 1. Help Messages
```bash
# View command help
git start -h
git cc -h
git pr -h
git sync -h

# Note: Using --help shows alias definition
# See known-issues.md for details
```

### 2. Ticket Handling
```bash
# Set with branch
git start-branch -t PROJ-123

# Override for commit
git cc -t PROJ-456

# Automatically included in PR
git open-pr  # Uses branch ticket
```

### 3. Interactive vs Non-interactive
```bash
# Interactive (prompts for input)
git cc

# Non-interactive (all flags)
git cc -m "message" --type feat -s ui
```

### 4. Short Aliases
```bash
git start     # for start-branch
git cc        # for conventional-commit
git pr        # for open-pr
git sync      # for branch synchronization
```

## Testing Commands

```bash
# Show test help
git test -h

# Run test suite
git test

# Select test type:
1) Interactive workflow tests
2) Non-interactive flag tests
3) Verification tests
4) All tests
5) Exit
```

## Related Documentation

- [Installation Guide](../installation/README.md)
- [Configuration Guide](../configuration/README.md)
- [Workflow Guide](../workflow/README.md)
- [Testing Guide](../testing/README.md)
- [Known Issues](../known-issues.md)

## Need Help?

- See command-specific documentation:
  - [start-branch](start-branch.md)
  - [conventional-commit](conventional-commit.md)
  - [open-pr](open-pr.md)
  - [sync](sync.md)
- Check [troubleshooting guide](../installation/troubleshooting.md)
- Review [known issues](../known-issues.md)
- Run verification: `git test -v`
