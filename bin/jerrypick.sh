#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

jerrypick() {
    local dry_run=false
    local source_branch=""
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dry-run) dry_run=true ;;
            -h|--help) show_help; return 0 ;;
            *) 
                if [ -z "$source_branch" ]; then
                    source_branch="$1"
                else
                    echo "Unknown parameter: $1"; show_help; return 1
                fi
                ;;
        esac
        shift
    done
    
    # If no source branch provided, show selection
    if [ -z "$source_branch" ]; then
        echo -e "${BLUE}Available branches:${NC}"
        branches=($(git branch --format="%(refname:short)"))
        select_option "${branches[@]}"
        selected=$?
        source_branch="${branches[$selected]}"
    fi
    
    echo -e "${BLUE}Selected source branch: $source_branch${NC}"
    
    # Get commits with pagination
    local page_size=5
    local start=0
    local selected=0
    local commits=($(git log --format="%h - %s (%cr) by %an" $source_branch))
    local selections=()
    
    while true; do
        clear
        echo -e "${BLUE}Recent commits in $source_branch:${NC}"
        echo "↑/↓ to navigate, Space to select/deselect, Enter to confirm, 'n' for next page, 'p' for previous page"
        for ((i=start; i<start+page_size && i<${#commits[@]}; i++)); do
            if [[ " ${selections[@]} " =~ " $i " ]]; then
                mark="[x]"
            else
                mark="[ ]"
            fi
            if [ $i -eq $selected ]; then
                echo -e "${GREEN}> $mark ${commits[$i]}${NC}"
            else
                echo "  $mark ${commits[$i]}"
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
            " ") # Space
                if [[ " ${selections[@]} " =~ " $selected " ]]; then
                    selections=(${selections[@]/$selected})
                else
                    selections+=($selected)
                fi
                ;;
            "") # Enter
                break
                ;;
        esac
    done
    
    # Cherry-pick selected commits
    for i in "${selections[@]}"; do
        commit_hash=$(echo ${commits[$i]} | cut -d' ' -f1)
        if [ "$dry_run" = true ]; then
            echo -e "${YELLOW}[DRY-RUN] Would cherry-pick: ${commits[$i]}${NC}"
        else
            echo -e "${BLUE}Cherry-picking: ${commits[$i]}${NC}"
            if ! git cherry-pick "$commit_hash"; then
                echo -e "${RED}Conflict detected.${NC}"
                if ! handle_conflicts; then
                    echo -e "${RED}Cherry-pick aborted. Please resolve conflicts manually and try again.${NC}"
                    git cherry-pick --abort
                    return 1
                fi
            fi
        fi
    done
    
    if [ "$dry_run" = false ]; then
        echo -e "${GREEN}Successfully applied selected commits to current branch.${NC}"
    fi
}

show_help() {
    echo "Usage: git jerrypick [options] [source_branch]"
    echo
    echo "Options:"
    echo "  --dry-run      Preview cherry-pick changes without applying"
    echo "  -h             Show this help message"
}

# Function to display selectable list
select_option() {
    local options=("$@")
    local selected=0
    
    while true; do
        for ((i=0; i<${#options[@]}; i++)); do
            if [ $i -eq $selected ]; then
                echo -e "${GREEN}> ${options[$i]}${NC}"
            else
                echo "  ${options[$i]}"
            fi
        done
        
        read -sn1 key
        case "$key" in
            A) # Up arrow
                ((selected--))
                [ $selected -lt 0 ] && selected=$((${#options[@]}-1))
                ;;
            B) # Down arrow
                ((selected++))
                [ $selected -ge ${#options[@]} ] && selected=0
                ;;
            "") # Enter
                return $selected
                ;;
        esac
        clear
    done
}

# Run the jerrypick function with all arguments
jerrypick "$@"
