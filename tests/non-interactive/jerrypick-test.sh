#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

echo -e "${BLUE}=== Testing Jerrypick Command (Non-Interactive) ===${NC}"

# Test git jerrypick with dry run
run_test "jerrypick with dry run" '
    # Set up test repository
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
    # Use --all flag to select all commits non-interactively
    output=$(git jerrypick --dry-run --all feature-branch)
    
    # Check if dry-run messages are present
    assert_contains "$output" "[DRY-RUN] Would cherry-pick: Add feature"
    assert_contains "$output" "[DRY-RUN] Would cherry-pick: Update feature"
    
    # Check that no actual cherry-pick was performed
    assert_not_contains "$(git log --oneline)" "Add feature"
    assert_not_contains "$(git log --oneline)" "Update feature"
    
    # Clean up
    teardown_test_repo
'

# Test git jerrypick with specific branch
run_test "jerrypick with specific branch" '
    # Set up test repository
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
    # Use --all flag to select all commits non-interactively
    output=$(git jerrypick --all feature-branch)
    
    # Check if cherry-pick was successful
    assert_contains "$output" "Successfully applied selected commits to current branch"
    
    # Check that commits were cherry-picked
    assert_contains "$(git log --oneline)" "Add feature"
    assert_contains "$(git log --oneline)" "Update feature"
    
    # Clean up
    teardown_test_repo
'

# Test git jerrypick with conflicts
run_test "jerrypick with conflicts" '
    # Set up test repository
    setup_test_repo
    
    # Create a feature branch with some commits
    git checkout -b feature-branch
    echo "Feature content" > feature.txt
    git add feature.txt
    git commit -m "Add feature"
    
    # Switch back to main branch and create conflicting changes
    git checkout main
    echo "Conflicting content" > feature.txt
    git add feature.txt
    git commit -m "Add conflicting content"
    
    # Run git jerrypick with feature branch
    # Use --all flag to select all commits non-interactively
    output=$(git jerrypick --all feature-branch)
    
    # Check if conflict message is present
    assert_contains "$output" "Conflict detected"
    assert_contains "$output" "Please resolve conflicts and run '\''git cherry-pick --continue'\''"
    
    # Check that cherry-pick is in progress
    assert_contains "$(git status)" "You are currently cherry-picking"
    
    # Clean up
    teardown_test_repo
'

# Print test summary
print_test_summary
