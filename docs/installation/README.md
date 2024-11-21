# 🚀 Installation Guide

Get started with ChronoGit quickly and easily.

## Prerequisites

Before installing ChronoGit, ensure you have:

1. Git installed and configured
   ```bash
   git --version
   ```

2. GitHub CLI (optional, for PR features)
   ```bash
   gh --version
   ```

## Quick Install

```bash
# 1. Clone repository
git clone https://github.com/your-username/chronogit.git
cd chronogit

# 2. Configure git aliases
echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig && git config --get include.path >/dev/null && echo "✓ Git aliases configured successfully" || echo "✗ Configuration failed"

# 3. Verify installation
git test -v
```

## Step-by-Step Installation

### 1. Clone Repository

```bash
# Using HTTPS
git clone https://github.com/your-username/chronogit.git

# Using SSH
git clone git@github.com:your-username/chronogit.git

# Change to directory
cd chronogit
```

### 2. Configure Git Aliases

```bash
# Add configuration to .gitconfig
echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig

# Verify configuration
git config --get include.path
```

### 3. Set Permissions

```bash
# Make scripts executable
chmod +x bin/*.sh
chmod +x tests/**/*.sh

# Verify permissions
ls -l bin/*.sh
```

### 4. Verify Installation

```bash
# Run verification tests
git test -v

# Check commands
git start-branch --help
git cc --help
git pr --help
```

## Optional Setup

### GitHub CLI

For PR features, install GitHub CLI:

```bash
# macOS
brew install gh

# Windows
winget install GitHub.cli

# Linux
# See https://cli.github.com/

# Authenticate
gh auth login
```

### SSH Key

For repository access:

```bash
# Generate key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Add to agent
ssh-add ~/.ssh/id_ed25519

# Test connection
ssh -T git@github.com
```

## Verification

Run these checks to verify your setup:

```bash
# 1. Check git aliases
git config --get include.path

# 2. Check commands
git start-branch --help
git cc --help
git pr --help

# 3. Run tests
git test -v
```

## Common Issues

See our [Troubleshooting Guide](troubleshooting.md) for solutions to:

- Git aliases not working
- Permission denied errors
- GitHub CLI issues
- Configuration problems

## Next Steps

1. [Learn the commands](../commands/README.md)
2. [Configure your setup](../configuration/README.md)
3. [Follow best practices](../workflow/best-practices.md)
4. [Run tests](../testing/README.md)

## Related Documentation

- [Command Reference](../commands/README.md)
- [Configuration Guide](../configuration/README.md)
- [Workflow Guide](../workflow/README.md)
- [Troubleshooting](troubleshooting.md)
