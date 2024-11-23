# 📚 ChronoGit Documentation

Welcome to the ChronoGit documentation! Here you'll find comprehensive guides and references to help you master your Git workflow.

## 📖 Table of Contents

### [🚀 Installation](installation/README.md)
- Quick start guide
- Prerequisites
  - SSH key setup
  - GitHub CLI
  - Authentication
- Verification steps
- [Troubleshooting](installation/troubleshooting.md)
- [Known Issues](known-issues.md)

### [🛠️ Commands](commands/README.md)
- [`git start-branch`](commands/start-branch.md) - Create feature branches
  - Branch naming
  - Ticket tracking
  - Source control
- [`git cc`](commands/conventional-commit.md) - Create standardized commits
  - Conventional commits
  - Scope handling
  - Breaking changes
- [`git open-pr`](commands/open-pr.md) - Create pull requests
  - Target selection
  - Template support
  - Draft PRs

### [⚙️ Configuration](configuration/README.md)
- [Custom settings](configuration/custom-config.md)
  - Branch configuration
  - Ticket handling
  - Repository setup
- Environment setup
- Git aliases

### [📋 Workflow](workflow/README.md)
- [Best practices](workflow/best-practices.md)
  - Branch naming
  - Commit messages
  - PR guidelines
- [Workflow examples](workflow/examples.md)
  - Feature development
  - Bug fixes
  - Documentation
- [Contributing guide](workflow/contributing.md)
- Ticket references

### [🧪 Testing](testing/README.md)
- [Test guide](testing/test-guide.md)
  - Running tests
  - Test types
  - Adding tests
- Interactive tests
  - Workflow testing
  - User interaction
- Non-interactive tests
  - Flag testing
  - Automation
- Verification tests
  - Installation checks
  - Basic functionality

### [🔮 Future Improvements](improvements/README.md)
- [Review command](improvements/review-command.md)
- [Rollback command](improvements/rollback-command.md)
- [Standup command](improvements/standup-command.md)
- [Sync command](improvements/sync-command.md)
- [Workspace command](improvements/workspace-command.md)

## 🔍 Quick Links

- [Installation Guide](installation/README.md)
- [Command Reference](commands/README.md)
- [Best Practices](workflow/best-practices.md)
- [Troubleshooting](installation/troubleshooting.md)
- [Known Issues](known-issues.md)
- [Contributing](workflow/contributing.md)

## 📁 Project Structure

```
chronogit/
├── bin/              # Main executable scripts
│   ├── conventional-commit.sh
│   ├── start-branch.sh
│   └── open-pr.sh
├── tests/            # Testing scripts
│   ├── run-tests.sh          # Test runner
│   ├── interactive/          # Interactive tests
│   ├── non-interactive/      # Flag tests
│   └── verify/              # Setup tests
├── docs/             # Documentation
│   ├── installation/         # Installation guides
│   ├── commands/            # Command docs
│   ├── configuration/       # Config guides
│   ├── workflow/           # Workflow guides
│   ├── testing/            # Test docs
│   ├── improvements/       # Future features
│   └── known-issues.md     # Known issues & behaviors
├── .gitconfig        # Git configuration
└── README.md         # Project overview
```

## 🎯 Getting Started

1. [Install ChronoGit](installation/README.md)
2. [Learn the commands](commands/README.md)
3. [Follow best practices](workflow/best-practices.md)
4. [Contribute](workflow/contributing.md)

## 🆘 Need Help?

- Check the [troubleshooting guide](installation/troubleshooting.md)
- Review [known issues](known-issues.md)
- See [configuration options](configuration/README.md)
- Learn about [conflict handling](workflow/best-practices.md#conflict-management)
