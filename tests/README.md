# Git Workflow Test Suite 🧪

## Overview

This test suite provides comprehensive testing for the git workflow commands, covering both interactive workflows and non-interactive features.

## Prerequisites

### GitHub CLI
Some tests (open-pr) require GitHub CLI:
```bash
# Install
brew install gh  # macOS
winget install GitHub.cli  # Windows

# Authenticate
gh auth login
```

## Directory Structure

```
tests/
├── interactive/           # Interactive workflow tests
│   └── workflow-test.sh  # Full workflow with user interaction
├── non-interactive/      # Non-interactive feature tests
│   ├── start-branch-test.sh
│   ├── conventional-commit-test.sh
│   ├── open-pr-test.sh
│   └── sync-test.sh
├── verify/               # Setup and verification tests
│   ├── installation.sh
│   └── workflow.sh
└── run-tests.sh         # Main test runner
```

## Running Tests

### Basic Usage

```bash
# Run all tests
./tests/run-tests.sh -a

# Run specific test suites
./tests/run-tests.sh -i  # Interactive tests
./tests/run-tests.sh -n  # Non-interactive tests
./tests/run-tests.sh -v  # Verification tests
```

### Options

- `-i, --interactive` - Run interactive workflow tests
- `-n, --non-interactive` - Run non-interactive flag tests
- `-v, --verify` - Run verification tests
- `-a, --all` - Run all tests
- `-h` - Show help message

## Test Types

### Interactive Tests
Located in `tests/interactive/`, these tests:
- Simulate real user workflows
- Require user interaction
- Test command integration
- Verify full feature workflows

### Non-Interactive Tests
Located in `tests/non-interactive/`, these tests:
- Test command flags and options
- Run automatically without user input
- Verify individual features
- Check error handling

### Verification Tests
Located in `tests/verify/`, these tests:
- Check installation setup
- Verify basic functionality
- Ensure environment configuration
- Test core workflows

## Test Coverage

### start-branch
- Branch creation
- Ticket storage
- Branch types
- Source control
- Sync options

### conventional-commit
- Commit types
- Scope handling
- Breaking changes
- Ticket references
- Auto-push
- Non-interactive mode

### open-pr
- PR creation
- Draft PRs
- Templates
- Target branches
- Browser control
- GitHub CLI integration

### sync
- Branch synchronization
- Main branch update
- Remote sync
- Conflict handling
- Dry-run mode
- Stash management

## Adding New Tests

### 1. Interactive Tests
Add new workflow tests to `tests/interactive/`:
```bash
#!/bin/bash
# Include common functions
source tests/common/functions.sh

# Add test steps
echo "Step 1: ..."
pause

# Add verification
check_test "test name" "command" "expected"
```

### 2. Non-Interactive Tests
Add new feature tests to `tests/non-interactive/`:
```bash
#!/bin/bash
# Include common functions
source tests/common/functions.sh

# Add test cases
check_test "feature test" "command" "expected"

# Add cleanup
cleanup() {
    # Cleanup code
}
```

### 3. Test Functions

Common test functions available:
```bash
# Check test result
check_test "test name" "command" "expected"

# Handle errors
handle_error "error message"

# Cleanup resources
cleanup "resource name"

# Pause for user
pause "message"
```

## Best Practices

1. **Test Organization**
   - Keep tests focused and atomic
   - Use descriptive test names
   - Include proper cleanup
   - Handle errors gracefully

2. **Test Coverage**
   - Test both success and failure cases
   - Include edge cases
   - Verify all command options
   - Test integration points

3. **Test Output**
   - Use clear, formatted output
   - Include helpful error messages
   - Show test progress
   - Provide summary results

4. **Test Maintenance**
   - Keep tests independent
   - Use common functions
   - Document test purposes
   - Clean up test resources

## Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Make test files executable
   chmod +x tests/**/*.sh
   ```

2. **Git Not Found**
   ```bash
   # Verify git installation
   ./tests/verify/installation.sh
   ```

3. **GitHub CLI Not Found**
   ```bash
   # Install GitHub CLI
   brew install gh
   
   # Authenticate
   gh auth login
   ```

4. **Test Failures**
   ```bash
   # Run verification tests
   ./tests/run-tests.sh -v
   
   # Check test output
   ./tests/run-tests.sh -n --verbose
   ```

### Getting Help

1. Run tests with verbose output:
   ```bash
   ./tests/run-tests.sh -a --verbose
   ```

2. Check individual test files:
   ```bash
   ./tests/non-interactive/start-branch-test.sh
   ```

3. Review test documentation:
   ```bash
   less tests/README.md
