# 📋 Test Guide

Detailed examples and guides for testing ChronoGit.

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

# Example test cases:
1. start-branch:
   ```bash
   git start-branch -t TEST-123 -b feature -n test-feature
   ```

2. conventional-commit:
   ```bash
   git cc -m "add feature" --type feat -s ui --non-interactive
   ```

3. open-pr:
   ```bash
   git pr -t development --title "Test PR" --no-browser
   ```
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

## Writing Tests

### Common Test Functions

```bash
#!/bin/bash

# Colors
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

# Setup test environment
setup() {
    # Create test branch
    git checkout -b test-branch
    
    # Create test file
    echo "test" > test.txt
    git add test.txt
}

# Cleanup test environment
cleanup() {
    git checkout main
    git branch -D test-branch
    rm -f test.txt
}

# Run tests
run_tests() {
    setup
    
    # Test cases
    check_test "test case 1" "command" "expected"
    ((total_tests++))
    [ $? -eq 0 ] && ((tests_passed++))
    
    cleanup
}

# Run and report
run_tests
echo "Tests passed: $tests_passed/$total_tests"
```

## Test Cases

### 1. start-branch Tests

```bash
# Test branch creation
check_test "branch creation" \
    "git start-branch -t TEST-123 -b feature -n test" \
    "feature/test"

# Test ticket storage
check_test "ticket storage" \
    "git config branch.feature/test.ticket" \
    "TEST-123"
```

### 2. conventional-commit Tests

```bash
# Test basic commit
check_test "basic commit" \
    "git cc -m 'test' --type feat -s ui --non-interactive" \
    "feat(ui): test"

# Test breaking change
check_test "breaking change" \
    "git cc -m 'test' --type feat -s ui -b --non-interactive" \
    "feat(ui)!: test"
```

### 3. open-pr Tests

```bash
# Test PR creation
check_test "pr creation" \
    "git pr -t development --title 'Test PR' --no-browser" \
    "Created PR: Test PR"

# Test draft PR
check_test "draft pr" \
    "git pr -t development --title 'Draft PR' --draft --no-browser" \
    "Created draft PR"
```

## Non-interactive Mode

For automated testing, commands support non-interactive mode:

### 1. start-branch
```bash
git start-branch -t TEST-123 -b feature -n test-feature
```

### 2. conventional-commit
```bash
git cc -m "message" --type feat -s ui --non-interactive
```

### 3. open-pr
```bash
git pr -t development --title "Test PR" --no-browser
```

## Test Organization

```
tests/
├── interactive/           # Interactive workflow tests
│   └── workflow-test.sh  # Full workflow with user interaction
├── non-interactive/      # Non-interactive feature tests
│   ├── start-branch-test.sh
│   ├── conventional-commit-test.sh
│   └── open-pr-test.sh
└── verify/               # Setup and verification tests
    ├── installation.sh
    └── workflow.sh
```

## Best Practices

### 1. Test Setup

- Clean environment before tests
- Use unique test data
- Handle cleanup properly

### 2. Test Cases

- Test happy path
- Test error cases
- Test edge cases

### 3. Test Output

- Clear test names
- Helpful error messages
- Summary reports

## Related Documentation

- [Command Reference](../commands/README.md)
- [Configuration Guide](../configuration/README.md)
- [Contributing Guide](../workflow/contributing.md)