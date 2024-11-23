# ✨ Best Practices

Follow these best practices to get the most out of ChronoGit.

## Branch Management

### Branch Naming

✅ **Do**:
- Use descriptive names
- Follow type prefixes
- Include ticket references
```bash
git start-branch -t PROJ-123
# feature/user-authentication
```

❌ **Don't**:
- Use vague names
- Skip type prefixes
- Omit ticket references
```bash
git start-branch  # without ticket
# Avoid: feature/stuff
```

### Branch Types

Use appropriate types:
- `feature/` - New features
- `bugfix/` - Non-critical fixes
- `hotfix/` - Critical fixes
- `release/` - Release preparation
- `docs/` - Documentation

## Commit Messages

### Conventional Commits

✅ **Do**:
```bash
# Clear type and scope
git cc -m "add login form" -s auth
➜ feat(auth): add login form [PROJ-123]

# Breaking changes marked
git cc -m "change API" -s core -b
➜ feat(core)!: change API [PROJ-123]
```

❌ **Don't**:
```bash
# Vague messages
git cc -m "fix stuff"

# Missing type
git commit -m "changes"
```

### Commit Scope

✅ **Do**:
- Use consistent scopes
- Keep scopes focused
- Skip when unclear
```bash
git cc -m "update styles" -s ui
git cc -m "fix typo" --no-scope
```

❌ **Don't**:
- Use inconsistent scopes
- Use overly broad scopes
- Force scopes when unnecessary

## Pull Requests

### PR Creation

✅ **Do**:
```bash
# Create PR with clear title
git pr
# [PROJ-123] Add user authentication

# Use draft for WIP
git pr --draft
```

❌ **Don't**:
- Skip ticket references
- Use vague titles
- Mix multiple features

### PR Templates

✅ **Do**:
- Follow template structure
- Include test steps
- Link related PRs
```markdown
## Changes
- Added login form
- Implemented validation
- Added tests

## Testing
1. Open login page
2. Enter credentials
3. Verify success
```

❌ **Don't**:
- Ignore templates
- Skip testing steps
- Omit important details

## Workflow Tips

### Development Flow

1. Start Clean
```bash
# Create new branch
git start-branch -t PROJ-123

# Verify branch
git status
```

2. Work Iteratively
```bash
# Small, focused commits
git cc -m "add form structure" -s ui
git cc -m "implement validation" -s auth
```

3. Review Changes
```bash
# Check work
git status
git diff

# Create PR
git pr
```

### Ticket Handling

✅ **Do**:
- Set tickets when creating branches
- Use override when needed
- Keep tickets synchronized
```bash
# Branch ticket
git start-branch -t PROJ-123

# Override for specific commit
git cc -t PROJ-456
```

❌ **Don't**:
- Skip ticket references
- Mix ticket references
- Use incorrect tickets

## Testing

### Before PR

✅ **Do**:
- Run tests
- Check linting
- Verify functionality
```bash
# Run tests
git test

# Check changes
git status
git diff --staged
```

❌ **Don't**:
- Skip testing
- Ignore linting errors
- Rush reviews

### After Changes

✅ **Do**:
- Verify fixes
- Test edge cases
- Document changes
```bash
# Test changes
git test -v

# Update PR
git push origin feature/task
```

## Common Issues

### Branch Issues

Problem: Wrong base branch
```bash
# Check current branch
git branch

# Start fresh
git start-branch -t PROJ-123
```

### Commit Issues

Problem: Wrong commit message
```bash
# Amend last commit
git cc --amend

# Force push if needed
git push -f origin feature/task
```

### PR Issues

Problem: PR needs updates
```bash
# Make changes
git cc -m "address feedback" -s ui

# Update PR
git push origin feature/task
```

## Conflict Management

### Conflict Prevention

Our tools help prevent conflicts through:
1. Auto-stashing changes (start-branch)
2. Auto-syncing with main branch (start-branch)
3. Standardized branch naming
4. Early conflict detection (PR creation)

✅ **Do**:
- Keep branches short-lived
- Sync with main branch regularly
- Use `--no-stash` only when needed
```bash
# Let start-branch handle stashing
git start-branch -t PROJ-123

# Only skip stash when needed
git start-branch -t PROJ-123 --no-stash
```

❌ **Don't**:
- Work on outdated branches
- Skip main branch sync
- Mix unrelated changes

### Common Conflict Scenarios

#### 1. PR Creation Conflicts
When GitHub reports your PR can't be automatically merged:

1. Sync with target branch
```bash
# Get latest changes
git checkout development
git pull origin development

# Update your branch
git checkout feature/task
git merge development
```

2. Resolve conflicts
```bash
# After fixing conflicts
git add .
git cc -m "merge development" -s merge
```

3. Update PR
```bash
git push origin feature/task
```

#### 2. Branch Sync Conflicts
When pulling main branch updates:

1. Stash your changes
```bash
git stash save "WIP: current changes"
```

2. Update main
```bash
git checkout main
git pull origin main
```

3. Update your branch
```bash
git checkout feature/task
git merge main
# Resolve conflicts if any
git add .
git cc -m "merge main" -s merge
```

4. Restore changes
```bash
git stash pop
# If conflicts with stashed changes:
# 1. Resolve conflicts
# 2. git add .
# 3. git stash drop
```

#### 3. Stash Pop Conflicts
When restoring stashed changes:

1. If stash pop fails
```bash
# Stash pop failed with conflicts
git status  # Check conflicted files
```

2. Resolve conflicts
```bash
# Edit conflicted files
git add .  # Mark as resolved
```

3. Clean up
```bash
git stash drop  # Remove stash after resolving
```

### Sync Strategies

✅ **Do**:
- Sync before starting work
- Use start-branch's auto-sync
- Resolve conflicts early

❌ **Don't**:
- Work on stale branches
- Skip sync with --no-sync
- Let conflicts accumulate

## Related Documentation

- [Workflow Guide](README.md)
- [Command Reference](../commands/README.md)
- [Configuration Guide](../configuration/README.md)
- [Testing Guide](../testing/README.md)
