# Non-Interactive Tests 🤖

## Overview

Non-interactive tests verify command flags and options that can be used in scripts and CI/CD pipelines. These tests run automatically without user input.

## Available Tests

### start-branch-test.sh
Tests branch creation commands and flags:
- Full command: `git start-branch`
- Short alias: `git start`
- Flags:
  - `-n, --name` - Branch name
  - `-b, --branch-type` - Branch type
  - `--current` - Use current branch
  - `--no-sync` - Skip sync
  - `--no-stash` - Skip stash

### conventional-commit-test.sh
Tests commit creation flags:
- Command: `git cc`
- Flags:
  - `-m, --message` - Commit message
  - `-s, --scope` - Commit scope
  - `-b, --breaking` - Breaking change
  - `-p, --push` - Auto push
  - `--no-verify` - Skip hooks

### open-pr-test.sh
Tests PR creation commands and flags:
- Full command: `git open-pr`
- Short alias: `git pr`
- Flags:
  - `-t, --target` - Target branch
  - `--title` - PR title
  - `--body` - PR description
  - `--draft` - Draft PR
  - `--no-browser` - Skip browser

## Running Tests

```bash
# Run all non-interactive tests
./tests/run-tests.sh -n

# Run specific test
./tests/non-interactive/start-branch-test.sh
./tests/non-interactive/conventional-commit-test.sh
./tests/non-interactive/open-pr-test.sh
```

## Test Structure

Each test file follows this structure:

```bash
#!/bin/bash

# Initialize counters
tests_passed=0
total_tests=0

# Test helper functions
check_test() {
    local test_name=$1
    local command=$2
    local expected=$3
    # Test implementation
}

cleanup() {
    # Cleanup resources
}

# Test both full commands and aliases where applicable
check_test "full command test" "git start-branch ..." "expected"
check_test "short alias test" "git start ..." "expected"

# Cleanup
cleanup

# Summary
echo "Tests passed: $tests_passed/$total_tests"
```

## Adding New Tests

1. Create new test file:
   ```bash
   touch tests/non-interactive/new-feature-test.sh
   chmod +x tests/non-interactive/new-feature-test.sh
   ```

2. Implement test structure:
   ```bash
   #!/bin/bash
   
   # Initialize
   tests_passed=0
   total_tests=0
   
   # Test both command forms if applicable
   check_test "full command" "git command ..." "expected"
   check_test "short alias" "git alias ..." "expected"
   
   # Add cleanup
   cleanup
   ```

3. Add to test runner:
   ```bash
   # Update tests/run-tests.sh
   non_interactive_tests+=(tests/non-interactive/new-feature-test.sh)
   ```

## Best Practices

1. **Test Organization**
   - One test file per command
   - Test both full commands and aliases
   - Clear test case names
   - Proper cleanup after tests

2. **Test Coverage**
   - Test all flag combinations
   - Test both command forms
   - Include error cases
   - Verify expected output

3. **Test Maintenance**
   - Use common functions
   - Clean up resources
   - Handle errors gracefully
   - Document test cases

## Troubleshooting

### Common Issues

1. **Test Failures**
   ```bash
   # Run with debug output
   VERBOSE=1 ./tests/non-interactive/start-branch-test.sh
   ```

2. **Cleanup Issues**
   ```bash
   # Manual cleanup
   git checkout production
   git branch -D test-branch
   rm -f test.txt
   ```

3. **Permission Issues**
   ```bash
   # Fix permissions
   chmod +x tests/non-interactive/*.sh
   ```

### Getting Help

1. Check test output:
   ```bash
   ./tests/non-interactive/test.sh --verbose
   ```

2. Review test cases:
   ```bash
   less tests/non-interactive/test.sh
   ```

3. Run verification:
   ```bash
   ./tests/verify/installation.sh
