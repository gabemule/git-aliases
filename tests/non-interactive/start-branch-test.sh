#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
total_tests=0

# Function to check test result with error output
check_test() {
    local test_name=$1
    local command=$2
    local expected=$3
    
    ((total_tests++))
    echo -n "Testing $test_name... "
    
    # Capture both output and exit status
    output=$(eval "$command" 2>&1)
    status=$?
    
    # Check for specific error conditions
    if echo "$output" | grep -q "couldn't find remote ref production"; then
        echo -e "${RED}FAILED${NC}"
        echo "Error: Remote production branch not found"
        echo "Full output: $output"
        return 1
    fi
    
    if echo "$output" | grep -q "error: pathspec 'production'"; then
        echo -e "${RED}FAILED${NC}"
        echo "Error: Local production branch not properly set up"
        echo "Full output: $output"
        return 1
    fi
    
    if [ $status -ne 0 ]; then
        echo -e "${RED}FAILED${NC}"
        echo "Command failed with status $status"
        echo "Full output: $output"
        return 1
    fi
    
    if echo "$output" | grep -q "$expected"; then
        echo -e "${GREEN}PASSED${NC}"
        ((tests_passed++))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "Expected to find: $expected"
        echo "Full output: $output"
        return 1
    fi
}

# Function to verify remote branch
verify_remote_branch() {
    local branch=$1
    if ! git ls-remote --heads origin "$branch" | grep -q "$branch"; then
        echo -e "${RED}Error: Branch '$branch' not found in remote${NC}"
        return 1
    fi
    return 0
}

# Function to cleanup branches
cleanup_branch() {
    local branch=$1
    git checkout production 2>/dev/null
    git branch -D $branch 2>/dev/null
}

echo -e "${BLUE}=== Testing Start Branch Command (Non-Interactive) ===${NC}"

# Verify production branch setup
echo -e "\n${BLUE}Verifying branch setup...${NC}"
if ! verify_remote_branch "production"; then
    echo -e "${RED}Tests cannot proceed: production branch not properly set up in remote${NC}"
    exit 1
fi

# Test 1: Basic branch creation with all flags
cleanup_branch "feature/test-flags"
check_test "branch creation with flags" \
    "git start-branch -t TEST-123 -n test-flags -b feature && git branch --show-current" \
    "feature/test-flags"

# Test 2: Verify ticket storage
check_test "ticket storage" \
    "git config branch.feature/test-flags.ticket" \
    "TEST-123"

# Test 3: Create from current branch
cleanup_branch "feature/from-current"
git checkout -b base-branch
check_test "branch from current" \
    "git start-branch -t TEST-456 -n from-current -b feature --current && git rev-parse --abbrev-ref HEAD" \
    "feature/from-current"

# Test 4: No sync option
cleanup_branch "feature/no-sync"
check_test "no sync option" \
    "git start-branch -t TEST-789 -n no-sync -b feature --no-sync && git branch --show-current" \
    "feature/no-sync"

# Test 5: No stash option
cleanup_branch "feature/no-stash"
echo "test" > test.txt
check_test "no stash option" \
    "git start-branch -t TEST-012 -n no-stash -b feature --no-stash && git status --porcelain" \
    "?? test.txt"

# Test 6: Short alias
cleanup_branch "feature/short-alias"
check_test "short alias" \
    "git start -t TEST-345 -n short-alias -b feature && git branch --show-current" \
    "feature/short-alias"

# Cleanup
cleanup_branch "feature/test-flags"
cleanup_branch "feature/from-current"
cleanup_branch "feature/no-sync"
cleanup_branch "feature/no-stash"
cleanup_branch "feature/short-alias"
cleanup_branch "base-branch"
rm -f test.txt

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