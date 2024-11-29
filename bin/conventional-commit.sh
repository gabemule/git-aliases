#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

# Show help message
show_help() {
    echo "Usage: git cc [options]"
    echo
    echo "Create a commit following conventional commit format"
    echo
    echo "Options:"
    echo "  -t, --ticket <id>      Override ticket for this commit"
    echo "  -m, --message <msg>    Specify commit message"
    echo "  -s, --scope <scope>    Specify commit scope"
    echo "      --no-scope        Skip scope prompt"
    echo "      --body <text>     Specify commit body"
    echo "      --no-body         Skip body prompt"
    echo "  -p, --push            Push changes after commit"
    echo "  -b, --breaking        Mark as breaking change"
    echo "      --no-verify       Skip commit hooks"
    echo "      --type <type>     Specify commit type"
    echo "      --non-interactive Skip all prompts"
    echo "  -h                    Show this help message"
    echo
    echo "Types:"
    echo "  feat     - New feature"
    echo "  fix      - Bug fix"
    echo "  docs     - Documentation only changes"
    echo "  style    - Changes not affecting code"
    echo "  refactor - Code change that neither fixes a bug nor adds a feature"
    echo "  perf     - Code change that improves performance"
    echo "  test     - Adding missing tests or correcting existing tests"
    echo "  chore    - Changes to the build process or auxiliary tools"
    echo "  ci       - Changes to CI configuration files and scripts"
    echo "  build    - Changes that affect the build system"
    exit 0
}

# Initialize variables
one_time_ticket=""
message=""
scope=""
type=""
body=""
auto_push=false
breaking=false
no_verify=false
no_scope=false
no_body=false
non_interactive=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h)
            show_help
            ;;
        -t|--ticket)
            one_time_ticket="$2"
            if ! validate_ticket "$one_time_ticket"; then
                exit 1
            fi
            shift 2
            ;;
        -m|--message)
            message="$2"
            shift 2
            ;;
        -s|--scope)
            scope="$2"
            shift 2
            ;;
        --no-scope)
            no_scope=true
            shift
            ;;
        --body)
            body="$2"
            shift 2
            ;;
        --no-body)
            no_body=true
            shift
            ;;
        -p|--push)
            auto_push=true
            shift
            ;;
        -b|--breaking)
            breaking=true
            shift
            ;;
        --no-verify)
            no_verify=true
            shift
            ;;
        --type)
            type="$2"
            shift 2
            ;;
        --non-interactive)
            non_interactive=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use -h to see available options"
            exit 1
            ;;
    esac
done

# Check for staged files
if [ -z "$(git diff --cached --name-only)" ]; then
    echo -e "${RED}Error: No staged files. Stage your changes before committing.${NC}"
    echo
    git status
    exit 1
fi

# Valid commit types
types=("feat" "fix" "docs" "style" "refactor" "perf" "test" "chore" "ci" "build")
descriptions=(
    "New feature"
    "Bug fix"
    "Documentation only changes"
    "Changes that do not affect the meaning of the code"
    "A code change that neither fixes a bug nor adds a feature"
    "A code change that improves performance"
    "Adding missing tests or correcting existing tests"
    "Changes to the build process or auxiliary tools"
    "Changes to CI configuration files and scripts"
    "Changes that affect the build system or external dependencies"
)

# If type not provided, select interactively
if [ -z "$type" ]; then
    clear
    echo -e "${BLUE}Select commit type:${NC}"
    select_option "${types[@]}"
    selected=$?
    type=${types[$selected]}
    description=${descriptions[$selected]}

    echo
    echo -e "${GREEN}You selected: $type - $description${NC}"
    echo
else
    # Validate provided type
    if [[ ! " ${types[@]} " =~ " ${type} " ]]; then
        echo -e "${RED}Invalid type: $type${NC}"
        echo "Valid types: ${types[*]}"
        exit 1
    fi
fi

# Get scope if not provided and not explicitly skipped
if [ -z "$scope" ] && [ "$no_scope" != true ]; then
    scope=$(prompt_with_default "Enter scope (optional)" "")
fi

scope_part=""
if [ -n "$scope" ]; then
    scope_part="($scope)"
fi

# Get commit description if not provided
if [ -z "$message" ]; then
    message=$(prompt_with_default "Enter short description" "")
fi

# Handle commit body
if [ "$no_body" != true ]; then
    if [ -z "$body" ]; then
        if [ "$non_interactive" != true ]; then
            echo "Enter commit body (optional, press Ctrl+D when finished):"
            body=""
            while IFS= read -r line; do
                body+="$line"$'\n'
            done
            body=${body%$'\n'}  # Remove trailing newline
        fi
    fi
fi

# Handle breaking change
breaking_change_marker=""
breaking_change_footer=""
if [ "$breaking" = true ]; then
    breaking_change_marker="!"
    breaking_change_footer="BREAKING CHANGE: Breaking changes introduced"
fi

# Get ticket from branch config or one-time ticket
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [ -n "$one_time_ticket" ]; then
    ticket="$one_time_ticket"
else
    ticket=$(git config branch."$current_branch".ticket)
    if [ -z "$ticket" ]; then
        ticket=""  # Explicitly set to empty if proceeding without ticket
    fi
fi

# Build commit message parts
commit_title="${type}${scope_part}${breaking_change_marker}: ${message}"
if [ -n "$ticket" ]; then
    commit_title+=" [${ticket}]"
fi

# Display final message
echo
echo -e "\n${BLUE}Final commit message:${NC}"
echo "----------"
echo
echo "$commit_title"
if [ -n "$body" ]; then
    echo
    echo "$body"
fi
if [ -n "$breaking_change_footer" ]; then
    echo
    echo "$breaking_change_footer"
fi
echo
echo "----------"
echo

# Confirm commit in interactive mode
if [ "$non_interactive" != true ]; then
    confirm=$(read_secure_input "Do you want to commit with this message? (Y/n) ")
    if [[ ! $confirm =~ ^[Yy]?$ ]]; then
        echo
        echo -e "${YELLOW}Commit aborted.${NC}"
        echo
        exit 0
    fi
fi

# Build commit command
commit_args=()
if [ "$no_verify" = true ]; then
    commit_args+=(--no-verify)
fi
commit_args+=(-m "$commit_title")
if [ -n "$body" ]; then
    commit_args+=(-m "$body")
fi
if [ -n "$breaking_change_footer" ]; then
    commit_args+=(-m "$breaking_change_footer")
fi

# Commit changes
if ! git commit "${commit_args[@]}"; then
    echo
    echo -e "${RED}Error: Commit failed! This might be due to husky hooks or other git errors.${NC}"
    echo "Please check the error message above and try again."
    echo
    exit 1
fi

echo
echo -e "${GREEN}Commit successful!${NC}"
echo

# Handle auto-push
if [ "$auto_push" = true ]; then
    echo -e "${BLUE}Auto-pushing changes...${NC}"
    if git push origin $current_branch; then
        echo
        echo -e "${GREEN}Changes pushed successfully to $current_branch.${NC}"
        echo
    else
        echo
        echo -e "${RED}Failed to push changes. Please push manually.${NC}"
        echo
        exit 1
    fi
elif [ "$non_interactive" != true ]; then
    # Offer to push in interactive mode
    push_confirm=$(read_secure_input "Do you want to push the changes now? (Y/n) ")
    if [[ $push_confirm =~ ^[Yy]?$ ]]; then
        echo
        if git push origin $current_branch; then
            echo
            echo -e "${GREEN}Changes pushed successfully to $current_branch.${NC}"
            echo
        else
            echo
            echo -e "${RED}Failed to push changes. Please push manually.${NC}"
            echo
            exit 1
        fi
    else
        echo
        echo -e "${YELLOW}Changes not pushed. Remember to push your changes later.${NC}"
        echo
    fi
fi
