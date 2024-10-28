#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to pause and wait for user
pause() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read
}

# Clear screen and show header
clear
echo -e "${BLUE}=== Git Workflow Test ===${NC}"
echo -e "This script will run all commands in sequence.\n"

# Step 1: Create branch
echo -e "${BLUE}Step 1: Creating feature branch${NC}"
echo "You will be prompted to:"
echo "1. Select 'feature' using arrow keys"
echo "2. Enter 'test-feature' as the name"
pause
./start-branch.sh -t TEST-123

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
./conventional-commit.sh

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
./open-pr.sh

# Verify PR
echo -e "\n${YELLOW}Verifying PR:${NC}"
gh pr list
pause

# Step 4: Run verification
echo -e "\n${BLUE}Step 4: Running verification${NC}"
pause
./verify.sh

# Cleanup
echo -e "\n${BLUE}Step 5: Cleanup${NC}"
echo -e "Would you like to clean up (delete test branch)? (Y/n)"
read -n 1 cleanup
echo
if [[ $cleanup =~ ^[Yy]?$ ]]; then
    git checkout production
    git branch -D feature/test-feature
fi

echo -e "\n${GREEN}Test sequence complete!${NC}"
