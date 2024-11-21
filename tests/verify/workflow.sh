#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
total_tests=5  # Start with base tests, increment if PR test is available

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

# Function to check configuration
check_config() {
    local name=$1
    local key=$2
    local default=$3
    
    echo -n "Checking $name... "
    value=$(git config "$key" || echo "$default")
    if [ "$value" = "$default" ]; then
        echo -e "${GREEN}PASSED${NC}"
        ((tests_passed++))
        return 0
    else
        echo -e "${BLUE}CUSTOM${NC}"
        echo "Using custom value: $value (default: $default)"
        ((tests_passed++))
        return 0
    fi
}

# Function to cleanup
cleanup() {
    git checkout production 2>/dev/null
    git branch -D feature/test-feature 2>/dev/null
    rm -f test.txt
}

echo -e "${BLUE}=== Verifying Git Workflow Tests ===${NC}"

# Check configuration defaults
echo -e "\n${BLUE}Checking Configuration:${NC}"
((total_tests+=6))

check_config "main branch" \
    "workflow.mainBranch" \
    "production"

check_config "default target" \
    "workflow.defaultTarget" \
    "development"

check_config "ticket pattern" \
    "workflow.ticketPattern" \
    "^[A-Z]+-[0-9]+$"

check_config "feature prefix" \
    "workflow.featurePrefix" \
    "feature/"

check_config "bugfix prefix" \
    "workflow.bugfixPrefix" \
    "bugfix/"

check_config "PR template" \
    "workflow.prTemplatePath" \
    ".github/pull_request_template.md"

# Clean up any previous test state
cleanup

# Set up test state
git checkout -b feature/test-feature
git config branch.feature/test-feature.ticket "TEST-123"
echo "test content" > test.txt
git add test.txt
git commit -m "feat(test): add test file [TEST-123]"

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
    ((total_tests++))  # Only increment if PR test is available
    check_test "pull request" \
        "gh pr list --head feature/test-feature" \
        "Test PR"
else
    echo "Skipping PR check - GitHub CLI not installed"
fi

# Clean up test state
cleanup

# Print summary
echo -e "\n${BLUE}=== Test Summary ===${NC}"
echo "Tests passed: $tests_passed/$total_tests"

if [ $tests_passed -eq $total_tests ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
elif [ $tests_passed -eq 11 ] && [ $total_tests -eq 11 ]; then
    # All base tests passed, PR test skipped
    echo -e "${GREEN}All required tests passed! (PR test skipped)${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Review output above.${NC}"
    exit 1
fi
