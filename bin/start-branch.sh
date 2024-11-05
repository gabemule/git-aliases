#!/bin/bash

# Check if script is run in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: This script must be run in a git repository."
    exit 1
fi

# Parse command line arguments for ticket
while getopts "t:" opt; do
    case $opt in
        t)
            ticket="$OPTARG"
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            exit 1
            ;;
    esac
done

# Array of valid branch types
types=("feature" "bugfix" "hotfix" "release" "docs")
descriptions=(
    "New feature development"
    "Bug fix in the code"
    "Critical fix for production"
    "Prepare for a new production release"
    "Write, update, or fix documentation"
)

# Function to prompt for input with default value
prompt_with_default() {
    local prompt="$1"
    local default="$2"
    local input
    read -p "$prompt [$default]: " input
    echo "${input:-$default}"
}

# Function to prompt for non-empty input
prompt_non_empty() {
    local prompt="$1"
    local input=""
    while [ -z "$input" ]; do
        read -p "$prompt: " input
        if [ -z "$input" ]; then
            echo "Input cannot be empty. Please try again."
        fi
    done
    echo "$input"
}

# Function to validate ticket format
validate_ticket() {
    if [[ ! $1 =~ ^[A-Z]+-[0-9]+$ ]]; then
        echo "Invalid ticket format. Must match PROJECT-XXX (e.g., PROJ-123)"
        return 1
    fi
    return 0
}

# Function to display menu and handle selection
select_option() {
    ESC=$(printf '\033')
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    local options=("$@")
    local selected=0

    cursor_blink_off

    while true; do
        echo
        echo
        local idx=0
        for option in "${options[@]}"; do
            cursor_to $((idx + 3))
            if [ $idx -eq $selected ]; then
                print_selected "$option"
            else
                print_option "$option"
            fi
            ((idx++))
        done

        case $(key_input) in
            up)    ((selected--)); 
                   if [ $selected -lt 0 ]; then selected=$((${#options[@]} - 1)); fi;;
            down)  ((selected++));
                   if [ $selected -ge ${#options[@]} ]; then selected=0; fi;;
            enter) break;;
        esac
    done

    cursor_to $((${#options[@]} + 3))
    cursor_blink_on

    return $selected
}

# Check for modified files and stash if needed
if [[ -n $(git status -s) ]]; then
    echo "You have modified files. Creating a stash..."
    stash_description="Auto stash before start-branch on $(date '+%Y-%m-%d %H:%M:%S')"
    git stash save "$stash_description" -a
    echo "Stash created with description: $stash_description"
    sleep 2
fi

# Get main branch from config or use default (production)
main_branch=$(git config workflow.mainBranch || echo "production")

# Switch to main branch and pull latest changes
git checkout $main_branch
git pull origin $main_branch

# Clear screen and select branch type
clear
echo "Select branch type:"
select_option "${types[@]}"
selected=$?
branch_type=${types[$selected]}
description=${descriptions[$selected]}

echo
echo "You selected: $branch_type - $description"
echo

# Get task name
task_name=$(prompt_non_empty "Enter the name of the new task")

# If ticket not provided via argument, prompt for it
if [ -z "$ticket" ]; then
    while true; do
        ticket=$(prompt_non_empty "Enter ticket number (e.g., PROJ-123)")
        if validate_ticket "$ticket"; then
            break
        fi
    done
fi

# Create branch with descriptive name (without ticket)
branch_name="${branch_type}/${task_name// /-}"
if git checkout -b "$branch_name"; then
    # Store ticket reference in git config
    git config branch."$branch_name".ticket "$ticket"
    
    echo
    echo "Successfully created and switched to new branch: $branch_name"
    echo "Associated ticket: $ticket"
    echo "You can now start working on your task."
    echo
    echo "When you're done:"
    echo "1. Create a pull request to merge into 'development'"
    echo "2. After testing, create another pull request to merge into '$main_branch'"
    echo
else
    echo
    echo "Error: Failed to create new branch."
    echo
    exit 1
fi
