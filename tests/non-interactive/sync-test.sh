#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

echo -e "${BLUE}=== Testing Sync Command (Non-Interactive) ===${NC}"

# Test git sync with no arguments
run_test "sync with no arguments" '
    # Set up test repository
    setup_test_repo
    
    # Create a feature branch
    git checkout -b feature/test
    
    # Make some changes
    echo "Test content" > test.txt
    git add test.txt
    git commit -m "Add test.txt"
    
    # Run git sync
    output=$(git sync)
    
    # Check if the sync was successful
    assert_contains "$output" "Branch successfully synchronized!"
    
    # Check if the changes were pushed
    assert_contains "$(git log origin/feature/test)" "Add test.txt"
    
    # Clean up
    teardown_test_repo
'

# Test git sync --no-push
run_test "sync with --no-push" '
    # Set up test repository
    setup_test_repo
    
    # Create a feature branch
    git checkout -b feature/test
    
    # Make some changes
    echo "Test content" > test.txt
    git add test.txt
    git commit -m "Add test.txt"
    
    # Run git sync --no-push
    output=$(git sync --no-push)
    
    # Check if the sync was successful
    assert_contains "$output" "Branch successfully synchronized!"
    
    # Check if the changes were not pushed
    assert_not_contains "$(git log origin/feature/test 2>/dev/null)" "Add test.txt"
    
    # Clean up
    teardown_test_repo
'

# Test git sync --dry-run
run_test "sync with --dry-run" '
    # Set up test repository
    setup_test_repo
    
    # Create a feature branch
    git checkout -b feature/test
    
    # Make some changes
    echo "Test content" > test.txt
    git add test.txt
    git commit -m "Add test.txt"
    
    # Run git sync --dry-run
    output=$(git sync --dry-run)
    
    # Check if dry-run message is present
    assert_contains "$output" "[DRY-RUN]"
    
    # Check if the changes were not pushed
    assert_not_contains "$(git log origin/feature/test 2>/dev/null)" "Add test.txt"
    
    # Clean up
    teardown_test_repo
'

# Print test summary
print_test_summary
