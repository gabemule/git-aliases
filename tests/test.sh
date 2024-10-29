#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to pause and wait for user
pause() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Function to handle errors
handle_error() {
    echo -e "\n${RED}Error: $1${NC}"
    echo "Would you like to continue? (Y/n)"
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

# Ensure verify.sh is executable
chmod +x verify.sh 2>/dev/null

# Clear screen and show header
clear
echo -e "${BLUE}=== Git Workflow Test ===${NC}"
echo -e "This script will run all commands in sequence.\n"

# Handle any uncommitted changes
had_changes=1
handle_uncommitted
had_changes=$?

# Ensure development branch exists
echo -e "${BLUE}Checking required branches...${NC}"
git checkout production || handle_error "Failed to checkout production"
ensure_branch "development"
git checkout production || handle_error "Failed to checkout production"

# Step 1: Create branch
echo -e "\n${BLUE}Step 1: Creating feature branch${NC}"
echo "You will be prompted to:"
echo "1. Select 'feature' using arrow keys"
echo "2. Enter 'test-feature' as the name"
pause

# Delete existing branch if it exists
cleanup_branch "feature/test-feature"

./start-branch.sh -t TEST-123 || handle_error "Failed to create branch"

# Verify branch creation
echo -e "\n${YELLOW}Verifying branch creation:${NC}"
git branch
pause

# Step 2: Create and commit file
echo -e "\n${BLUE}Step 2: Creating test file and committing${NC}"
echo "You will be prompted to:"
echo "1. Select 'feat' type"
echo "2. Enter 'test' as scope"
echo "3. Enter 'add test file' as description"
echo "4. Enter 'this is a test commit' as body"
echo "5. Select 'N' for breaking change"
echo "6. Select 'Y' to push changes"
pause

echo "test content" > test.txt
git add test.txt
./conventional-commit.sh || handle_error "Failed to create commit"

# Handle push
handle_push "feature/test-feature"

# Verify commit
echo -e "\n${YELLOW}Verifying commit:${NC}"
git log -1
pause

# Step 3: Create PR
echo -e "\n${BLUE}Step 3: Creating Pull Request${NC}"
echo "You will be prompted to:"
echo "1. Select 'development' as target"
echo "2. Enter 'Test PR' as title"
echo "3. Enter 'Testing PR creation' as description"
pause

# Stash any changes before PR creation
handle_uncommitted
./open-pr.sh || handle_error "Failed to create PR"
restore_uncommitted $?

# Verify PR
echo -e "\n${YELLOW}Verifying PR:${NC}"
gh pr list
pause

# Step 4: Run verification
echo -e "\n${BLUE}Step 4: Running verification${NC}"
pause
./verify.sh || handle_error "Verification failed"

# Cleanup
echo -e "\n${BLUE}Step 5: Cleanup${NC}"
echo -e "Would you like to clean up (delete test branch locally and remotely)? (Y/n)"
read -n 1 cleanup
echo
if [[ $cleanup =~ ^[Yy]?$ ]]; then
    cleanup_branch "feature/test-feature"
fi

# Restore any stashed changes
restore_uncommitted $had_changes

echo -e "\n${GREEN}Test sequence complete!${NC}"
