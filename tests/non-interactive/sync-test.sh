#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

# Test git sync with no arguments
test_sync_no_args() {
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
    
    teardown_test_repo
}

# Test git sync --no-push
test_sync_no_push() {
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
    
    teardown_test_repo
}

# Test git sync --dry-run
test_sync_dry_run() {
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
    
    teardown_test_repo
}

# Run the tests
run_test test_sync_no_args
run_test test_sync_no_push
run_test test_sync_dry_run

# Print test summary
print_test_summary
