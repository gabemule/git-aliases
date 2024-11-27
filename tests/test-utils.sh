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

run_test() {
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

print_test_summary() {
    echo -e "\n${BLUE}=== Test Summary ===${NC}"
    echo "Tests passed: $tests_passed/$total_tests"

    if [ $tests_passed -eq $total_tests ]; then
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}Some tests failed. Review output above.${NC}"
        exit 1
    fi
}

setup_test_repo() {
    # Create a temporary directory for the test repository
    test_repo=$(mktemp -d)
    cd "$test_repo"
    
    # Initialize a new git repository
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create an initial commit
    echo "Initial content" > README.md
    git add README.md
    git commit -m "Initial commit"
}

teardown_test_repo() {
    # Clean up the temporary test repository
    cd ..
    rm -rf "$test_repo"
}

check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    
    # Check for gh CLI
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI (gh) is not installed.${NC}"
        echo -e "${YELLOW}Please install it following the instructions at: https://cli.github.com/${NC}"
        exit 1
    fi
    
    # Check gh authentication
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}Error: GitHub CLI is not authenticated.${NC}"
        echo -e "${YELLOW}Please run: gh auth login${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Prerequisites check passed!${NC}"
    echo
}

assert_contains() {
    if ! echo "$1" | grep -q "$2"; then
        echo -e "${RED}FAILED${NC}"
        echo "Expected to find: $2"
        echo "Actual output: $1"
        return 1
    fi
}

assert_not_contains() {
    if echo "$1" | grep -q "$2"; then
        echo -e "${RED}FAILED${NC}"
        echo "Expected not to find: $2"
        echo "Actual output: $1"
        return 1
    fi
}
