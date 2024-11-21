# 🧪 Testing Guide

ChronoGit includes comprehensive testing to ensure reliability.

## Quick Start

```bash
# Run all tests
git test -a

# Run specific tests
git test  # Shows menu:
1) Interactive workflow tests
2) Non-interactive flag tests
3) Verification tests
4) All tests
5) Exit
```

## Test Types

### 1. Interactive Tests

Tests that simulate user workflows:

```bash
# Run interactive tests
git test -i

# Example workflow:
1. Create branch
2. Make commits
3. Create PR
```

### 2. Non-interactive Tests

Tests command flags and options:

```bash
# Run non-interactive tests
git test -n

# Tests:
- start-branch flags
- conventional-commit flags
- open-pr flags
```

### 3. Verification Tests

Tests installation and setup:

```bash
# Run verification tests
git test -v

# Checks:
- Git installation
- Script permissions
- Configuration
```

## Test Structure

```
tests/
├── interactive/           # Interactive workflow tests
│   └── workflow-test.sh  # Full workflow with user interaction
├── non-interactive/      # Non-interactive feature tests
│   ├── start-branch-test.sh
│   ├── conventional-commit-test.sh
│   └── open-pr-test.sh
├── verify/               # Setup and verification tests
│   ├── installation.sh
│   └── workflow.sh
└── run-tests.sh         # Main test runner
```

## Running Tests

### All Tests

```bash
# Run everything
git test -a

# Output:
=== Running Verification Tests ===
=== Running Non-Interactive Tests ===
=== Running Interactive Tests ===
```

### Specific Tests

```bash
# Interactive only
git test -i

# Non-interactive only
git test -n

# Verification only
git test -v
```

### Test Menu

```bash
git test

Select tests to run:
1) Interactive workflow tests
2) Non-interactive flag tests
3) Verification tests
4) All tests
5) Exit
```

## Writing Tests

### Test Functions

```bash
# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Check test result
check_test() {
    local test_name=$1
    local command=$2
    local expected=$3
    
    echo -n "Testing $test_name... "
    if eval "$command" | grep -q "$expected"; then
        echo -e "${GREEN}PASSED${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# Example usage
check_test "branch creation" \
    "git branch" \
    "feature/test"
```

### Test Structure

```bash
#!/bin/bash

# Initialize counters
tests_passed=0
total_tests=0

# Run tests
check_test "test name" "command" "expected"
((total_tests++))
if [ $? -eq 0 ]; then
    ((tests_passed++))
fi

# Print summary
echo "Tests passed: $tests_passed/$total_tests"
```

## Adding Tests

### 1. Interactive Tests

Create in `tests/interactive/`:

```bash
# New test file
touch tests/interactive/new-workflow.sh

# Test structure
#!/bin/bash
source ../common/functions.sh

# Test steps
show_step "Step 1"
run_command "git start-branch"
verify_result "branch exists"

# Add to runner
interactive_tests+=(tests/interactive/new-workflow.sh)
```

### 2. Non-interactive Tests

Create in `tests/non-interactive/`:

```bash
# New test file
touch tests/non-interactive/new-feature.sh

# Test structure
#!/bin/bash
source ../common/functions.sh

# Test cases
test_flag_behavior
test_error_handling
test_edge_cases

# Add to runner
non_interactive_tests+=(tests/non-interactive/new-feature.sh)
```

### 3. Verification Tests

Create in `tests/verify/`:

```bash
# New test file
touch tests/verify/new-check.sh

# Test structure
#!/bin/bash
source ../common/functions.sh

# Verification checks
verify_installation
verify_configuration
verify_permissions

# Add to runner
verify_tests+=(tests/verify/new-check.sh)
```

## Best Practices

### 1. Test Organization

- Group related tests
- Clear test names
- Descriptive messages

### 2. Test Coverage

- Happy path
- Error cases
- Edge cases

### 3. Test Output

- Clear formatting
- Helpful messages
- Progress indication

## Common Issues

### 1. Permission Issues

```bash
# Fix permissions
chmod +x tests/**/*.sh
```

### 2. Path Issues

```bash
# Use dynamic paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### 3. Cleanup

```bash
# Always cleanup
cleanup() {
    git checkout main
    git branch -D test-branch
    rm -f test-file
}
trap cleanup EXIT
```

## Related Documentation

- [Command Reference](../commands/README.md)
- [Configuration Guide](../configuration/README.md)
- [Contributing Guide](../workflow/contributing.md)
