#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

# Test git jerrypick with dry run
test_jerrypick_dry_run() {
    setup_test_repo
    
    # Create a feature branch with some commits
    git checkout -b feature-branch
    echo "Feature content" > feature.txt
    git add feature.txt
    git commit -m "Add feature"
    echo "More feature content" >> feature.txt
    git add feature.txt
    git commit -m "Update feature"
    
    # Switch back to main branch
    git checkout main
    
    # Run git jerrypick with dry run
    output=$(git jerrypick --dry-run feature-branch)
    
    # Check if dry-run messages are present
    assert_contains "$output" "[DRY-RUN] Would cherry-pick: Add feature"
    assert_contains "$output" "[DRY-RUN] Would cherry-pick: Update feature"
    
    # Check that no actual cherry-pick was performed
    assert_not_contains "$(git log --oneline)" "Add feature"
    assert_not_contains "$(git log --oneline)" "Update feature"
    
    teardown_test_repo
}

# Test git jerrypick with specific branch
test_jerrypick_specific_branch() {
    setup_test_repo
    
    # Create a feature branch with some commits
    git checkout -b feature-branch
    echo "Feature content" > feature.txt
    git add feature.txt
    git commit -m "Add feature"
    echo "More feature content" >> feature.txt
    git add feature.txt
    git commit -m "Update feature"
    
    # Switch back to main branch
    git checkout main
    
    # Run git jerrypick with specific branch
    output=$(echo -e "\n\n" | git jerrypick feature-branch)
    
    # Check if cherry-pick was successful
    assert_contains "$output" "Successfully applied selected commits to current branch"
    
    # Check that commits were cherry-picked
    assert_contains "$(git log --oneline)" "Add feature"
    assert_contains "$(git log --oneline)" "Update feature"
    
    teardown_test_repo
}

# Run the tests
run_test test_jerrypick_dry_run
run_test test_jerrypick_specific_branch

# Print test summary
print_test_summary
