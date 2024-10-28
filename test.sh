#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counter
tests_run=0
tests_passed=0

# Function to run a test
run_test() {
    local test_name=$1
    local command=$2
    local expected_pattern=$3
    
    ((tests_run++))
    echo -n "Testing $test_name... "
    
    # Run command and capture output
    output=$(eval "$command" 2>&1)
    
    # Check if output matches expected pattern
    if echo "$output" | grep -q "$expected_pattern"; then
        echo -e "${GREEN}PASSED${NC}"
        ((tests_passed++))
    else
        echo -e "${RED}FAILED${NC}"
        echo "Expected pattern: $expected_pattern"
        echo "Got output: $output"
    fi
}

# Clean up function
cleanup() {
    echo "Cleaning up test environment..."
    git checkout production 2>/dev/null
    git branch | grep "test/" | xargs git branch -D 2>/dev/null
    git config --remove-section branch.test/feature 2>/dev/null
}

# Setup test environment
echo "Setting up test environment..."
cleanup

# Test 1: start-branch.sh
echo -e "\nTesting branch creation:"
run_test "Branch creation" \
    "./start-branch.sh -t TEST-123 <<< $'feature\ntest-feature'" \
    "Successfully created.*test-feature"

# Test 2: Verify ticket storage
echo -e "\nTesting ticket storage:"
run_test "Ticket storage" \
    "git config branch.feature/test-feature.ticket" \
    "TEST-123"

# Test 3: conventional-commit.sh
echo -e "\nTesting commit creation:"
# Create a test file
echo "test content" > test.txt
git add test.txt

run_test "Commit creation" \
    "./conventional-commit.sh <<< $'feat\n\ntest commit\n\nn'" \
    "\[TEST-123\]"

# Test 4: Verify commit message
echo -e "\nTesting commit message:"
run_test "Commit message format" \
    "git log -1 --pretty=%B" \
    "feat: test commit \[TEST-123\]"

# Test 5: open-pr.sh (mock test since we can't create actual PRs in test)
echo -e "\nTesting PR creation setup:"
run_test "PR preparation" \
    "git branch --show-current" \
    "feature/test-feature"

# Print test summary
echo -e "\nTest Summary:"
echo "Tests run: $tests_run"
echo "Tests passed: $tests_passed"
echo "Tests failed: $((tests_run - tests_passed))"

# Cleanup
cleanup

if [ $tests_passed -eq $tests_run ]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed!${NC}"
    exit 1
fi
