#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
total_tests=6

# Function to check test result
check_test() {
    local test_name=$1
    local command=$2
    local expected=$3
    
    echo -n "Checking $test_name... "
    if eval "$command" | grep -q "$expected"; then
        echo -e "${GREEN}PASSED${NC}"
        ((tests_passed++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "Expected to find: $expected"
        echo "Run '$command' to see actual output"
    fi
}

echo -e "${BLUE}=== Verifying Git Workflow Tests ===${NC}"

# 1. Check if branch exists and has correct name
check_test "branch creation" \
    "git branch" \
    "feature/test-feature"

# 2. Check if ticket is stored in branch config
check_test "ticket storage" \
    "git config branch.feature/test-feature.ticket" \
    "TEST-123"

# 3. Check if test file exists
check_test "test file creation" \
    "git ls-files" \
    "test.txt"

# 4. Check commit message format
check_test "commit message" \
    "git log -1 --pretty=%B" \
    "\[TEST-123\]"

# 5. Check if commit follows conventional format
check_test "conventional commit" \
    "git log -1 --pretty=%B" \
    "^feat(test): "

# 6. Check if PR exists (if gh CLI is available)
if command -v gh &> /dev/null; then
    check_test "pull request" \
        "gh pr list --head feature/test-feature" \
        "Test PR"
else
    echo "Skipping PR check - GitHub CLI not installed"
fi

# Print summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo "Tests passed: $tests_passed/$total_tests"

if [ $tests_passed -eq $total_tests ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Review output above.${NC}"
    exit 1
fi
