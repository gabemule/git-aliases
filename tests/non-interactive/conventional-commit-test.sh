#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

# Function to cleanup
cleanup() {
    git checkout production 2>/dev/null
    git branch -D feature/test-commits 2>/dev/null
    git push origin --delete feature/test-commits 2>/dev/null
    rm -f test.txt
}

# Create test file for each test to ensure we have changes to commit
create_test_file() {
    echo "test content $1" > test.txt
    git add test.txt
}

# Function to setup test branch
setup_test_branch() {
    cleanup
    git checkout -b feature/test-commits
    git config branch.feature/test-commits.ticket "TEST-123"
    git push -u origin feature/test-commits
}

echo -e "${BLUE}=== Testing Conventional Commit Command (Non-Interactive) ===${NC}"

# Setup test branch
setup_test_branch

# Test 1: Basic commit with message and type
create_test_file "1"
run_test "basic commit with message and type" \
    "git cc -m 'add test file' --type feat --no-scope --non-interactive && git log -1 --pretty=%B" \
    "feat: add test file \[TEST-123\]"

# Test 2: Commit with explicit scope
create_test_file "2"
run_test "commit with scope" \
    "git cc -m 'update test' -s test --type fix --non-interactive && git log -1 --pretty=%B" \
    "fix(test): update test \[TEST-123\]"

# Test 3: Commit with no scope
create_test_file "3"
run_test "commit without scope" \
    "git cc -m 'simple update' --type docs --no-scope --non-interactive && git log -1 --pretty=%B" \
    "docs: simple update \[TEST-123\]"

# Test 4: Breaking change with scope
create_test_file "4"
run_test "breaking change with scope" \
    "git cc -m 'change api' -s api -b --type feat --non-interactive && git log -1 --pretty=%B" \
    "feat(api)!: change api \[TEST-123\]"

# Test 5: Breaking change without scope
create_test_file "5"
run_test "breaking change without scope" \
    "git cc -m 'major change' -b --type feat --no-scope --non-interactive && git log -1 --pretty=%B" \
    "feat!: major change \[TEST-123\]"

# Test 6: Override ticket with scope
create_test_file "6"
run_test "ticket override with scope" \
    "git cc -m 'override ticket' -t TEST-456 --type docs -s readme --non-interactive && git log -1 --pretty=%B" \
    "docs(readme): override ticket \[TEST-456\]"

# Test 7: Override ticket without scope
create_test_file "7"
run_test "ticket override without scope" \
    "git cc -m 'override ticket' -t TEST-456 --type docs --no-scope --non-interactive && git log -1 --pretty=%B" \
    "docs: override ticket \[TEST-456\]"

# Test 8: No verify with scope
create_test_file "8"
run_test "no verify with scope" \
    "git cc -m 'skip hooks' --no-verify --type chore -s deps --non-interactive && git log -1 --pretty=%B" \
    "chore(deps): skip hooks \[TEST-123\]"

# Test 9: Auto push without scope
create_test_file "9"
run_test "auto push without scope" \
    "git cc -m 'test auto push' -p --type test --no-scope --non-interactive && git log -1 --pretty=%B && git push" \
    "test: test auto push \[TEST-123\]"

# Cleanup
cleanup

# Print test summary
print_test_summary
