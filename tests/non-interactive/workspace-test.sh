#!/bin/bash

# Source test utilities
source "$(dirname "$0")/../test-utils.sh"

# Test git workspace save
test_workspace_save() {
    setup_test_repo
    
    # Create some changes
    echo "Test content" > test.txt
    git add test.txt
    echo "Unstaged content" > unstaged.txt
    
    # Save workspace
    output=$(git workspace save test-workspace)
    
    # Check if workspace was saved
    assert_contains "$output" "Workspace 'test-workspace' saved"
    
    # Check if workspace files were created
    assert_file_exists "$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)/test-workspace.branch"
    assert_file_exists "$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)/test-workspace.staged"
    assert_file_exists "$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)/test-workspace.unstaged"
    assert_file_exists "$HOME/.git-workspaces/$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)/test-workspace.untracked.tar.gz"
    
    teardown_test_repo
}

# Test git workspace restore
test_workspace_restore() {
    setup_test_repo
    
    # Create and save a workspace
    echo "Test content" > test.txt
    git add test.txt
    echo "Unstaged content" > unstaged.txt
    git workspace save test-workspace
    
    # Clear the working directory
    git reset --hard
    rm unstaged.txt
    
    # Restore workspace
    output=$(git workspace restore test-workspace)
    
    # Check if workspace was restored
    assert_contains "$output" "Workspace 'test-workspace' restored"
    
    # Check if files were restored
    assert_file_contains "test.txt" "Test content"
    assert_file_contains "unstaged.txt" "Unstaged content"
    assert_contains "$(git status --porcelain)" "A  test.txt"
    assert_contains "$(git status --porcelain)" "?? unstaged.txt"
    
    teardown_test_repo
}

# Test git workspace list
test_workspace_list() {
    setup_test_repo
    
    # Create some workspaces
    git workspace save workspace1
    git workspace save workspace2
    
    # List workspaces
    output=$(git workspace list)
    
    # Check if workspaces are listed
    assert_contains "$output" "workspace1"
    assert_contains "$output" "workspace2"
    
    teardown_test_repo
}

# Run the tests
run_test test_workspace_save
run_test test_workspace_restore
run_test test_workspace_list

# Print test summary
print_test_summary
