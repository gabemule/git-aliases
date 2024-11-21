# 📋 Workflow Guide

ChronoGit provides a streamlined Git workflow designed for clarity and consistency.

## Quick Start

```bash
# 1. Create feature branch
git start-branch -t PROJ-123

# 2. Make changes and commit
git cc

# 3. Create pull request
git pr
```

## Workflow Overview

### 1. Branch Creation

```bash
# Start new feature
git start-branch -t PROJ-123
# or
git start -t PROJ-123

# Select branch type:
# - feature/
# - bugfix/
# - hotfix/
# - release/
# - docs/
```

### 2. Development

```bash
# Stage changes
git add .

# Create commit
git cc
# Select type (feat, fix, etc.)
# Enter scope (optional)
# Enter description

# Push changes
git push origin feature/task
```

### 3. Pull Requests

```bash
# Create PR
git open-pr
# or
git pr

# Select target:
# - development (features)
# - production (hotfixes)
```

## Branch Strategy

```
production
    │
    ├── development
    │     │
    │     ├── feature/task-1
    │     └── feature/task-2
    │
    └── hotfix/critical-fix
```

### Branch Types

1. **Production Branch**
   - Main production code
   - Always stable
   - Protected branch

2. **Development Branch**
   - Integration branch
   - Features merge here
   - Staging environment

3. **Feature Branches**
   - New features
   - Bug fixes
   - Documentation

4. **Hotfix Branches**
   - Critical fixes
   - Merge to production
   - Backport to development

## Commit Strategy

### Conventional Commits

```
type(scope): description [ticket]

body

BREAKING CHANGE: description
```

### Types

- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `perf`: Performance
- `test`: Testing
- `chore`: Maintenance

### Examples

```bash
# Feature
git cc -m "implement login" -s auth
➜ feat(auth): implement login [PROJ-123]

# Bug fix
git cc -m "fix alignment" -s ui
➜ fix(ui): fix alignment [PROJ-123]

# Breaking change
git cc -m "change API" -s core -b
➜ feat(core)!: change API [PROJ-123]
```

## PR Strategy

### PR Flow

1. **Create PR**
   ```bash
   git pr
   ```

2. **Review Process**
   - Code review
   - Testing
   - Approval

3. **Merge**
   - Squash and merge
   - Delete branch
   - Auto-close ticket

### PR Types

1. **Feature PRs**
   - Target: development
   - Regular review
   - Template-based

2. **Hotfix PRs**
   - Target: production
   - Urgent review
   - Backport needed

## Best Practices

See our detailed guides:
- [Best Practices](best-practices.md)
- [Workflow Examples](examples.md)
- [Contributing Guide](contributing.md)

## Related Documentation

- [Command Reference](../commands/README.md)
- [Configuration Guide](../configuration/README.md)
- [Testing Guide](../testing/README.md)
