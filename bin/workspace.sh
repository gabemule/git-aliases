#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

workspace_manager() {
    local action=$1
    local name=${2:-"default"}
    
    local workspace_dir="$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)"
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
            
            echo -e "${GREEN}Workspace '$name' saved${NC}"
            ;;
            
        "restore")
            if [ ! -f "$workspace_dir/$name.branch" ]; then
                echo -e "${RED}Workspace '$name' not found${NC}"
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
            
            echo -e "${GREEN}Workspace '$name' restored${NC}"
            ;;
            
        "list")
            echo -e "${BLUE}Available workspaces:${NC}"
            for ws in "$workspace_dir"/*.branch; do
                [ -f "$ws" ] && basename "$ws" .branch
            done
            ;;
            
        *)
            show_help
            ;;
    esac
}

show_help() {
    echo "Usage: git workspace <action> [name]"
    echo
    echo "Actions:"
    echo "  save <name>    Save current workspace state"
    echo "  restore <name> Restore a saved workspace state"
    echo "  list           List all saved workspaces"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
}

# Parse command line arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

if [ $# -lt 1 ]; then
    show_help
    exit 1
fi

workspace_manager "$@"
