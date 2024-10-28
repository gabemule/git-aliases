#!/bin/bash

# Check if the script is being run in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: This script must be run in a git repository."
    exit 1
fi

# Store the current branch name
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Stash any local changes
if [[ -n $(git status --porcelain) ]]; then
    echo "Stashing local changes..."
    git stash push -m "Auto stash before updating branch"
    stash_created=true
fi

# Fetch the latest changes from the remote
echo "Fetching latest changes from remote..."
git fetch origin

# Update the local production branch
echo "Updating local production branch..."
git checkout production
git pull origin production

# Switch back to the original branch
git checkout $current_branch

# Merge production into the current branch
echo "Merging production into $current_branch..."
if ! git merge production; then
    echo "Conflicts detected. Please resolve them and run 'git merge --continue'."
    echo "After resolving conflicts, commit the changes and push to update the remote branch."
    exit 1
fi

# Apply the stashed changes if any
if [[ $stash_created ]]; then
    echo "Applying stashed changes..."
    git stash pop
    if [[ $? -ne 0 ]]; then
        echo "Conflicts detected while applying stashed changes. Please resolve them manually."
        exit 1
    fi
fi

echo "Branch $current_branch has been successfully updated with the latest changes from production."
echo "Remember to push your changes to update the remote branch: git push origin $current_branch"
