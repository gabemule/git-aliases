#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
tests_passed=0
total_tests=0

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check for gh CLI
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
        echo -e "${YELLOW}Please install it following the instructions at: https://cli.github.com/${NC}"
        echo
        echo "Quick install commands:"
        echo "  Homebrew (macOS): brew install gh"
        echo "  Windows: winget install GitHub.cli"
        echo "  Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
        echo
        echo "After installation:"
        echo "1. Run: gh auth login"
        echo "2. Follow the authentication steps"
        echo "3. Run this test again"
        exit 1
    fi
    
    # Check gh authentication
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI is not authenticated.${NC}"
        echo -e "${YELLOW}Please run: gh auth login${NC}"
        echo
        echo "Authentication steps:"
        echo "1. Run: gh auth login"
        echo "2. Choose GitHub.com"
        echo "3. Choose HTTPS protocol"
        echo "4. Authenticate with your GitHub credentials"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed!${NC}"
    echo
}

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

# Function to cleanup
cleanup() {
    git checkout production 2>/dev/null
    git branch -D feature/test-pr 2>/dev/null
    git push origin --delete feature/test-pr 2>/dev/null
    rm -rf .github
}

echo -e "${BLUE}=== Testing Open PR Command (Non-Interactive) ===${NC}"

# Check prerequisites first
check_prerequisites

# Setup test branch
cleanup
git checkout -b feature/test-pr
git config branch.feature/test-pr.ticket "TEST-123"

# Create test commit
echo "test" > test.txt
git add test.txt
git commit -m "test: add test file"
git push origin feature/test-pr

# Test 1: Basic PR creation (full command)
check_test "basic PR creation (full command)" \
    "git open-pr -t development --title 'Test PR' --body 'Test description' --no-browser && gh pr list --head feature/test-pr" \
    "\[TEST-123\] Test PR"

# Test 2: Basic PR creation (short alias)
check_test "basic PR creation (short alias)" \
    "git pr -t development --title 'Test PR Alias' --body 'Test description' --no-browser && gh pr list --head feature/test-pr" \
    "\[TEST-123\] Test PR Alias"

# Test 3: Draft PR (full command)
check_test "draft PR (full command)" \
    "git open-pr -t development --title 'Draft PR' --body 'Draft description' --draft --no-browser && gh pr list --head feature/test-pr --draft" \
    "\[TEST-123\] Draft PR"

# Test 4: Draft PR (short alias)
check_test "draft PR (short alias)" \
    "git pr -t development --title 'Draft PR Alias' --body 'Draft description' --draft --no-browser && gh pr list --head feature/test-pr --draft" \
    "\[TEST-123\] Draft PR Alias"

# Test 5: PR with template (full command)
# Create test template
mkdir -p .github
echo "## Description\n\n## Changes\n\n## Testing" > .github/pull_request_template.md
check_test "PR with template (full command)" \
    "git open-pr -t development --title 'Template PR' --no-browser && gh pr view --json body | grep Description" \
    "Description"

# Test 6: PR with template (short alias)
check_test "PR with template (short alias)" \
    "git pr -t development --title 'Template PR Alias' --no-browser && gh pr view --json body | grep Description" \
    "Description"

# Test 7: PR to production (full command)
check_test "PR to production (full command)" \
    "git open-pr -t production --title 'Production PR' --no-browser && gh pr list --head feature/test-pr --base production" \
    "\[TEST-123\] Production PR"

# Test 8: PR to production (short alias)
check_test "PR to production (short alias)" \
    "git pr -t production --title 'Production PR Alias' --no-browser && gh pr list --head feature/test-pr --base production" \
    "\[TEST-123\] Production PR Alias"

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
