#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

echo -e "${BLUE}=== Testing Start Branch Command (Non-Interactive) ===${NC}"

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

# Verify production branch setup
echo -e "\n${BLUE}Verifying branch setup...${NC}"
if ! verify_remote_branch "production"; then
    echo -e "${RED}Tests cannot proceed: production branch not properly set up in remote${NC}"
    exit 1
fi

# Test 1: Basic branch creation with all flags
run_test "branch creation with flags" '
    cleanup_branch "feature/test-flags"
    output=$(git start-branch -t TEST-123 -n test-flags -b feature && git branch --show-current)
    assert_contains "$output" "feature/test-flags"
'

# Test 2: Verify ticket storage
run_test "ticket storage" '
    output=$(git config branch.feature/test-flags.ticket)
    assert_contains "$output" "TEST-123"
'

# Test 3: Create from current branch
run_test "branch from current" '
    cleanup_branch "feature/from-current"
    git checkout -b base-branch
    output=$(git start-branch -t TEST-456 -n from-current -b feature --current && git rev-parse --abbrev-ref HEAD)
    assert_contains "$output" "feature/from-current"
'

# Test 4: No sync option
run_test "no sync option" '
    cleanup_branch "feature/no-sync"
    output=$(git start-branch -t TEST-789 -n no-sync -b feature --no-sync && git branch --show-current)
    assert_contains "$output" "feature/no-sync"
'

# Test 5: No stash option
run_test "no stash option" '
    cleanup_branch "feature/no-stash"
    echo "test" > test.txt
    output=$(git start-branch -t TEST-012 -n no-stash -b feature --no-stash && git status --porcelain)
    assert_contains "$output" "?? test.txt"
'

# Test 6: Short alias
run_test "short alias" '
    cleanup_branch "feature/short-alias"
    output=$(git start -t TEST-345 -n short-alias -b feature && git branch --show-current)
    assert_contains "$output" "feature/short-alias"
'

# Cleanup
cleanup_branch "feature/test-flags"
cleanup_branch "feature/from-current"
cleanup_branch "feature/no-sync"
cleanup_branch "feature/no-stash"
cleanup_branch "feature/short-alias"
cleanup_branch "base-branch"
rm -f test.txt

# Print test summary
print_test_summary
