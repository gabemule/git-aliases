# 📋 Workflow Examples

Real-world examples of common ChronoGit workflows.

## Feature Development

### 1. New Feature

```bash
# Start feature branch
git start-branch -t PROJ-123
# Select: feature
# Name: user-authentication

# Create component
echo 'export const Login = () => {...}' > Login.tsx
git add Login.tsx
git cc -m "add login component" -s ui

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

### 2. Feature with Breaking Change

```bash
# Start feature branch
git start-branch -t PROJ-456
# Select: feature
# Name: api-v2

# Update API
echo 'export const api = { v2: {...} }' > api.ts
git add api.ts
git cc -m "update API structure" -s core -b

# Update clients
git add .
git cc -m "update API clients" -s client

# Create PR
git pr --draft
# Title: [PROJ-456] API v2 Implementation
```

## Bug Fixes

### 1. Quick Fix

```bash
# Start bugfix branch
git start-branch -t PROJ-789
# Select: bugfix
# Name: button-alignment

# Fix CSS
git add styles.css
git cc -m "fix button alignment" -s ui

# Create PR
git pr -t development
```

### 2. Critical Hotfix

```bash
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

### 1. API Documentation

```bash
# Start docs branch
git start-branch -t PROJ-234
# Select: docs
# Name: api-reference

# Update docs
git add docs/
git cc -m "update API docs" --no-scope

# Create PR
git pr
```

### 2. README Update

```bash
# Start docs branch
git start-branch -t PROJ-567
# Select: docs
# Name: readme-update

# Update README
git add README.md
git cc -m "improve getting started" -s docs

# Create PR
git pr --no-browser
```

## Release Management

### 1. Version Release

```bash
# Start release branch
git start-branch -t PROJ-890
# Select: release
# Name: v1.2.0

# Update version
git add package.json
git cc -m "bump version" -s release

# Update changelog
git add CHANGELOG.md
git cc -m "update changelog" --no-scope

# Create PR
git pr -t production
```

### 2. Post-Release Fixes

```bash
# Start hotfix branch
git start-branch -t PROJ-999
# Select: hotfix
# Name: post-release-fix

# Fix issue
git add .
git cc -m "fix deployment issue" -s deploy

# Create PR
git pr -t production
```

## Complex Workflows

### 1. Feature with Multiple Components

```bash
# Start feature branch
git start-branch -t PROJ-321
# Select: feature
# Name: user-dashboard

# Add components
git add components/
git cc -m "add dashboard layout" -s ui

git add services/
git cc -m "add data services" -s api

git add tests/
git cc -m "add integration tests" -s test

# Create PR
git pr --draft
```

### 2. Refactoring with Breaking Changes

```bash
# Start feature branch
git start-branch -t PROJ-654
# Select: feature
# Name: core-refactor

# Refactor core
git add src/core
git cc -m "refactor core module" -s core -b

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

### 1. Commit Organization

```bash
# Group by component
git cc -m "update header" -s ui
git cc -m "update footer" -s ui

# Group by type
git cc -m "add feature" -s core
git cc -m "add tests" -s test
git cc -m "add docs" --no-scope
```

### 2. PR Organization

```bash
# Feature PR
git pr
# Title: [PROJ-123] Add Feature
# Description:
# - Component changes
# - Test coverage
# - Documentation

# Breaking Change PR
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
