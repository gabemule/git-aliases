#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Git Workflow Test Script ===${NC}"
echo "This script will guide you through testing all commands."
echo "Follow the instructions and verify the results."

echo -e "\n${BLUE}1. Testing start-branch.sh${NC}"
echo "Run the following command:"
echo "$ ./start-branch.sh -t TEST-123"
echo "When prompted:"
echo "1. Select: feature"
echo "2. Enter name: test-feature"
echo "Expected result: New branch 'feature/test-feature' created"
echo "Verify with: git branch"

echo -e "\n${BLUE}2. Testing conventional-commit.sh${NC}"
echo "First, create a test file:"
echo "$ echo 'test content' > test.txt"
echo "$ git add test.txt"
echo "Then commit:"
echo "$ ./conventional-commit.sh"
echo "When prompted:"
echo "1. Select: feat"
echo "2. Enter scope (optional): test"
echo "3. Description: add test file"
echo "4. Body: this is a test commit"
echo "5. Breaking change: N"
echo "6. Push changes: Y"
echo "Expected result: Commit created with [TEST-123] reference"
echo "Verify with: git log -1"

echo -e "\n${BLUE}3. Testing open-pr.sh${NC}"
echo "Run the following command:"
echo "$ ./open-pr.sh"
echo "When prompted:"
echo "1. Select target: development"
echo "2. Enter title: Test PR"
echo "3. Enter description: Testing PR creation"
echo "Expected result: PR created with [TEST-123] in title"
echo "Verify in GitHub UI"

echo -e "\n${BLUE}4. Cleanup${NC}"
echo "After testing, clean up with:"
echo "$ git checkout production"
echo "$ git branch -D feature/test-feature"

echo -e "\n${GREEN}Would you like to start the tests? (Y/n)${NC}"
read -p "> " start

if [[ $start =~ ^[Yy]?$ ]]; then
    echo -e "\n${BLUE}Starting with start-branch.sh...${NC}"
    echo "Run: ./start-branch.sh -t TEST-123"
fi
