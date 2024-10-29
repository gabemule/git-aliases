#!/bin/bash

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: This script must be run in a git repository."
    exit 1
fi

# Get current branch and ticket
current_branch=$(git rev-parse --abbrev-ref HEAD)
ticket=$(git config branch."$current_branch".ticket)

# Check if we're on a feature/bugfix/hotfix/docs branch
if [[ ! "$current_branch" =~ ^(feature|bugfix|hotfix|docs)/ ]]; then
    echo "Error: You must be on a feature, bugfix, hotfix, or docs branch to open a PR."
    echo "Current branch: $current_branch"
    exit 1
fi

# Prompt for the target branch
echo "Select the target branch for your PR:"
select target in "development" "production"; do
    case $target in
        development|production) break;;
        *) echo "Invalid option. Please try again.";;
    esac
done

# Check if PR already exists
existing_pr=$(gh pr list --head "$current_branch" --base "$target" --json url --jq '.[0].url')
if [ -n "$existing_pr" ]; then
    echo "A PR already exists for this branch: $existing_pr"
    exit 0
fi

# Prompt for PR title, including ticket if available
if [ -n "$ticket" ]; then
    default_title="[$ticket] "
else
    default_title=""
fi
read -p "Enter PR title: $default_title" title_input
title="$default_title$title_input"

# Prompt for PR description
echo "Enter PR description (press Ctrl+D when finished):"
description=$(cat)

# If we have a ticket, add it to the description
if [ -n "$ticket" ]; then
    description="Related ticket: $ticket\n\n$description"
fi

# Create the PR
pr_url=$(gh pr create --base "$target" --head "$current_branch" --title "$title" --body "$description" --web)

if [ -n "$pr_url" ]; then
    echo "PR created successfully!"
    echo "PR URL: $pr_url"
else
    echo "Failed to create PR."
    exit 1
fi
