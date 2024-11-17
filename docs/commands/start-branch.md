# Start Branch Command 🌿

Creates new branches with standardized naming and automatic ticket reference tracking.

## Usage

### Basic Usage

```bash
# Interactive mode (full command)
git start-branch -t PROJ-123

# Interactive mode (short alias)
git start -t PROJ-123

# Non-interactive mode (full command)
git start-branch -t PROJ-123 -n user-authentication -b feature

# Non-interactive mode (short alias)
git start -t PROJ-123 -n user-authentication -b feature
```

### Options

- `-t, --ticket <id>` - Specify ticket reference (e.g., PROJ-123)
- `-n, --name <name>` - Specify branch name (skip prompt)
- `-b, --branch-type <type>` - Specify branch type (skip prompt)
- `--current` - Create branch from current branch instead of main
- `--no-sync` - Skip main branch sync
- `--no-stash` - Skip stashing changes

## Examples

### 1. Interactive Branch Creation

```bash
# Using full command
$ git start-branch -t PROJ-123
Select branch type:
   feature
   bugfix
   hotfix
   release
   docs
? Enter the name of the new task: user-authentication
✓ Created branch: feature/user-authentication
✓ Stored ticket: PROJ-123

# Using short alias
$ git start -t PROJ-123
Select branch type:
   feature
   bugfix
   hotfix
   release
   docs
? Enter the name of the new task: user-authentication
✓ Created branch: feature/user-authentication
✓ Stored ticket: PROJ-123
```

### 2. Quick Branch Creation

```bash
# Using full command
$ git start-branch -t PROJ-456 -b hotfix -n fix-login
✓ Created branch: hotfix/fix-login
✓ Stored ticket: PROJ-456

# Using short alias
$ git start -t PROJ-456 -b hotfix -n fix-login
✓ Created branch: hotfix/fix-login
✓ Stored ticket: PROJ-456
```

### 3. Branch from Current

```bash
# Using full command
$ git start-branch -t PROJ-789 --current
Select branch type:
   feature
? Enter the name of the new task: add-tests
✓ Created branch: feature/add-tests from current branch
✓ Stored ticket: PROJ-789

# Using short alias
$ git start -t PROJ-789 --current
Select branch type:
   feature
? Enter the name of the new task: add-tests
✓ Created branch: feature/add-tests from current branch
✓ Stored ticket: PROJ-789
```

### 4. Skip Sync and Stash

```bash
# Using full command
$ git start-branch -t PROJ-321 --no-sync --no-stash
Select branch type:
   feature
? Enter the name of the new task: quick-fix
✓ Created branch: feature/quick-fix
✓ Stored ticket: PROJ-321

# Using short alias
$ git start -t PROJ-321 --no-sync --no-stash
Select branch type:
   feature
? Enter the name of the new task: quick-fix
✓ Created branch: feature/quick-fix
✓ Stored ticket: PROJ-321
```

## Branch Types

| Type | Purpose | Example |
|------|---------|---------|
| feature | New features | feature/user-authentication |
| bugfix | Non-critical fixes | bugfix/login-validation |
| hotfix | Critical fixes | hotfix/security-vulnerability |
| release | Release preparation | release/v1.2.0 |
| docs | Documentation | docs/api-endpoints |

## Configuration

### Main Branch

```bash
# Set custom main branch (defaults to 'production')
git config workflow.mainBranch main

# View current setting
git config workflow.mainBranch
```

### Ticket Reference

```bash
# View stored ticket
git config branch.feature/user-authentication.ticket

# Manually set ticket
git config branch.feature/user-authentication.ticket PROJ-123
```

## Related Commands

- [git cc](conventional-commit.md) - Create commits with ticket references
- [git open-pr](open-pr.md) - Create PR from branch
