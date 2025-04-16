#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

jerrypick() {
    local dry_run=false
    local source_branch=""
    local debug_mode=false
    
    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --dry-run) dry_run=true ;;
            --debug) debug_mode=true ;;
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
    
    # Check if source_branch is a commit hash (40 characters of hex)
    if [[ "$source_branch" =~ ^[0-9a-f]{40}$ ]] || [[ "$source_branch" =~ ^[0-9a-f]{7,}$ ]]; then
        # It's a commit hash
        local commit_hash=$source_branch
        echo -e "${BLUE}Using commit: $commit_hash${NC}"
        
        # Get commit details
        local commit_details=$(git show --no-patch --format="%h - %s (%cr) by %an" $commit_hash)
        
        # Cherry-pick the commit
        echo -e "${BLUE}Cherry-picking: $commit_details${NC}"
        if ! git cherry-pick "$commit_hash"; then
            echo -e "${RED}Conflict detected.${NC}"
            if ! handle_conflicts; then
                echo -e "${RED}Cherry-pick aborted. Please resolve conflicts manually and try again.${NC}"
                git cherry-pick --abort
                return 1
            fi
        fi
        
        echo -e "${GREEN}Successfully applied commit to current branch.${NC}"
        return 0
    fi
    
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
    # Use readarray to preserve full lines
    # Show all commits in the source branch
    
    # Get commits directly using git log
    local commits_output=$(git log --format="%h - %s (%cr) by %an" $source_branch)
    
    # Convert output to array
    IFS=$'\n' read -rd '' -a commits <<< "$commits_output"
    
    if [ "$debug_mode" = true ]; then
        echo "Debug: Running git log for $source_branch"
        echo "$commits_output"
        echo "Debug: End of git log output"
        echo "Debug: Number of commits found: ${#commits[@]}"
        for ((i=0; i<${#commits[@]}; i++)); do
            echo "Debug: Commit $i: ${commits[$i]}"
        done
        return 0
    fi
    
    # If no commits found, show error and exit
    if [ ${#commits[@]} -eq 0 ]; then
        echo -e "${RED}No commits found in branch $source_branch${NC}"
        return 1
    fi
    
    local selections=()
    
    # Use a more robust approach for interactive selection
    while true; do
        clear
        echo -e "${BLUE}Recent commits in $source_branch:${NC}"
        echo "Use j/k to navigate, Space to select/deselect, Enter to confirm"
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
        
        # Use a different approach to read keys
        IFS= read -r -s -n1 key
        
        # Handle arrow keys (they send escape sequences)
        if [[ $key == $'\e' ]]; then
            # Read the next two characters
            read -r -s -n1 key2
            read -r -s -n1 key3
            
            # Process arrow keys
            if [[ $key2 == "[" ]]; then
                case $key3 in
                    A)  # Up arrow
                        ((selected--))
                        if [ $selected -lt $start ]; then
                            ((start-=page_size))
                            [ $start -lt 0 ] && start=0
                        fi
                        [ $selected -lt 0 ] && selected=$((${#commits[@]}-1))
                        ;;
                    B)  # Down arrow
                        ((selected++))
                        if [ $selected -ge $((start+page_size)) ]; then
                            ((start+=page_size))
                            [ $((start+page_size)) -gt ${#commits[@]} ] && start=$((${#commits[@]}-page_size))
                            [ $start -lt 0 ] && start=0
                        fi
                        [ $selected -ge ${#commits[@]} ] && selected=0
                        ;;
                esac
            fi
        else
            # Process other keys
            case "$key" in
                n)  # Next page
                    ((start+=page_size))
                    [ $((start+page_size)) -gt ${#commits[@]} ] && start=$((${#commits[@]}-page_size))
                    [ $start -lt 0 ] && start=0
                    selected=$start
                    ;;
                p)  # Previous page
                    ((start-=page_size))
                    [ $start -lt 0 ] && start=0
                    selected=$start
                    ;;
                " ")  # Space
                    # Toggle selection
                    if [[ " ${selections[@]} " =~ " $selected " ]]; then
                        # Remove from selections
                        new_selections=()
                        for sel in "${selections[@]}"; do
                            if [ $sel -ne $selected ]; then
                                new_selections+=($sel)
                            fi
                        done
                        selections=("${new_selections[@]}")
                    else
                        # Add to selections
                        selections+=($selected)
                    fi
                    ;;
                $'\n'|"")  # Enter (can be either newline or empty string)
                    break
                    ;;
            esac
        fi
    done
    
    # Cherry-pick selected commits
    for i in "${selections[@]}"; do
        commit_hash=$(echo "${commits[$i]}" | cut -d' ' -f1)
        if [ "$dry_run" = true ]; then
            echo -e "${YELLOW}[DRY-RUN] Would cherry-pick: ${commits[$i]}${NC}"
        else
            echo -e "${BLUE}Cherry-picking: ${commits[$i]}${NC}"
            if ! git cherry-pick "$commit_hash"; then
                echo -e "${RED}Conflict detected while cherry-picking: ${commits[$i]}${NC}"
                echo "Options:"
                echo "  1) Continue (resolve conflicts manually)"
                echo "  2) Skip this commit"
                echo "  3) Abort cherry-pick"
                read -p "Enter your choice (1-3): " choice
                
                case "$choice" in
                    1)  # Continue
                        echo -e "${YELLOW}Please resolve conflicts manually and run 'git cherry-pick --continue' when done.${NC}"
                        return 0
                        ;;
                    2)  # Skip
                        echo -e "${YELLOW}Skipping commit: ${commits[$i]}${NC}"
                        git cherry-pick --skip
                        ;;
                    *)  # Abort
                        echo -e "${RED}Cherry-pick aborted.${NC}"
                        git cherry-pick --abort
                        return 1
                        ;;
                esac
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
    echo "  --debug        Show debug information and exit"
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
        
        # Simple key reading
        read -s -n 1 key
        if [[ "$key" == "k" ]]; then
            # Up
            ((selected--))
            [ $selected -lt 0 ] && selected=$((${#options[@]}-1))
        elif [[ "$key" == "j" ]]; then
            # Down
            ((selected++))
            [ $selected -ge ${#options[@]} ] && selected=0
        elif [[ "$key" == $'\n' || "$key" == "" ]]; then
            # Enter
            return $selected
        fi
        clear
    done
}

# Run the jerrypick function with all arguments
jerrypick "$@"
