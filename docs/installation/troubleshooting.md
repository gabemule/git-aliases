# 🔧 Troubleshooting Guide

Solutions for common issues with ChronoGit.

## Quick Fixes

```bash
# 1. Verify installation
git test -v

# 2. Check configuration
git config --get include.path

# 3. Fix permissions
chmod +x /path/to/chronogit/bin/*.sh
```

## Installation Issues

### Git Aliases Not Working

**Problem**: Commands like `git cc` not found

**Check**:
```bash
# Verify git config include
git config --get include.path

# Check .gitconfig content
cat ~/.gitconfig
```

**Solution**:
```bash
# Re-add configuration
echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig

# Verify it worked
git config --get include.path
```

### Script Permissions

**Problem**: "Permission denied" when running commands

**Check**:
```bash
# Check permissions
ls -l bin/*.sh
```

**Solution**:
```bash
# Fix permissions
chmod +x bin/*.sh
chmod +x tests/**/*.sh

# Verify fix
ls -l bin/*.sh
```

### GitHub CLI Issues

**Problem**: PR creation fails

**Check**:
```bash
# Check installation
gh --version

# Check authentication
gh auth status
```

**Solution**:
```bash
# Install GitHub CLI
brew install gh  # macOS
winget install GitHub.cli  # Windows

# Authenticate
gh auth login
```

## Command Issues

### Branch Creation

**Problem**: Branch creation fails

**Check**:
```bash
# Check current branch
git branch

# Check git status
git status
```

**Solution**:
```bash
# Stash changes
git stash

# Create branch
git start-branch -t PROJ-123

# Restore changes
git stash pop
```

### Commit Creation

**Problem**: Commit fails

**Check**:
```bash
# Check staged files
git status

# Check last commit
git log -1
```

**Solution**:
```bash
# Stage files
git add .

# Create commit
git cc -m "fix: resolve issue"

# Verify commit
git log -1
```

### PR Creation

**Problem**: PR creation fails

**Check**:
```bash
# Check branch
git branch

# Check remote
git remote -v
```

**Solution**:
```bash
# Push branch
git push origin feature/task

# Create PR
git pr -t development
```

## Configuration Issues

### Main Branch

**Problem**: Wrong main branch

**Check**:
```bash
# Check configuration
git config workflow.mainBranch
```

**Solution**:
```bash
# Set main branch
git config workflow.mainBranch main

# Verify setting
git config workflow.mainBranch
```

### Ticket References

**Problem**: Missing ticket references

**Check**:
```bash
# Check branch ticket
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket
```

**Solution**:
```bash
# Set ticket
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket PROJ-123

# Verify ticket
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket
```

## Test Issues

### Test Failures

**Problem**: Tests failing

**Check**:
```bash
# Run verification
git test -v

# Check specific test
./tests/verify/installation.sh
```

**Solution**:
```bash
# Fix permissions
chmod +x tests/**/*.sh

# Re-run tests
git test -v
```

### Path Issues

**Problem**: Files not found

**Check**:
```bash
# Check current directory
pwd

# List files
ls -la
```

**Solution**:
```bash
# Use full paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"
```

## Common Error Messages

### "Not a git repository"

**Problem**: Git commands fail

**Solution**:
```bash
# Check if in git repo
git rev-parse --git-dir

# Initialize if needed
git init

# Set remote
git remote add origin <url>
```

### "Permission denied"

**Problem**: Can't execute scripts

**Solution**:
```bash
# Fix script permissions
chmod +x bin/*.sh
chmod +x tests/**/*.sh

# Verify fix
ls -l bin/*.sh
```

### "GitHub CLI not installed"

**Problem**: PR creation fails

**Solution**:
```bash
# Install GitHub CLI
brew install gh  # macOS
winget install GitHub.cli  # Windows

# Authenticate
gh auth login
```

## Verification Steps

Run these checks to verify your setup:

```bash
# 1. Check installation
git test -v

# 2. Check commands
git start-branch -h
git cc -h
git pr -h

# 3. Check configuration
git config --get include.path
git config workflow.mainBranch
```

## Getting Help

If you're still having issues:

1. Run verification tests:
   ```bash
   git test -v
   ```

2. Check documentation:
   - [Installation Guide](README.md)
   - [Command Reference](../commands/README.md)
   - [Configuration Guide](../configuration/README.md)

3. Open an issue with:
   - Error message
   - Steps to reproduce
   - Verification test results
