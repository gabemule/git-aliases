#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the git-aliases directory path from git config
ALIASES_DIR=$(dirname "$(git config --get include.path)")
if [ -z "$ALIASES_DIR" ]; then
    echo -e "${RED}Error: Could not determine git-aliases directory.${NC}"
    echo "Please ensure git-aliases is properly configured with:"
    echo "git config --global include.path /path/to/git-aliases/.gitconfig"
    exit 1
fi

# Function to pause and wait for user
pause() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to show guide message
show_guide() {
    clear
    echo -e "${BLUE}=== $1 ===${NC}\n"
    echo -e "$2\n"
    pause
}

# Function to handle errors
handle_error() {
    echo -e "\n${RED}Error: $1${NC}"
    if [[ "$1" == *"GitHub CLI"* ]]; then
        # For GitHub CLI errors, just show warning and continue
        echo -e "${YELLOW}PR creation will be skipped. Install GitHub CLI to test this feature.${NC}"
        return 0
    fi
    echo "Would you like to continue the test? (Y/n)"
    read -n 1 continue_test
    if [[ ! $continue_test =~ ^[Yy]?$ ]]; then
        exit 1
    fi
    echo
}

# Function to handle push with pull
handle_push() {
    local branch=$1
    if ! git push origin $branch; then
        echo -e "${YELLOW}Push failed. Attempting to sync with remote...${NC}"
        git pull origin $branch --rebase || handle_error "Failed to pull changes"
        git push origin $branch || handle_error "Failed to push changes"
    fi
}

# Function to ensure branch exists
ensure_branch() {
    local branch=$1
    if ! git rev-parse --verify $branch >/dev/null 2>&1; then
        echo -e "${YELLOW}Creating $branch branch...${NC}"
        git checkout -b $branch || handle_error "Failed to create $branch branch"
        git push origin $branch || handle_error "Failed to push $branch branch"
    fi
}

# Function to cleanup branches
cleanup_branch() {
    local branch=$1
    echo -e "${YELLOW}Cleaning up $branch...${NC}"
    git checkout production
    git branch -D $branch 2>/dev/null
    git push origin --delete $branch 2>/dev/null
}

# Function to handle uncommitted changes
handle_uncommitted() {
    if [[ -n $(git status -s) ]]; then
        echo -e "${YELLOW}Stashing uncommitted changes...${NC}"
        git stash save "Temporary stash for testing $(date '+%Y-%m-%d %H:%M:%S')"
        return 0
    fi
    return 1
}

# Function to restore uncommitted changes
restore_uncommitted() {
    if [ $1 -eq 0 ]; then
        echo -e "${YELLOW}Restoring uncommitted changes...${NC}"
        git stash pop
    fi
}

# Show welcome message
show_guide "Welcome to Git Workflow Test" "This interactive test will guide you through our git workflow:

1. Creating a feature branch
2. Making changes and committing
3. Syncing changes
4. Creating a pull request
5. Using workspace command

Each step will be explained before execution, and you'll be prompted to continue.
This helps you understand the workflow while testing it works correctly."

# Handle any uncommitted changes
had_changes=1
handle_uncommitted
had_changes=$?

# Ensure development branch exists
show_guide "Branch Setup" "First, we'll ensure the required branches exist:

1. Checking production branch
2. Creating development branch if needed
3. Setting up test environment

This step is usually handled by repository maintainers."

echo -e "${BLUE}Checking required branches...${NC}"
git checkout production || handle_error "Failed to checkout production"
ensure_branch "development"
git checkout production || handle_error "Failed to checkout production"

# Step 1: Create branch
show_guide "Step 1: Creating Feature Branch" "Now we'll create a new feature branch:

1. You'll be prompted to select branch type (feature)
2. Enter branch name (test-feature)
3. Branch will be created with ticket reference

This demonstrates the branch creation workflow."

# Delete existing branch if it exists
cleanup_branch "feature/test-feature"

echo -e "${YELLOW}Creating feature branch...${NC}"
"$ALIASES_DIR/bin/start-branch.sh" -t TEST-123 || handle_error "Failed to create branch"

# Verify branch creation
show_guide "Branch Creation Result" "Let's verify the branch was created correctly:

1. Branch should be named 'feature/test-feature'
2. Ticket TEST-123 should be associated
3. Branch should be checked out

Current branches:"
git branch
pause

# Step 2: Create and commit file
show_guide "Step 2: Making Changes" "Now we'll create and commit changes:

1. Creating a test file
2. Select 'feat' type (for new feature)
3. Enter 'test' as scope
4. Enter 'add test file' as description
5. Add 'Testing commit workflow' as body
6. Choose to push changes

Important: Please select 'feat' type for this test to pass verification."

# Remove any existing test file
rm -f test.txt

# Create and commit test file
echo "test content" > test.txt
git add test.txt
"$ALIASES_DIR/bin/conventional-commit.sh" || handle_error "Failed to create commit"

# Handle push
handle_push "feature/test-feature"

# Verify commit
show_guide "Commit Result" "Let's verify the commit:

1. Should follow conventional commit format
2. Should include ticket reference
3. Should be pushed to remote

Latest commit:"
git log -1
pause

# Step 3: Sync changes
show_guide "Step 3: Syncing Changes" "Now we'll sync our changes:

1. Update from main branch
2. Pull latest changes from remote
3. Push local changes

This demonstrates the sync workflow."

echo -e "${YELLOW}Syncing changes...${NC}"
"$ALIASES_DIR/bin/sync.sh" || handle_error "Failed to sync changes"

# Verify sync
show_guide "Sync Result" "Let's verify the sync:

1. Should be up-to-date with main branch
2. Should be up-to-date with remote
3. Local changes should be pushed

Current status:"
git status
pause

# Step 4: Create PR
show_guide "Step 4: Creating Pull Request" "Now we'll create a pull request:

1. Select target branch (development)
2. Enter PR title
3. Enter PR description
4. PR will be created and opened in browser

Note: This step requires GitHub CLI (gh). If not installed, it will be skipped."

# Check for gh CLI
if ! command -v gh &> /dev/null; then
    handle_error "GitHub CLI (gh) is not installed. Install it with:
    
macOS: brew install gh
Windows: winget install GitHub.cli
Linux: See https://cli.github.com/

After installation:
1. Run: gh auth login
2. Follow the authentication steps"
else
    # Stash any changes before PR creation
    handle_uncommitted
    "$ALIASES_DIR/bin/open-pr.sh" || handle_error "Failed to create PR"
    restore_uncommitted $?

    # Verify PR
    show_guide "Pull Request Result" "Let's verify the PR:

    1. Should be created with correct title
    2. Should target development branch
    3. Should include ticket reference

    Current PRs:"
    gh pr list
    pause
fi

# Step 5: Test workspace command
show_guide "Step 5: Testing Workspace Command" "Now we'll test the workspace command:

1. Save current workspace
2. Make some changes
3. List workspaces
4. Restore saved workspace

This demonstrates the workspace management workflow."

# Save workspace
echo -e "${YELLOW}Saving current workspace...${NC}"
"$ALIASES_DIR/bin/workspace.sh" save test-workspace || handle_error "Failed to save workspace"

# Make some changes
echo "new content" > new_file.txt
git add new_file.txt

# List workspaces
echo -e "${YELLOW}Listing workspaces...${NC}"
"$ALIASES_DIR/bin/workspace.sh" list || handle_error "Failed to list workspaces"

# Restore workspace
echo -e "${YELLOW}Restoring saved workspace...${NC}"
"$ALIASES_DIR/bin/workspace.sh" restore test-workspace || handle_error "Failed to restore workspace"

# Verify workspace restoration
if [[ ! -f new_file.txt ]]; then
    echo -e "${GREEN}Workspace restored successfully!${NC}"
else
    handle_error "Workspace restoration failed"
fi

# Step 6: Run verification
show_guide "Step 6: Verification" "Now we'll verify everything:

1. Branch structure
2. Commit format
3. Ticket references
4. Sync status
5. Workspace functionality

This ensures all parts of the workflow are working correctly."

"$ALIASES_DIR/tests/verify/workflow.sh" || handle_error "Verification failed"

# Cleanup
show_guide "Step 7: Cleanup" "Finally, we'll clean up our test:

1. Delete test branch
2. Restore any stashed changes
3. Return to production branch
4. Remove test workspace

Would you like to clean up (delete test branch locally and remotely)? (Y/n)"
read -n 1 cleanup
echo
if [[ $cleanup =~ ^[Yy]?$ ]]; then
    # Remove test files first
    rm -f test.txt new_file.txt
    cleanup_branch "feature/test-feature"
    # Remove test workspace
    rm -rf "$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)/test-workspace"*
fi

# Restore any stashed changes
restore_uncommitted $had_changes

show_guide "Test Complete" "Interactive workflow test completed successfully!

What we tested:
1. Branch creation ✓
2. Conventional commits ✓
3. Branch synchronization ✓
4. Pull requests (requires gh CLI)
5. Ticket handling ✓
6. Workspace management ✓

You can now use these commands in your daily workflow:
- git start-branch
- git cc (conventional-commit)
- git sync
- git open-pr
- git workspace"
