#!/bin/bash

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
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: This script must be run in a git repository."
    exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Please install it following the instructions at: https://cli.github.com/"
    echo
    echo "Quick install commands:"
    echo "  Homebrew (macOS): brew install gh"
    echo "  Windows: winget install --id GitHub.cli"
    echo "  Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
    exit 1
fi

# Get current branch and ticket
current_branch=$(git rev-parse --abbrev-ref HEAD)
ticket=$(git config branch."$current_branch".ticket)

# Get branch prefixes from config or use defaults
feature_prefix=$(git config workflow.featurePrefix || echo "feature/")
bugfix_prefix=$(git config workflow.bugfixPrefix || echo "bugfix/")
hotfix_prefix=$(git config workflow.hotfixPrefix || echo "hotfix/")
release_prefix=$(git config workflow.releasePrefix || echo "release/")
docs_prefix=$(git config workflow.docsPrefix || echo "docs/")

# Check if we're on a valid branch type
valid_prefix=false
for prefix in "$feature_prefix" "$bugfix_prefix" "$hotfix_prefix" "$release_prefix" "$docs_prefix"; do
    if [[ "$current_branch" =~ ^"$prefix" ]]; then
        valid_prefix=true
        break
    fi
done

if [ "$valid_prefix" = false ]; then
    echo "Error: You must be on a feature, bugfix, hotfix, or docs branch to open a PR."
    echo "Current branch: $current_branch"
    exit 1
fi

# Get default target from config or use development
default_target=$(git config workflow.defaultTarget || echo "development")

# Get target branch if not provided
if [ -z "$target" ]; then
    echo "Select the target branch for your PR:"
    select target_choice in "development" "production"; do
        case $target_choice in
            development|production)
                target=$target_choice
                break
                ;;
            *) echo "Invalid option. Please try again.";;
        esac
    done
else
    # Validate provided target
    if [[ ! "$target" =~ ^(development|production)$ ]]; then
        echo "Invalid target branch: $target"
        echo "Valid targets: development, production"
        exit 1
    fi
fi

# Check if PR already exists
existing_pr=$(gh pr list --head "$current_branch" --base "$target" --json url --jq '.[0].url')
if [ -n "$existing_pr" ]; then
    echo "A PR already exists for this branch: $existing_pr"
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
    echo "Enter PR description (press Ctrl+D when finished):"
    body=$(cat)
fi

# Get PR template path from config or use default
template_path=$(git config workflow.prTemplatePath || echo ".github/pull_request_template.md")

# Check for PR template
if [[ -f "$template_path" ]]; then
    template=$(cat "$template_path")
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
        echo "Failed to create PR."
        exit 1
    fi
else
    # Create and open PR in browser
    if ! gh pr create "${pr_args[@]}" --web; then
        echo "Failed to create PR."
        exit 1
    fi
fi

echo
echo "PR created successfully!"
echo
