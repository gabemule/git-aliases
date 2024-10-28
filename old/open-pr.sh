#!/bin/bash

# Function to prompt for input with a default value
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
            echo "This field cannot be empty. Please try again."
        fi
    done
    echo "$input"
}

# Check if we're on a task branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
if [[ "$current_branch" != task/* ]]; then
    echo "Error: You must be on a task branch to open a PR."
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

# Get the repository details
repo_url=$(git config --get remote.origin.url)
repo_name=$(echo $repo_url | sed -n 's#.*/\([^.]*\)\.git#\1#p')
owner=$(echo $repo_url | sed -n 's#.*/\([^/]*\)/[^/]*\.git#\1#p')

# Check if PR already exists
existing_pr=$(gh pr list --head "$current_branch" --base "$target" --json url --jq '.[0].url')

if [ -n "$existing_pr" ]; then
    echo "A PR already exists for this branch: $existing_pr"
    exit 0
fi

# Prompt for PR title and description
title=$(prompt_non_empty "Enter PR title")
description=$(prompt_non_empty "Enter PR description")

# Create the PR
pr_url=$(gh pr create --base "$target" --head "$current_branch" --title "$title" --body "$description" --web)

if [ -n "$pr_url" ]; then
    echo "PR created successfully!"
    echo "PR URL: $pr_url"
else
    echo "Failed to create PR."
    exit 1
fi
