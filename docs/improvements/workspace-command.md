# Git Workspace Command

## Description
Allows developers to save and restore complete workspace states, including staged changes, unstaged changes, and untracked files. Perfect for context switching or handling interruptions.

## Features
- Complete workspace state saving
- Multiple named workspaces
- Includes untracked files
- Branch state preservation
- Staged/unstaged change separation

## Example Usage
```bash
# Save current state
$ git workspace save feature-auth
Workspace 'feature-auth' saved

# Switch to another task...

# Restore previous state
$ git workspace restore feature-auth
Restoring branch feature/user-auth
Restoring files...
Workspace 'feature-auth' restored

# List saved workspaces
$ git workspace list
Available workspaces:
feature-auth
bugfix-nav
```

## Pros and Cons

### Pros
- Perfect for context switching
- Saves complete state including untracked files
- More comprehensive than git stash
- Multiple named workspaces
- Preserves staging area state

### Cons
- Could use significant disk space
- Might be confusing with git's built-in stash
- Risk of stale workspaces
- Complex implementation
- Potential for large backup files

## Implementation
```bash
#!/bin/bash

workspace_manager() {
    action=$1
    name=${2:-"default"}
    
    workspace_dir="$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)"
    mkdir -p "$workspace_dir"
    
    case $action in
        "save")
            # Save current branch
            git rev-parse --abbrev-ref HEAD > "$workspace_dir/$name.branch"
            
            # Save staged changes
            git diff --cached > "$workspace_dir/$name.staged"
            
            # Save unstaged changes
            git diff > "$workspace_dir/$name.unstaged"
            
            # Save untracked files
            git ls-files --others --exclude-standard | tar czf "$workspace_dir/$name.untracked.tar.gz" -T -
            
            echo "Workspace '$name' saved"
            ;;
            
        "restore")
            if [ ! -f "$workspace_dir/$name.branch" ]; then
                echo "Workspace '$name' not found"
                return 1
            fi
            
            # Restore branch
            git checkout $(cat "$workspace_dir/$name.branch")
            
            # Restore untracked files
            tar xzf "$workspace_dir/$name.untracked.tar.gz"
            
            # Restore unstaged changes
            git apply "$workspace_dir/$name.unstaged"
            
            # Restore staged changes
            git apply --cached "$workspace_dir/$name.staged"
            
            echo "Workspace '$name' restored"
            ;;
            
        "list")
            echo "Available workspaces:"
            for ws in "$workspace_dir"/*.branch; do
                [ -f "$ws" ] && basename "$ws" .branch
            done
            ;;
            
        *)
            echo "Usage: git workspace <save|restore|list> [name]"
            ;;
    esac
}
```

## Future Improvements
1. Add workspace cleanup command
2. Add workspace expiration dates
3. Add compression options
4. Add selective restore (only specific files)
5. Add workspace sharing between machines
6. Add workspace diff command
7. Add workspace merge capability

## Integration
- Works alongside git stash
- Can be used with any git workflow
- Supports team collaboration
- Preserves git history
- Compatible with CI/CD pipelines
