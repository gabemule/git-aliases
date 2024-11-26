# Git Rollback Command

## Description
Provides a safe and interactive way to rollback changes. Shows recent changes with pagination, helps select the rollback point, and creates a new branch for review before applying the rollback. Uses the configured main branch from git config.

## Features
- Interactive commit selection with pagination
- Safe rollback through PR process
- Automatic branch creation
- Change verification
- Conflict detection
- Configurable main branch

## Example Usage
```bash
# View and rollback changes
$ git rollback
Using main branch: production (configured in git config)
Recent changes in production:
↑/↓ to navigate, Enter to select, 'n' for next page, 'p' for previous page
> abc123 - feat: add user authentication (2 days ago) by dev1
  def456 - fix: correct login validation (1 day ago) by dev2
  ghi789 - style: update button colors (1 hour ago) by dev3
  jkl012 - docs: update API documentation (3 hours ago) by dev4
  mno345 - refactor: optimize database queries (5 hours ago) by dev5
[1-5/20 commits]

Select commit hash to rollback to: abc123
Creating rollback branch...
Reverting changes...
Rollback branch created: rollback/production_20230615_143022
Please review changes and merge through PR process

# Verify rollback
$ git verify-rollback rollback/production_20230615_143022
Changes to be reverted:
 M src/auth/login.js
 M src/styles/buttons.css
✓ Clean rollback possible
```

## Command Options

### git rollback
1. **--dry-run**
   - Purpose: Preview rollback changes without creating branch
   - Example: `git rollback --dry-run`

2. **--skip-verify**
   - Purpose: Skip verification step
   - Example: `git rollback --skip-verify`

### git verify-rollback
- Takes rollback branch name as argument
- Shows changes to be reverted
- Checks for potential conflicts

## Configuration
```bash
# Set main branch for repository (defaults to 'production')
git config workflow.mainBranch development

# Check current main branch configuration
git config workflow.mainBranch

# Or use the interactive menu
git chronogit
# Then select option 2 to set configuration
```

## Implementation

### Interactive Rollback Script
```bash
#!/bin/bash

rollback() {
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
    
    # Get commits with pagination
    local page_size=5
    local start=0
    local selected=0
    local commits=($(git log --format="%h - %s (%cr) by %an" origin/$main_branch))
    
    while true; do
        clear
        echo "Recent changes in $main_branch:"
        echo "↑/↓ to navigate, Enter to select, 'n' for next page, 'p' for previous page"
        for ((i=start; i<start+page_size && i<${#commits[@]}; i++)); do
            if [ $i -eq $selected ]; then
                echo "> ${commits[$i]}"
            else
                echo "  ${commits[$i]}"
            fi
        done
        echo "[$(($start+1))-$((start+page_size))/${#commits[@]} commits]"
        
        read -sn1 key
        case "$key" in
            A) # Up arrow
                ((selected--))
                if [ $selected -lt $start ]; then
                    ((start-=page_size))
                    [ $start -lt 0 ] && start=0
                fi
                [ $selected -lt 0 ] && selected=$((${#commits[@]}-1))
                ;;
            B) # Down arrow
                ((selected++))
                if [ $selected -ge $((start+page_size)) ]; then
                    ((start+=page_size))
                    [ $((start+page_size)) -gt ${#commits[@]} ] && start=$((${#commits[@]}-page_size))
                    [ $start -lt 0 ] && start=0
                fi
                [ $selected -ge ${#commits[@]} ] && selected=0
                ;;
            n) # Next page
                ((start+=page_size))
                [ $((start+page_size)) -gt ${#commits[@]} ] && start=$((${#commits[@]}-page_size))
                [ $start -lt 0 ] && start=0
                selected=$start
                ;;
            p) # Previous page
                ((start-=page_size))
                [ $start -lt 0 ] && start=0
                selected=$start
                ;;
            "") # Enter
                target_commit=$(echo ${commits[$selected]} | cut -d' ' -f1)
                break
                ;;
        esac
    done
    
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
- Clear view of recent changes with pagination
- Automatic branch creation
- Verification steps included
- Prevents accidental direct rollbacks
- Respects configured main branch
- Consistent interface with other ChronoGit commands

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
6. Configure main branch per repository using git config

## Integration

- Works with existing PR workflow
- Supports team review process
- Compatible with CI/CD pipelines
- Integrates with existing git aliases
- Uses same configuration as other ChronoGit commands
