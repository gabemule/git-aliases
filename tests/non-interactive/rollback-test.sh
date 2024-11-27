#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

echo -e "${BLUE}=== Testing Rollback Command (Non-Interactive) ===${NC}"

# Test git rollback with dry run
run_test "rollback with dry run" '
    # Set up test repository
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
    
    # Clean up
    teardown_test_repo
'

# Test git rollback with skip verify
run_test "rollback with skip verify" '
    # Set up test repository
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
    
    # Clean up
    teardown_test_repo
'

# Test git rollback creates a rollback branch
run_test "rollback creates a branch" '
    # Set up test repository
    setup_test_repo
    
    # Create some commits
    echo "Initial content" > test.txt
    git add test.txt
    git commit -m "Initial commit"
    echo "Updated content" > test.txt
    git add test.txt
    git commit -m "Update content"
    
    # Run git rollback
    output=$(echo "y" | git rollback)
    
    # Check if rollback branch was created
    assert_contains "$output" "Rollback branch created: rollback/"
    
    # Check that the rollback branch exists
    assert_contains "$(git branch)" "rollback/"
    
    # Clean up
    teardown_test_repo
'

# Print test summary
print_test_summary
