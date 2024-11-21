# 🛠️ ChronoGit Commands

ChronoGit provides a set of powerful Git commands to streamline your workflow. Each command is designed to be intuitive and follows consistent patterns.

## Available Commands

### [🌿 Branch Creation](start-branch.md)
```bash
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

## Common Patterns

All commands follow these consistent patterns:

### 1. Ticket Handling
```bash
# Set with branch
git start-branch -t PROJ-123

# Override for commit
git cc -t PROJ-456

# Automatically included in PR
git open-pr  # Uses branch ticket
```

### 2. Interactive vs Non-interactive
```bash
# Interactive (prompts for input)
git cc

# Non-interactive (all flags)
git cc -m "message" --type feat -s ui
```

### 3. Short Aliases
```bash
git start     # for start-branch
git cc        # for conventional-commit
git pr        # for open-pr
```

## Testing Commands

```bash
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

## Need Help?

- See command-specific documentation:
  - [start-branch](start-branch.md)
  - [conventional-commit](conventional-commit.md)
  - [open-pr](open-pr.md)
- Check [troubleshooting guide](../installation/troubleshooting.md)
- Run verification: `git test -v`
