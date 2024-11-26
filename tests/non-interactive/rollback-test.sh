#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

# Test git rollback with dry run
test_rollback_dry_run() {
    setup_test_repo
    
    # Create some commits
    echo "Initial content" > test.txt
    git add test.txt
    git commit -m "Initial commit"
    echo "Updated content" > test.txt
    git add test.txt
    git commit -m "Update content"
    
    # Run git rollback with dry run
    output=$(git rollback --dry-run)
    
    # Check if dry-run message is present
    assert_contains "$output" "[DRY-RUN] Would create branch: rollback/"
    assert_contains "$output" "[DRY-RUN] Would revert commits from"
    
    # Check that no actual rollback branch was created
    assert_not_contains "$(git branch)" "rollback/"
    
    teardown_test_repo
}

# Test git rollback with skip verify
test_rollback_skip_verify() {
    setup_test_repo
    
    # Create some commits
    echo "Initial content" > test.txt
    git add test.txt
    git commit -m "Initial commit"
    echo "Updated content" > test.txt
    git add test.txt
    git commit -m "Update content"
    
    # Run git rollback with skip verify
    output=$(git rollback --skip-verify)
    
    # Check if rollback branch was created
    assert_contains "$output" "Rollback branch created: rollback/"
    
    # Check that verification step was skipped
    assert_not_contains "$output" "Verifying changes..."
    
    teardown_test_repo
}

# Run the tests
run_test test_rollback_dry_run
run_test test_rollback_skip_verify

# Print test summary
print_test_summary
