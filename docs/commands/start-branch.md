# Start Branch Command 🌿

Creates new branches with standardized naming and automatic ticket reference tracking.

## Features

- Standardized branch naming
- Automatic ticket reference storage
- Main branch synchronization
- Automatic stash handling
- Interactive branch type selection

## Usage

### Basic Usage

```bash
git start-branch
```

### Options

- `-t <ticket>` - Specify ticket reference (e.g., PROJ-123)

## Examples

### 1. With Ticket Argument

```bash
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
```

### 2. Interactive Ticket Entry

```bash
$ git start-branch
Select branch type:
   feature
   bugfix
   hotfix
   release
   docs
? Enter the name of the new task: login-fix
? Enter ticket number (e.g., PROJ-123): PROJ-456
✓ Created branch: bugfix/login-fix
✓ Stored ticket: PROJ-456
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
