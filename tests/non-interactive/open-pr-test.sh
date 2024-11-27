#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

# Function to setup test branch
setup_test_branch() {
    # Stash any uncommitted changes
    git stash

    git checkout production
    git pull origin production
    git checkout -b feature/test-pr 2>/dev/null || git checkout feature/test-pr
    git reset --hard origin/production
    git config branch.feature/test-pr.ticket "TEST-123"
    echo "test" > test.txt
    git add test.txt
    git commit -m "test: add test file" --no-verify
    git push -u origin feature/test-pr --force
}

# Function to cleanup
cleanup() {
    git checkout production 2>/dev/null
    git branch -D feature/test-pr 2>/dev/null
    git push origin --delete feature/test-pr 2>/dev/null
    rm -rf .github
    # Pop stashed changes
    git stash pop
}

echo -e "${BLUE}=== Testing Open PR Command (Non-Interactive) ===${NC}"

# Check prerequisites first
check_prerequisites

# Initial setup
cleanup
setup_test_branch

# Test 1: Basic PR creation (full command)
run_test "basic PR creation (full command)" \
    "git open-pr -t development --title 'Test PR' --body 'Test description' --no-browser && gh pr list --head feature/test-pr" \
    "\[TEST-123\] Test PR"

# Test 2: Basic PR creation (short alias)
run_test "basic PR creation (short alias)" \
    "git pr -t development --title 'Test PR Alias' --body 'Test description' --no-browser && gh pr list --head feature/test-pr" \
    "\[TEST-123\] Test PR Alias"

# Test 3: Draft PR (full command)
run_test "draft PR (full command)" \
    "git open-pr -t development --title 'Draft PR' --body 'Draft description' --draft --no-browser && gh pr list --head feature/test-pr --draft" \
    "\[TEST-123\] Draft PR"

# Test 4: Draft PR (short alias)
run_test "draft PR (short alias)" \
    "git pr -t development --title 'Draft PR Alias' --body 'Draft description' --draft --no-browser && gh pr list --head feature/test-pr --draft" \
    "\[TEST-123\] Draft PR Alias"

# Test 5: PR with template (full command)
# Create test template
mkdir -p .github
echo "## Description\n\n## Changes\n\n## Testing" > .github/pull_request_template.md
run_test "PR with template (full command)" \
    "git open-pr -t development --title 'Template PR' --no-browser && gh pr view --json body | grep Description" \
    "Description"

# Test 6: PR with template (short alias)
run_test "PR with template (short alias)" \
    "git pr -t development --title 'Template PR Alias' --no-browser && gh pr view --json body | grep Description" \
    "Description"

# Test 7: PR to production (full command)
run_test "PR to production (full command)" \
    "git open-pr -t production --title 'Production PR' --no-browser && gh pr list --head feature/test-pr --base production" \
    "\[TEST-123\] Production PR"

# Test 8: PR to production (short alias)
run_test "PR to production (short alias)" \
    "git pr -t production --title 'Production PR Alias' --no-browser && gh pr list --head feature/test-pr --base production" \
    "\[TEST-123\] Production PR Alias"

# Final cleanup
cleanup

# Print test summary
print_test_summary
