# Verification Tests ✅

## Overview

Verification tests ensure proper installation and basic functionality of the git workflow commands. These tests run first to validate the environment before other tests.

## Available Tests

### installation.sh
Verifies setup requirements:
- Git installation
- Script permissions
- Configuration files
- GitHub CLI setup

### workflow.sh
Verifies basic functionality:
- Branch creation
- Ticket storage
- Commit creation
- PR creation

## Running Tests

```bash
# Run all verification tests
./tests/run-tests.sh -v

# Run specific test
./tests/verify/installation.sh
./tests/verify/workflow.sh
```

## Test Requirements

1. **Git Setup**
   - Git installed
   - Git config includes our .gitconfig
   - Repository initialized

2. **GitHub CLI**
   - gh CLI installed
   - User authenticated
   - Repository access

3. **File Permissions**
   - Scripts executable
   - Config files readable
   - Test files executable

## Test Flow

### Installation Test

1. **Environment Check**
   ```bash
   # Check git installation
   check_config "git installation" \
       "command -v git >/dev/null 2>&1"

   # Check configuration
   check_config "include configuration" \
       "git config --get include.path"

   # Check permissions
   check_config "script permissions" \
       "[ -x bin/conventional-commit.sh ]"
   ```

### Workflow Test

1. **Basic Functionality**
   ```bash
   # Check branch creation
   check_test "branch creation" \
       "git branch" \
       "feature/test-feature"

   # Check ticket storage
   check_test "ticket storage" \
       "git config branch.feature/test-feature.ticket" \
       "TEST-123"
   ```

## Adding New Tests

1. Create new verification test:
   ```bash
   touch tests/verify/new-verify-test.sh
   chmod +x tests/verify/new-verify-test.sh
   ```

2. Implement verification:
   ```bash
   #!/bin/bash
   
   # Add checks
   check_config "test name" "command" "error message"
   
   # Add verifications
   check_test "test name" "command" "expected"
   ```

3. Add to test runner:
   ```bash
   # Update tests/run-tests.sh
   verify_tests+=(tests/verify/new-verify-test.sh)
   ```

## Best Practices

1. **Verification Order**
   - Check installation first
   - Then check configuration
   - Finally check functionality

2. **Error Messages**
   - Clear error descriptions
   - Solution suggestions
   - Helpful commands

3. **Test Independence**
   - Self-contained tests
   - No dependencies between tests
   - Clean state after tests

## Troubleshooting

### Common Issues

1. **Installation Problems**
   ```bash
   # Check git setup
   ./tests/verify/installation.sh --verbose
   ```

2. **Configuration Issues**
   ```bash
   # View git config
   git config --list
   ```

3. **Permission Problems**
   ```bash
   # Fix permissions
   chmod +x bin/*.sh tests/**/*.sh
   ```

### Getting Help

1. Run installation check:
   ```bash
   ./tests/verify/installation.sh
   ```

2. View configuration:
   ```bash
   git config --get include.path
   ```

3. Check permissions:
   ```bash
   ls -l bin/*.sh tests/**/*.sh
