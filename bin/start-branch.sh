#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

# Show help message
show_help() {
    echo "Usage: git start-branch [options]"
    echo "   or: git start [options]"
    echo
    echo "Create a new branch with standardized naming and ticket tracking"
    echo
    echo "Options:"
    echo "  -t, --ticket <id>       Specify ticket reference (e.g., PROJ-123)"
    echo "  -n, --name <name>       Specify branch name"
    echo "  -b, --branch-type <type> Specify branch type"
    echo "      --current          Create branch from current branch"
    echo "      --no-sync          Skip syncing with main branch"
    echo "      --no-stash         Skip stashing changes"
    echo "  -h                      Show this help message"
    echo
    echo "Branch Types:"
    echo "  feature  - New feature development"
    echo "  bugfix   - Bug fix in the code"
    echo "  hotfix   - Critical fix for production"
    echo "  release  - Prepare for a new production release"
    echo "  docs     - Documentation changes"
    exit 0
}

# Check if script is run in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: This script must be run in a git repository.${NC}"
    exit 1
fi

# Initialize flags with default values
ticket=""
branch_name=""
branch_type=""
use_current_branch=false
no_sync=false
no_stash=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h)
            show_help
            ;;
        -t|--ticket)
            ticket="$2"
            shift 2
            ;;
        -n|--name)
            branch_name="$2"
            shift 2
            ;;
        -b|--branch-type)
            branch_type="$2"
            shift 2
            ;;
        --current)
            use_current_branch=true
            shift
            ;;
        --no-sync)
            no_sync=true
            shift
            ;;
        --no-stash)
            no_stash=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h to see available options"
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

# Handle stashing if needed
if [[ "$no_stash" != true ]] && [[ -n $(git status -s) ]]; then
    echo -e "${BLUE}You have modified files. Creating a stash...${NC}"
    stash_description="Auto stash before start-branch on $(date '+%Y-%m-%d %H:%M:%S')"
    git stash save "$stash_description" -a
    echo -e "${GREEN}Stash created with description: $stash_description${NC}"
    sleep 2
fi

# Handle branch source and sync
if [[ "$use_current_branch" != true ]]; then
    if [[ "$no_sync" != true ]]; then
        # Switch to main branch and pull latest changes
        git checkout $MAIN_BRANCH
        git pull origin $MAIN_BRANCH
    fi
fi

# Validate/prompt for branch type if not provided
if [ -n "$branch_type" ]; then
    if [[ ! " ${types[@]} " =~ " ${branch_type} " ]]; then
        echo -e "${RED}Invalid branch type: $branch_type${NC}"
        echo "Valid types: ${types[*]}"
        exit 1
    fi
else
    # Clear screen and select branch type
    clear
    echo -e "${BLUE}Select branch type:${NC}"
    select_option "${types[@]}"
    selected=$?
    branch_type=${types[$selected]}
    description=${descriptions[$selected]}
    echo
    echo -e "${GREEN}You selected: $branch_type - $description${NC}"
    echo
fi

# Get task name if not provided
if [ -z "$branch_name" ]; then
    branch_name=$(read_secure_input "Enter the name of the new task: ")
    while [ -z "$branch_name" ]; do
        echo "Input cannot be empty. Please try again."
        branch_name=$(read_secure_input "Enter the name of the new task: ")
    done
fi

# If ticket not provided via argument, prompt for it
if [ -z "$ticket" ]; then
    while true; do
        ticket=$(read_secure_input "Enter ticket number (e.g., PROJ-123): ")
        if [ -n "$ticket" ] && validate_ticket "$ticket"; then
            break
        else
            echo "Invalid ticket format or empty input. Please try again."
        fi
    done
fi

# Get prefix based on branch type
case $branch_type in
    feature) prefix=$FEATURE_PREFIX ;;
    bugfix)  prefix=$BUGFIX_PREFIX ;;
    hotfix)  prefix=$HOTFIX_PREFIX ;;
    release) prefix=$RELEASE_PREFIX ;;
    docs)    prefix=$DOCS_PREFIX ;;
    *)       prefix="$branch_type/" ;;
esac

# Create branch with descriptive name (without ticket)
final_branch_name="${prefix}${branch_name// /-}"
if git checkout -b "$final_branch_name"; then
    # Store ticket reference in git config
    git config branch."$final_branch_name".ticket "$ticket"
    
    echo
    echo -e "${GREEN}Successfully created and switched to new branch: $final_branch_name${NC}"
    echo -e "${GREEN}Associated ticket: $ticket${NC}"
    echo -e "${BLUE}You can now start working on your task.${NC}"
    echo
    echo "When you're done:"
    echo "1. Create a pull request to merge into 'development'"
    echo "2. After testing, create another pull request to merge into '$MAIN_BRANCH'"
    echo
else
    echo
    echo -e "${RED}Error: Failed to create new branch.${NC}"
    echo
    exit 1
fi
