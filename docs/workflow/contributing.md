# 🤝 Contributing Guide

Thank you for considering contributing to ChronoGit! This guide will help you get started.

## Quick Start

```bash
# 1. Fork and clone
git clone https://github.com/your-username/chronogit.git
cd chronogit

# 2. Install
echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig

# 3. Create feature branch
git start-branch -t CHRON-123

# 4. Make changes and commit
git cc

# 5. Create PR
git pr
```

## Development Setup

### Prerequisites

1. Git
   ```bash
   git --version  # Check installation
   ```

2. GitHub CLI
   ```bash
   gh --version   # Check installation
   gh auth login  # Authenticate
   ```

### Installation

1. Fork the repository on GitHub

2. Clone your fork:
   ```bash
   git clone https://github.com/your-username/chronogit.git
   cd chronogit
   ```

3. Configure git aliases:
   ```bash
   echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig
   ```

4. Verify installation:
   ```bash
   git test -v
   ```

## Development Workflow

### 1. Create Feature Branch

```bash
# Start new feature
git start-branch -t CHRON-123
# Select: feature
# Name: your-feature
```

### 2. Make Changes

```bash
# Edit files
code .

# Stage changes
git add .

# Create commit
git cc
# Select: feat
# Scope: core
# Description: add feature
```

### 3. Test Changes

```bash
# Run all tests
git test -a

# Run specific tests
git test  # Select test type
```

### 4. Create Pull Request

```bash
# Create PR
git pr
# Target: development
# Title: [CHRON-123] Add feature
# Description: Feature details
```

## Project Structure

```
chronogit/
├── bin/              # Command scripts
│   ├── conventional-commit.sh
│   ├── start-branch.sh
│   └── open-pr.sh
├── tests/            # Test files
│   ├── interactive/
│   ├── non-interactive/
│   └── verify/
└── docs/             # Documentation
```

## Testing

### Running Tests

```bash
# All tests
git test -a

# Interactive tests
git test -i

# Non-interactive tests
git test -n

# Verification tests
git test -v
```

### Adding Tests

1. Create test file:
   ```bash
   # Interactive test
   touch tests/interactive/new-test.sh
   
   # Non-interactive test
   touch tests/non-interactive/new-test.sh
   ```

2. Update test runner:
   ```bash
   # Edit tests/run-tests.sh
   interactive_tests+=(tests/interactive/new-test.sh)
   ```

## Documentation

### Updating Docs

1. Edit relevant files:
   ```bash
   # Command docs
   docs/commands/*.md
   
   # Configuration
   docs/configuration/*.md
   
   # Workflow
   docs/workflow/*.md
   ```

2. Follow documentation style:
   - Clear headings
   - Code examples
   - Related links

### Adding Features

1. Create feature doc:
   ```bash
   touch docs/improvements/feature-name.md
   ```

2. Include:
   - Feature description
   - Use cases
   - Implementation details

## Pull Request Guidelines

### PR Checklist

- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Changes tested locally
- [ ] Commit messages follow convention
- [ ] PR description is clear

### PR Template

```markdown
## Description
Brief description of changes

## Changes
- Added feature X
- Updated tests
- Updated docs

## Testing
1. Step one
2. Step two
3. Verify result

## Related
- Issue: #123
- Documentation: [Link]()
```

## Code Style

### Shell Scripts

```bash
# Function names
function_name() {
    local var="value"
    echo "$var"
}

# Error handling
if ! command; then
    echo "Error message"
    exit 1
fi

# Variables
local MY_VAR="value"
echo "$MY_VAR"
```

### Documentation

```markdown
# Title

## Section

### Subsection

\`\`\`bash
# Code example
command
\`\`\`
```

## Getting Help

- Check [documentation](../README.md)
- Run `git test` for verification
- Open an issue for questions

## Related Documentation

- [Installation Guide](../installation/README.md)
- [Command Reference](../commands/README.md)
- [Best Practices](best-practices.md)
