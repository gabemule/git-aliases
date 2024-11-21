#!/bin/bash

# Source common configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common/config.sh"

# Initialize variables
target=""
title=""
body=""
draft=false
no_browser=false
non_interactive=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--target)
            target="$2"
            shift 2
            ;;
        --title)
            title="$2"
            non_interactive=true
            shift 2
            ;;
        --body)
            body="$2"
            shift 2
            ;;
        --draft)
            draft=true
            shift
            ;;
        --no-browser)
            no_browser=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}Error: This script must be run in a git repository.${NC}"
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
    echo "Please install it following the instructions at: https://cli.github.com/"
    echo
    echo -e "${BLUE}Quick install commands:${NC}"
    echo "  Homebrew (macOS): brew install gh"
    echo "  Windows: winget install --id GitHub.cli"
    echo "  Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi

# Get current branch and ticket
current_branch=$(git rev-parse --abbrev-ref HEAD)
ticket=$(git config branch."$current_branch".ticket)

# Check if we're on a valid branch type
valid_prefix=false
for prefix in "$FEATURE_PREFIX" "$BUGFIX_PREFIX" "$HOTFIX_PREFIX" "$RELEASE_PREFIX" "$DOCS_PREFIX"; do
    if [[ "$current_branch" =~ ^"$prefix" ]]; then
        valid_prefix=true
        break
    fi
done

if [ "$valid_prefix" = false ]; then
    echo -e "${RED}Error: You must be on a feature, bugfix, hotfix, or docs branch to open a PR.${NC}"
    echo "Current branch: $current_branch"
    exit 1
fi

# Get target branch if not provided
if [ -z "$target" ]; then
    echo -e "${BLUE}Select the target branch for your PR:${NC}"
    select target_choice in "development" "production"; do
        case $target_choice in
            development|production)
                target=$target_choice
                break
                ;;
            *) echo -e "${RED}Invalid option. Please try again.${NC}";;
        esac
    done
else
    # Validate provided target
    if [[ ! "$target" =~ ^(development|production)$ ]]; then
        echo -e "${RED}Invalid target branch: $target${NC}"
        echo "Valid targets: development, production"
        exit 1
    fi
fi

# Check if PR already exists
existing_pr=$(gh pr list --head "$current_branch" --base "$target" --json url --jq '.[0].url')
if [ -n "$existing_pr" ]; then
    echo -e "${YELLOW}A PR already exists for this branch: $existing_pr${NC}"
    exit 0
fi

# Handle PR title
if [ -z "$title" ]; then
    if [ -n "$ticket" ]; then
        default_title="[$ticket] "
    else
        default_title=""
    fi
    read -p "Enter PR title: $default_title" title_input
    title="$default_title$title_input"
elif [ -n "$ticket" ] && [[ ! "$title" =~ \[$ticket\] ]]; then
    # Add ticket to provided title if not present
    title="[$ticket] $title"
fi

# Handle PR description
if [ -z "$body" ]; then
    echo -e "${BLUE}Enter PR description (press Ctrl+D when finished):${NC}"
    body=$(cat)
fi

# Check for PR template
if [[ -f "$PR_TEMPLATE_PATH" ]]; then
    template=$(cat "$PR_TEMPLATE_PATH")
    body="$template\n\n$body"
fi

# If we have a ticket, add it to the description
if [ -n "$ticket" ]; then
    body="Related ticket: $ticket\n\n$body"
fi

# Build PR command
pr_args=()
pr_args+=(--base "$target")
pr_args+=(--head "$current_branch")
pr_args+=(--title "$title")
pr_args+=(--body "$body")

if [ "$draft" = true ]; then
    pr_args+=(--draft)
fi

if [ "$no_browser" = true ]; then
    # Create PR without opening browser
    if ! gh pr create "${pr_args[@]}"; then
        echo -e "${RED}Failed to create PR.${NC}"
        exit 1
    fi
else
    # Create and open PR in browser
    if ! gh pr create "${pr_args[@]}" --web; then
        echo -e "${RED}Failed to create PR.${NC}"
        exit 1
    fi
fi

echo
echo -e "${GREEN}PR created successfully!${NC}"
echo
