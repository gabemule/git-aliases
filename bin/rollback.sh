#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

rollback() {
    local dry_run=false
    local skip_verify=false
    local continue_rollback=false
    
    # Get main branch from config or use default
    local main_branch=$(git config workflow.mainBranch || echo "production")
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dry-run) dry_run=true ;;
            --skip-verify) skip_verify=true ;;
            --continue) continue_rollback=true ;;
            -h|--help) show_help; return 0 ;;
            *) echo "Unknown parameter: $1"; show_help; return 1 ;;
        esac
        shift
    done
    
    if [[ "$continue_rollback" == true ]]; then
        if [[ ! -f ".git/ROLLBACK_IN_PROGRESS" ]]; then
            echo -e "${RED}No rollback in progress. Run 'git rollback' without --continue${NC}"
            return 1
        fi
        local rollback_branch=$(cat .git/ROLLBACK_IN_PROGRESS)
        echo -e "${BLUE}Continuing rollback on branch: $rollback_branch${NC}"
        git revert --continue
        if [[ $? -ne 0 ]]; then
            if ! handle_conflicts; then
                echo -e "${RED}Rollback failed. Please resolve conflicts and run 'git rollback --continue'${NC}"
                return 1
            fi
        fi
        git commit -m "Rollback: Continue revert process"
        rm -f .git/ROLLBACK_IN_PROGRESS
        echo -e "${GREEN}Rollback completed successfully${NC}"
        return 0
    fi
    
    # Ensure we're up to date
    if ! git fetch origin; then
        echo -e "${RED}Error: Failed to fetch latest changes${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Using main branch: $main_branch${NC}"
    
    # Get commits with pagination
    local page_size=5
    local start=0
    local selected=0
    local commits=($(git log --format="%h - %s (%cr) by %an" origin/$main_branch))
    
    while true; do
        clear
        echo -e "${BLUE}Recent changes in $main_branch:${NC}"
        echo "↑/↓ to navigate, Enter to select, 'n' for next page, 'p' for previous page"
        for ((i=start; i<start+page_size && i<${#commits[@]}; i++)); do
            if [ $i -eq $selected ]; then
                echo -e "${GREEN}> ${commits[$i]}${NC}"
            else
                echo "  ${commits[$i]}"
            fi
        done
        echo -e "${YELLOW}[$(($start+1))-$((start+page_size))/${#commits[@]} commits]${NC}"
        
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
        echo -e "${YELLOW}[DRY-RUN] Would create branch: $rollback_branch${NC}"
        echo -e "${YELLOW}[DRY-RUN] Would revert commits from $target_commit to HEAD${NC}"
        return 0
    fi
    
    git checkout -b "$rollback_branch" origin/$main_branch
    
    # Create revert commit
    if ! git revert --no-commit "$target_commit"..HEAD; then
        echo -e "${RED}Conflicts detected during rollback.${NC}"
        if ! handle_conflicts; then
            echo -e "${RED}Rollback failed. Please resolve conflicts and run 'git rollback --continue'${NC}"
            echo "$rollback_branch" > .git/ROLLBACK_IN_PROGRESS
            return 1
        fi
    fi

    # Verify changes if not skipped
    if [[ "$skip_verify" == false ]]; then
        echo -e "${BLUE}Verifying changes...${NC}"
        verify_rollback "$rollback_branch" "$main_branch"
        confirm=$(read_secure_input "Continue with rollback? (y/N) ")
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Rollback aborted${NC}"
            git checkout -
            git branch -D "$rollback_branch"
            return 1
        fi
    fi

    git commit -m "Rollback: Revert $main_branch to $target_commit"
    
    # Push and create PR
    if ! git push origin "$rollback_branch"; then
        echo -e "${RED}Error: Failed to push rollback branch${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Rollback branch created: $rollback_branch${NC}"
    echo -e "${BLUE}Please review changes and merge through PR process${NC}"
}

verify_rollback() {
    local rollback_branch="$1"
    local main_branch="$2"
    
    # Compare states
    echo -e "${BLUE}Changes to be reverted:${NC}"
    git diff origin/$main_branch.."$rollback_branch"
    
    # Check for conflicts
    if git merge-base --is-ancestor "$rollback_branch" origin/$main_branch; then
        echo -e "${GREEN}✓ Clean rollback possible${NC}"
    else
        echo -e "${YELLOW}⚠️ Conflicts may occur during rollback${NC}"
        echo -e "${YELLOW}Please review carefully${NC}"
    fi
}

show_help() {
    echo "Usage: git rollback [options]"
    echo
    echo "Options:"
    echo "  --dry-run      Preview rollback changes without creating branch"
    echo "  --skip-verify  Skip verification step"
    echo "  --continue     Continue rollback after resolving conflicts"
    echo "  -h             Show this help message"
}

# Run the rollback function with all arguments
rollback "$@"
