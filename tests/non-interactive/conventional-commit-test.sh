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
    
    # Capture both output and exit status
    output=$(eval "$command" 2>&1)
    status=$?
    
    if [ $status -ne 0 ] && [[ ! "$output" =~ "failed to push" ]]; then
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

# Create test file for each test to ensure we have changes to commit
create_test_file() {
    echo "test content $1" > test.txt
    git add test.txt
}

# Test 1: Basic commit with message and type
create_test_file "1"
check_test "basic commit with message and type" \
    "git cc -m 'add test file' --type feat --no-scope --non-interactive" \
    "feat: add test file \[TEST-123\]"

# Test 2: Commit with explicit scope
create_test_file "2"
check_test "commit with scope" \
    "git cc -m 'update test' -s test --type fix --non-interactive" \
    "fix(test): update test \[TEST-123\]"

# Test 3: Commit with no scope
create_test_file "3"
check_test "commit without scope" \
    "git cc -m 'simple update' --type docs --no-scope --non-interactive" \
    "docs: simple update \[TEST-123\]"

# Test 4: Breaking change with scope
create_test_file "4"
check_test "breaking change with scope" \
    "git cc -m 'change api' -s api -b --type feat --non-interactive" \
    "feat(api)!: change api \[TEST-123\]"

# Test 5: Breaking change without scope
create_test_file "5"
check_test "breaking change without scope" \
    "git cc -m 'major change' -b --type feat --no-scope --non-interactive" \
    "feat!: major change \[TEST-123\]"

# Test 6: Override ticket with scope
create_test_file "6"
check_test "ticket override with scope" \
    "git cc -m 'override ticket' -t TEST-456 --type docs -s readme --non-interactive" \
    "docs(readme): override ticket \[TEST-456\]"

# Test 7: Override ticket without scope
create_test_file "7"
check_test "ticket override without scope" \
    "git cc -m 'override ticket' -t TEST-456 --type docs --no-scope --non-interactive" \
    "docs: override ticket \[TEST-456\]"

# Test 8: No verify with scope
create_test_file "8"
check_test "no verify with scope" \
    "git cc -m 'skip hooks' --no-verify --type chore -s deps --non-interactive" \
    "chore(deps): skip hooks \[TEST-123\]"

# Test 9: Auto push without scope (only verify commit message, ignore push result)
create_test_file "9"
check_test "auto push without scope" \
    "git cc -m 'test auto push' -p --type test --no-scope --non-interactive" \
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
