# Git Workflow Commands 📚

This directory contains documentation for our currently available git workflow commands.

## Available Commands

### 🌿 [git start-branch](start-branch.md)
Creates standardized branches with ticket tracking.
```bash
git start-branch -t PROJ-123
```

**Key Features:**
- Standardized branch naming
- Automatic ticket reference storage
- Main branch synchronization
- Stash handling
- Interactive branch type selection

### ✍️ [git cc](conventional-commit.md)
Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification.
```bash
git cc
```

**Key Features:**
- Interactive type selection
- Optional scope support
- Breaking change detection
- Automatic ticket reference inclusion
- Optional one-time ticket override

### 🔍 [git open-pr](open-pr.md)
Streamlines PR creation with automatic ticket reference inclusion.
```bash
git open-pr
```

**Key Features:**
- Interactive target branch selection
- Automatic ticket reference inclusion
- Duplicate PR detection
- Web-based PR opening
- Title and description prompts

## Planned Improvements

Each command has planned improvements documented in our improvements directory:
- [Start Branch Improvements](../improvements/update-start-branch.md)
- [Conventional Commit Improvements](../improvements/update-conventional-commit.md)
- [Open PR Improvements](../improvements/update-open-pr.md)

## Usage Examples

### Complete Workflow

```bash
# Create new feature branch
git start-branch -t PROJ-123
# Select: feature
# Name: user-authentication

# Make changes and commit
git add .
git cc
# Select: feat
# Scope: auth
# Description: implement login

# Create PR
git open-pr
# Select: development
# Title auto-includes: [PROJ-123]
```

## See Also

- [Main Documentation](../README.md)
- [Improvements Overview](../improvements/README.md)
- [Installation Guide](../../README.md#-installation)
- [Configuration Guide](../../README.md#%EF%B8%8F-custom-configuration)
