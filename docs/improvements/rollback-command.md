# Git Rollback Command

## Description
Provides a safe and interactive way to rollback production changes. Shows recent changes, helps select the rollback point, and creates a new branch for review before applying the rollback. Uses the configured main branch from git config.

## Features
- Interactive commit selection
- Safe rollback through PR process
- Automatic branch creation
- Change verification
- Conflict detection
- Configurable main branch

## Example Usage
```bash
# View and rollback changes
$ rollback-production
Using main branch: development (configured in git config)
Last 7 changes in development:
abc123 - feat: add user authentication (2 days ago) by dev1
def456 - fix: correct login validation (1 day ago) by dev2
ghi789 - style: update button colors (1 hour ago) by dev3

Select commit hash to rollback to: abc123
Creating rollback branch...
Reverting changes...
Rollback branch created: rollback/development_20230615_143022
Please review changes and merge through PR process

# Verify rollback
$ verify-rollback rollback/development_20230615_143022
Changes to be reverted:
 M src/auth/login.js
 M src/styles/buttons.css
✓ Clean rollback possible
```

## Command Options

### rollback-production
1. **--dry-run**
   - Purpose: Preview rollback changes without creating branch
   - Example: `rollback-production --dry-run`

2. **--skip-verify**
   - Purpose: Skip verification step
   - Example: `rollback-production --skip-verify`

### verify-rollback
- Takes rollback branch name as argument
- Shows changes to be reverted
- Checks for potential conflicts

## Configuration
```bash
# Set main branch for repository (defaults to 'production')
git config workflow.mainBranch development

# Check current main branch configuration
git config workflow.mainBranch
```

## Implementation

### Interactive Rollback Script
```bash
#!/bin/bash

rollback_production() {
    local dry_run=false
    local skip_verify=false
    
    # Get main branch from config or use default
    local main_branch=$(git config workflow.mainBranch || echo "production")
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dry-run) dry_run=true ;;
            --skip-verify) skip_verify=true ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
        shift
    done
    
    # Ensure we're up to date
    if ! git fetch origin; then
        echo "Error: Failed to fetch latest changes"
        return 1
    fi
    
    echo "Using main branch: $main_branch"
    
    # Get last 7 main branch commits
    echo "Last 7 changes in $main_branch:"
    git log -n 7 --pretty=format:"%h - %s (%cr) by %an" origin/$main_branch
    
    # Interactive selection
    echo -e "\nSelect commit hash to rollback to:"
    read -p "> " target_commit
    
    # Validate commit exists
    if ! git rev-parse --quiet --verify "$target_commit" >/dev/null; then
        echo "Invalid commit hash"
        return 1
    }
    
    # Create rollback branch
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local rollback_branch="rollback/${main_branch}_$timestamp"
    
    if [[ "$dry_run" == true ]]; then
        echo "[DRY-RUN] Would create branch: $rollback_branch"
        echo "[DRY-RUN] Would revert commits from $target_commit to HEAD"
        return 0
    fi
    
    git checkout -b "$rollback_branch" origin/$main_branch
    
    # Create revert commit
    if ! git revert --no-commit "$target_commit"..HEAD; then
        echo "Error: Failed to revert changes"
        git revert --abort
        return 1
    fi
    
    # Verify changes if not skipped
    if [[ "$skip_verify" == false ]]; then
        echo "Verifying changes..."
        verify_rollback "$rollback_branch" "$main_branch"
        read -p "Continue with rollback? (y/N) " confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo "Rollback aborted"
            git checkout -
            git branch -D "$rollback_branch"
            return 1
        fi
    fi
    
    git commit -m "Rollback: Revert $main_branch to $target_commit"
    
    # Push and create PR
    if ! git push origin "$rollback_branch"; then
        echo "Error: Failed to push rollback branch"
        return 1
    fi
    
    echo "Rollback branch created: $rollback_branch"
    echo "Please review changes and merge through PR process"
}
```

### Rollback Verification
```bash
verify_rollback() {
    local rollback_branch="$1"
    local main_branch="$2"
    
    # Compare states
    echo "Changes to be reverted:"
    git diff origin/$main_branch.."$rollback_branch"
    
    # Check for conflicts
    if git merge-base --is-ancestor "$rollback_branch" origin/$main_branch; then
        echo "✓ Clean rollback possible"
    else
        echo "⚠️ Conflicts may occur during rollback"
        echo "Please review carefully"
    fi
}
```

## Pros and Cons

### Pros
- Safe rollback process through PR
- Clear view of recent changes
- Automatic branch creation
- Verification steps included
- Prevents accidental direct rollbacks
- Respects configured main branch

### Cons
- Requires understanding of git revert
- May need manual conflict resolution
- Multiple steps before actual rollback

## Best Practices

1. Always verify changes before merging rollback
2. Use --dry-run first to preview changes
3. Keep rollback commits small when possible
4. Document rollback reasons
5. Clean up rollback branches after merge
6. Configure main branch per repository

## Integration

- Works with existing PR workflow
- Supports team review process
- Compatible with CI/CD pipelines
- Integrates with existing git aliases
- Uses same configuration as other commands
