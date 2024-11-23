# 🌿 Start Branch Command

Creates new branches with standardized naming and automatic ticket reference tracking.

## Usage

### Basic Usage

```bash
# Show help
git start-branch -h
# or
git start -h

# Interactive mode (full command)
git start-branch -t PROJ-123

# Interactive mode (short alias)
git start -t PROJ-123

# With branch type and name
git start-branch -t PROJ-123 -n user-authentication -b feature
```

### Options

- `-h` - Show help message
- `-t, --ticket <id>` - Specify ticket reference (e.g., PROJ-123)
- `-n, --name <name>` - Specify branch name
- `-b, --branch-type <type>` - Specify branch type
- `--current` - Create branch from current branch instead of main
- `--no-sync` - Skip main branch sync (use with caution, see [Conflict Management](../workflow/best-practices.md#conflict-management))
- `--no-stash` - Skip stashing changes (use with caution, see [Stash Pop Conflicts](../workflow/best-practices.md#3-stash-pop-conflicts))

## Branch Types

Use arrow keys (↑/↓) to select branch type:
```bash
Select branch type:
   feature  - New feature development
   bugfix   - Bug fix in the code
   hotfix   - Critical fix for production
   release  - Prepare for a new production release
   docs     - Documentation changes
```

## Automatic Features

### 1. Stash Handling
By default, modified files are automatically stashed to prevent conflicts:
```bash
$ git start-branch -t PROJ-123
You have modified files. Creating a stash...
✓ Stash created with description: Auto stash before start-branch on 2024-01-20 10:30:45
```

Skip only when you're sure your changes won't interfere:
```bash
# Use with caution - see Conflict Management guide
git start-branch -t PROJ-123 --no-stash
```

### 2. Main Branch Sync
Unless --current or --no-sync is used:
1. Switches to main branch
2. Pulls latest changes
3. Creates new branch from updated main

This prevents future merge conflicts:
```bash
# Recommended: let sync happen
git start-branch -t PROJ-123

# Skip sync only when needed - see Branch Sync Conflicts guide
git start-branch -t PROJ-123 --no-sync

# Branch from current instead of main
git start-branch -t PROJ-123 --current  # For dependent features
```

### 3. Branch Naming
- Spaces converted to hyphens automatically
- Appropriate prefix added based on type
- Examples:
  ```bash
  git start -t PROJ-123 -n "user authentication"
  # Creates: feature/user-authentication
  
  git start -t PROJ-123 -n "fix login bug" -b bugfix
  # Creates: bugfix/fix-login-bug
  ```

## Interactive Usage

### Full Interactive Flow

```bash
$ git start-branch
Select branch type: [Use arrow keys to select]
Enter the name of the new task: user authentication
Enter ticket number (e.g., PROJ-123): PROJ-123

✓ Successfully created and switched to new branch: feature/user-authentication
✓ Associated ticket: PROJ-123

You can now start working on your task.

When you're done:
1. Create a pull request to merge into 'development'
2. After testing, create another pull request to merge into 'production'
```

### With Ticket Specified

```bash
$ git start -t PROJ-123
Select branch type: [Use arrow keys to select]
Enter the name of the new task: fix login
✓ Successfully created and switched to new branch: bugfix/fix-login
✓ Associated ticket: PROJ-123
```

## Error Handling

### Not in Git Repository
```bash
$ git start
Error: This script must be run in a git repository.
```

### Invalid Branch Type
```bash
$ git start -b invalid -t PROJ-123
Invalid branch type: invalid
Valid types: feature bugfix hotfix release docs
```

### Invalid Ticket Format
```bash
$ git start -t invalid
Invalid ticket format. Must match pattern: ^[A-Z]+-[0-9]+$
```

### Branch Creation Failed
```bash
$ git start -t PROJ-123
Error: Failed to create new branch.
```

## Configuration

Branch prefixes, main branch, and other settings can be configured using the chronogit command:

```bash
# Show current configuration
git chronogit

# Update configuration
git chronogit
# Select: 2) Set configuration
# Choose setting to modify
```

See [chronogit command](chronogit.md) for detailed configuration options.

## Workflow Steps

After branch creation, you should:

1. Make your changes and commit them:
   ```bash
   git cc -m "implement feature"
   ```

2. Create a PR to development:
   ```bash
   git pr -t development
   ```

3. After testing, create PR to production:
   ```bash
   git pr -t production
   ```

## Related Commands

- [git cc](conventional-commit.md) - Create commits in your branch
- [git open-pr](open-pr.md) - Create PR when ready
- [git chronogit](chronogit.md) - Configure branch settings
