# 🔙 Rollback Command

Provides a safe and interactive way to revert changes in the main branch, creating a new branch for review before applying the rollback.

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
```

### Options

- `-h` - Show help message
- `--dry-run` - Preview rollback changes without creating branch
- `--skip-verify` - Skip verification step

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

After rollback branch creation:

1. Review the changes in the rollback branch
2. Create a PR to merge the rollback:
   ```bash
   git pr -t production
   ```
3. After review and approval, merge the rollback PR

## Related Commands

- [git sync](sync.md) - Synchronize branches before rollback
- [git open-pr](open-pr.md) - Create PR for the rollback
- [git chronogit](chronogit.md) - Configure main branch settings
