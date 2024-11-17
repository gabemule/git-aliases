#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
total_tests=0

# Function to check test result
check_test() {
    local test_name=$1
    local command=$2
    local expected=$3
    
    ((total_tests++))
    echo -n "Testing $test_name... "
    if eval "$command" | grep -q "$expected"; then
        echo -e "${GREEN}PASSED${NC}"
        ((tests_passed++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "Expected to find: $expected"
        echo "Command: $command"
    fi
}

# Function to create test commit
create_test_commit() {
    echo "test" > test.txt
    git add test.txt
}

# Function to cleanup
cleanup() {
    git checkout production 2>/dev/null
    git branch -D feature/test-commits 2>/dev/null
    rm -f test.txt
}

echo -e "${BLUE}=== Testing Conventional Commit Command (Non-Interactive) ===${NC}"

# Setup test branch
cleanup
git checkout -b feature/test-commits
git config branch.feature/test-commits.ticket "TEST-123"

# Test 1: Basic commit with message
create_test_commit
check_test "basic commit with message" \
    "git cc -m 'add test file' --type feat && git log -1 --pretty=%B" \
    "feat: add test file \[TEST-123\]"

# Test 2: Commit with scope
create_test_commit
check_test "commit with scope" \
    "git cc -m 'update test' -s test --type fix && git log -1 --pretty=%B" \
    "fix(test): update test \[TEST-123\]"

# Test 3: Breaking change
create_test_commit
check_test "breaking change" \
    "git cc -m 'change api' -s api -b --type feat && git log -1 --pretty=%B" \
    "feat(api)!: change api \[TEST-123\]"

# Test 4: Override ticket
create_test_commit
check_test "ticket override" \
    "git cc -m 'override ticket' -t TEST-456 --type docs && git log -1 --pretty=%B" \
    "docs: override ticket \[TEST-456\]"

# Test 5: No verify
create_test_commit
check_test "no verify flag" \
    "git cc -m 'skip hooks' --no-verify --type chore && git log -1 --pretty=%B" \
    "chore: skip hooks \[TEST-123\]"

# Test 6: Auto push
# Note: This test assumes remote exists and is accessible
create_test_commit
check_test "auto push" \
    "git cc -m 'test auto push' -p --type test && git log -1 --pretty=%B" \
    "test: test auto push \[TEST-123\]"

# Cleanup
cleanup

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
