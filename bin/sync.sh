#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

sync_branch() {
    local current_branch=$(git rev-parse --abbrev-ref HEAD)
    local main_branch=$(git config workflow.mainBranch || echo "production")
    local continue_sync=false
    local skip_update=false
    local skip_pull=false
    local skip_push=false
    local dry_run=false
    local stashed=false
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --continue) continue_sync=true ;;
            --no-update) skip_update=true ;;
            --no-pull) skip_pull=true ;;
            --no-push) skip_push=true ;;
            --dry-run) 
                dry_run=true
                skip_push=true
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            *) echo -e "${RED}Unknown parameter: $1${NC}"; show_help; return 1 ;;
        esac
        shift
    done
    
    # If continuing, check for .git/SYNC_IN_PROGRESS
    if [[ "$continue_sync" == true ]]; then
        if [[ ! -f ".git/SYNC_IN_PROGRESS" ]]; then
            echo -e "${RED}No sync in progress. Run 'git sync' without --continue${NC}"
            return 1
        fi
        # Read stashed state
        stashed=$(cat .git/SYNC_IN_PROGRESS)
    else
        # Check for existing sync
        if [[ -f ".git/SYNC_IN_PROGRESS" ]]; then
            echo -e "${YELLOW}Previous sync in progress. Run 'git sync --continue' after resolving conflicts${NC}"
            echo -e "${YELLOW}Or remove .git/SYNC_IN_PROGRESS to start fresh${NC}"
            return 1
        fi
        
        # Stash changes if any
        if [[ -n $(git status -s) ]]; then
            if [[ "$dry_run" == true ]]; then
                echo -e "${BLUE}[DRY-RUN] Would stash changes${NC}"
            else
                echo -e "${BLUE}Stashing local changes...${NC}"
                git stash push -m "Auto stash before sync"
                stashed=true
                echo "$stashed" > .git/SYNC_IN_PROGRESS
            fi
        fi
    fi
    
    # Update from main branch if not skipped
    if [[ "$skip_update" == false && "$current_branch" != "$main_branch" ]]; then
        if [[ "$dry_run" == true ]]; then
            echo -e "${BLUE}[DRY-RUN] Would sync with $main_branch${NC}"
            # Check for potential conflicts
            if git merge-tree $(git merge-base HEAD origin/$main_branch) HEAD origin/$main_branch | grep -q "^<<<<<<<"; then
                echo -e "${YELLOW}[DRY-RUN] Conflicts would occur in:${NC}"
                git merge-tree $(git merge-base HEAD origin/$main_branch) HEAD origin/$main_branch | grep -A 3 "^<<<<<<<"
            fi
        else
            echo -e "${BLUE}Syncing with $main_branch...${NC}"
            if ! git merge origin/$main_branch --no-edit; then
                echo -e "${RED}Conflicts detected while merging $main_branch:${NC}"
                git diff --name-only --diff-filter=U
                echo
                echo -e "${YELLOW}Launching mergetool to resolve conflicts...${NC}"
                if ! git mergetool; then
                    echo -e "${RED}Error: Failed to launch mergetool${NC}"
                    return 1
                fi
                
                # Check if conflicts remain
                if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
                    echo -e "${YELLOW}Some conflicts still need to be resolved manually.${NC}"
                    echo -e "${YELLOW}Please resolve remaining conflicts and run 'git sync --continue'${NC}"
                    if [[ "$stashed" == true ]]; then
                        echo -e "${BLUE}Your changes are safely stashed.${NC}"
                    fi
                    return 1
                fi
                
                # Commit the merge
                git commit -m "Merge origin/$main_branch into $current_branch"
            fi
        fi
    fi
    
    # Pull latest for current branch if not skipped
    if [[ "$skip_pull" == false ]]; then
        if [[ "$dry_run" == true ]]; then
            echo -e "${BLUE}[DRY-RUN] Would pull latest changes${NC}"
        else
            echo -e "${BLUE}Pulling latest changes...${NC}"
            if ! git pull origin $current_branch --ff-only; then
                echo -e "${YELLOW}Error: Your branch has diverged from origin/$current_branch${NC}"
                echo -e "${BLUE}Local:  $(git rev-parse --short HEAD) $(git log -1 --pretty=%s HEAD)${NC}"
                echo -e "${BLUE}Remote: $(git rev-parse --short origin/$current_branch) $(git log -1 --pretty=%s origin/$current_branch)${NC}"
                echo -e "${YELLOW}Attempting to resolve with rebase...${NC}"
                
                if ! git pull --rebase origin $current_branch; then
                    echo -e "${YELLOW}Conflicts detected during rebase. Launching mergetool...${NC}"
                    if ! git mergetool; then
                        echo -e "${RED}Error: Failed to launch mergetool${NC}"
                        return 1
                    fi
                    
                    # Check if conflicts remain
                    if [[ -n $(git diff --name-only --diff-filter=U) ]]; then
                        echo -e "${YELLOW}Some conflicts still need to be resolved manually.${NC}"
                        echo -e "${YELLOW}Please resolve remaining conflicts and run 'git rebase --continue'${NC}"
                        echo -e "${YELLOW}Then run 'git sync' again${NC}"
                        if [[ "$stashed" == true ]]; then
                            echo -e "${BLUE}Your changes are safely stashed.${NC}"
                        fi
                        return 1
                    fi
                    
                    # Continue rebase
                    git rebase --continue
                fi
            fi
        fi
    else
        echo -e "${BLUE}Skipping pull (--no-pull specified)${NC}"
    fi
    
    # Push changes if not skipped
    if [[ "$skip_push" == true ]]; then
        echo -e "${BLUE}Skipping push (--no-push specified)${NC}"
    else
        if [[ "$dry_run" == true ]]; then
            echo -e "${BLUE}[DRY-RUN] Would push changes${NC}"
        else
            echo -e "${BLUE}Pushing to origin...${NC}"
            if ! git push origin $current_branch; then
                echo -e "${RED}Error: Failed to push changes${NC}"
                return 1
            fi
        fi
    fi
    
    # Restore stashed changes if any
    if [[ "$stashed" == true && "$dry_run" == false ]]; then
        echo -e "${BLUE}Restoring local changes...${NC}"
        git stash pop
    fi
    
    # Clean up
    if [[ "$dry_run" == false ]]; then
        rm -f .git/SYNC_IN_PROGRESS
    fi
    
    echo -e "${GREEN}Branch successfully synchronized!${NC}"
}

show_help() {
    echo "Usage: git sync [options]"
    echo
    echo "Synchronize current branch with main branch and remote"
    echo
    echo "Options:"
    echo "  --continue        Resume sync after conflict resolution"
    echo "  --no-update       Skip updating from main branch"
    echo "  --no-pull         Skip pulling from remote"
    echo "  --no-push         Skip pushing to remote"
    echo "  --dry-run         Show what would be done without making changes"
    echo "  -h, --help        Show this help message"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            sync_branch "$@"
            exit $?
            ;;
    esac
done

# If no arguments provided, run sync_branch
if [[ $# -eq 0 ]]; then
    sync_branch
    exit $?
fi
