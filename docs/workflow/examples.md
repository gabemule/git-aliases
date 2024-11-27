# 📋 Workflow Examples

Real-world examples of common ChronoGit workflows, including newly implemented features.

## Feature Development

### 1. New Feature with Sync

```bash
# Start feature branch
git start-branch -t PROJ-123
# Select: feature
# Name: user-authentication

# Create component
echo 'export const Login = () => {...}' > Login.tsx
git add Login.tsx
git cc -m "add login component" -s ui

# Sync with main branch
git sync

# Add tests
echo 'test("login renders", () => {...})' > Login.test.tsx
git add Login.test.tsx
git cc -m "add login tests" -s test

# Update docs
echo '## Login Component' > README.md
git add README.md
git cc -m "update docs" --no-scope

# Create PR
git pr
# Select: development
# Title: [PROJ-123] Add user authentication
# Description: Added login component with tests
```

### 2. Feature with Breaking Change and Conflict Resolution

```bash
# Start feature branch
git start-branch -t PROJ-456
# Select: feature
# Name: api-v2

# Update API
echo 'export const api = { v2: {...} }' > api.ts
git add api.ts
git cc -m "update API structure" -s core -b

# Sync and resolve conflicts
git sync
# If conflicts occur, mergetool will be launched automatically

# Update clients
git add .
git cc -m "update API clients" -s client

# Create PR
git pr --draft
# Title: [PROJ-456] API v2 Implementation
```

## Bug Fixes

### 1. Quick Fix with Cherry-Pick

```bash
# Start bugfix branch
git start-branch -t PROJ-789
# Select: bugfix
# Name: button-alignment

# Fix CSS
git add styles.css
git cc -m "fix button alignment" -s ui

# Cherry-pick a commit from another branch
git jerrypick feature/responsive-design
# Select the commit with the alignment fix

# Create PR
git pr -t development
```

### 2. Critical Hotfix with Rollback

```bash
# Rollback to last stable version
git rollback
# Select the commit to rollback to

# Start hotfix branch
git start-branch -t PROJ-911
# Select: hotfix
# Name: security-patch

# Fix security issue
git add auth.ts
git cc -m "fix security vulnerability" -s auth

# Create PR to production
git pr -t production
```

## Documentation

### 1. API Documentation with Workspace Management

```bash
# Save current workspace
git workspace save current-task

# Start docs branch
git start-branch -t PROJ-234
# Select: docs
# Name: api-reference

# Update docs
git add docs/
git cc -m "update API docs" --no-scope

# Create PR
git pr

# Switch back to previous task
git workspace restore current-task
```

### 2. README Update with Sync

```bash
# Start docs branch
git start-branch -t PROJ-567
# Select: docs
# Name: readme-update

# Update README
git add README.md
git cc -m "improve getting started" -s docs

# Sync with main branch
git sync

# Create PR
git pr --no-browser
```

## Release Management

### 1. Version Release with Conflict Resolution

```bash
# Start release branch
git start-branch -t PROJ-890
# Select: release
# Name: v1.2.0

# Update version
git add package.json
git cc -m "bump version" -s release

# Sync and resolve conflicts
git sync
# If conflicts occur, mergetool will be launched automatically

# Update changelog
git add CHANGELOG.md
git cc -m "update changelog" --no-scope

# Create PR
git pr -t production
```

### 2. Post-Release Fixes with Cherry-Pick

```bash
# Start hotfix branch
git start-branch -t PROJ-999
# Select: hotfix
# Name: post-release-fix

# Cherry-pick fixes from development
git jerrypick development
# Select relevant commits

# Additional fix
git add .
git cc -m "fix deployment issue" -s deploy

# Create PR
git pr -t production
```

## Complex Workflows

### 1. Feature with Multiple Components and Workspace Switching

```bash
# Start feature branch
git start-branch -t PROJ-321
# Select: feature
# Name: user-dashboard

# Add components
git add components/
git cc -m "add dashboard layout" -s ui

# Switch to another task
git workspace save dashboard-wip
git workspace restore another-task

# ... work on another task ...

# Switch back to dashboard
git workspace restore dashboard-wip

git add services/
git cc -m "add data services" -s api

git add tests/
git cc -m "add integration tests" -s test

# Create PR
git pr --draft
```

### 2. Refactoring with Breaking Changes and Conflict Resolution

```bash
# Start feature branch
git start-branch -t PROJ-654
# Select: feature
# Name: core-refactor

# Refactor core
git add src/core
git cc -m "refactor core module" -s core -b

# Sync with main and resolve conflicts
git sync
# If conflicts occur, mergetool will be launched automatically

# Update tests
git add tests/
git cc -m "update core tests" -s test

# Update docs
git add docs/
git cc -m "update API docs" -s docs

# Create PR
git pr --draft
```

## Common Patterns

### 1. Commit Organization with Conventional Commits

```bash
# Group by component
git cc -m "update header" -s ui
git cc -m "update footer" -s ui

# Group by type
git cc -m "feat: add new feature" -s core
git cc -m "test: add unit tests" -s test
git cc -m "docs: update API documentation" --no-scope
```

### 2. PR Organization with Sync and Review

```bash
# Feature PR
git sync
git pr
# Title: [PROJ-123] Add Feature
# Description:
# - Component changes
# - Test coverage
# - Documentation

# Breaking Change PR
git sync
git pr --draft
# Title: [PROJ-456] Breaking: API Changes
# Description:
# - Breaking changes
# - Migration guide
# - Testing steps
```

## Related Documentation

- [Best Practices](best-practices.md)
- [Command Reference](../commands/README.md)
- [Configuration Guide](../configuration/README.md)
- [Mergetool Integration](mergetool-integration.md)
