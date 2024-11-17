# 🚀 Git Workflow Scripts

A collection of Git workflow automation scripts designed to streamline development processes and enforce consistent conventions with ticket tracking.

## ⚡ Installation

1. Clone this repository:
```bash
   git clone https://github.com/Akad-Seguros/front-git-aliases.git
   # or
   git clone git@github.com:Akad-Seguros/front-git-aliases.git
   # Then, Change Destination to the cloned repo
   cd front-git-aliases
```

2. Run the script to install the Aliases:
```bash
   echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig && git config --get include.path >/dev/null && echo "✓ Git aliases configured successfully" || echo "✗ Configuration failed"
```

3. Verify installation:
```bash
   ./tests/verify-installation.sh
```

4. Ensure you have:
   - 🔑 SSH key configured for GitHub ([Setup Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent))
   - 🛠️ GitHub CLI installed ([Installation Guide](https://cli.github.com/))
   - 🔒 Authenticated with GitHub CLI:
```bash
   gh auth login
```

## 🛠️ Available Commands

### 🌿 `git start-branch` (alias for bin/start-branch.sh)

Creates new branches with standardized naming and stores ticket references.

**Features:**
- Clean, descriptive branch names
- Ticket reference storage in Git config (see [Ticket References](#-ticket-references))
- Automatic stashing of changes
- Main branch sync (defaults to 'production', see [Custom Configuration](#%EF%B8%8F-custom-configuration))
- Configurable main branch per repository

**Usage:**
```bash
git start-branch -t PROJ-123
# Select branch type (feature, bugfix, etc.)
# Enter task name
# Creates: feature/user-authentication
# Stores: PROJ-123 in branch config
```

### ✍️ `git cc` (alias for bin/conventional-commit.sh)

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, with automatic ticket reference handling.

**Features:**
- Interactive type selection
- Optional scope support
- Breaking change detection
- Ticket reference handling (see [Ticket References](#-ticket-references)):
  - Uses ticket from current branch (set by start-branch)
  - Optional one-time ticket override for single commit
- Optional auto-push

**Usage:**
```bash
# Make changes and stage them
git add .

# Create commit using branch's ticket (from start-branch)
git cc
# Select type (feat, fix, etc.)
# Enter description
# Creates: feat(auth): implement login [PROJ-123]

# Override ticket for this commit only (not saved to branch)
git cc -t PROJ-456
# Creates: feat(auth): implement login [PROJ-456]
# Next commit will use branch's ticket again
```

### 🔍 `git open-pr` (alias for bin/open-pr.sh)

Streamlines PR creation with automatic ticket reference inclusion.

**Features:**
- Target branch selection
- Automatic ticket inclusion in title (see [Ticket References](#-ticket-references))
- Duplicate PR detection
- Web-based PR opening

**Usage:**
```bash
git open-pr
# Select target (development/production)
# Enter title (ticket automatically included)
# Enter description
```

## ⚙️ Custom Configuration

### Branch Custom Configuration
```bash
# Set custom main branch for repository (defaults to 'production')
git config workflow.mainBranch main

# View current main branch configuration
git config workflow.mainBranch
```

### Ticket Custom Configuration
```bash
# Set ticket for current branch
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket PROJ-123

# View current branch's ticket
git config branch.$(git rev-parse --abbrev-ref HEAD).ticket
```

### Commit Custom Configuration
```bash
# Use one-time ticket for single commit (not persisted)
git cc -t PROJ-456
```

## 🎫 Ticket References

Tickets can be handled in several ways:

1. **Branch Creation**
```bash
   # With ticket
   git start-branch -t PROJ-123
   
   # Without ticket (will prompt)
   git start-branch
```

2. **Commit Creation**
```bash
   # Use branch ticket
   git cc
   
   # Use one-time ticket (only for this commit)
   git cc -t PROJ-456
   
   # Future: Explicitly mark as no ticket
   # git cc -n
```

3. **PR Creation**
   - Automatically uses branch ticket
   - Includes in title and description
   - Links to ticket tracking system

## 🔄 Workflow Example

1. Start new feature branch:
```bash
   git start-branch -t PROJ-123
   # Select: feature
   # Name: user-authentication
```

2. Make changes and commit:
```bash
   git add .
   git cc
   # Select: feat
   # Scope: auth
   # Description: implement login
   # Results in: feat(auth): implement login [PROJ-123]
```

3. Create PR:
```bash
   git open-pr
   # Select: development
   # Title auto-includes: [PROJ-123]
```

## 🔧 Troubleshooting

### Installation Issues
1. **Git Aliases Not Working**
   ```bash
   # Verify git config include
   git config --get include.path
   
   # Check .gitconfig content manually
   cat ~/.gitconfig
   # Should contain:
   [include]
       path = /path/to/repo/front-git-aliases/.gitconfig
   
   # Re-run installation if needed
   echo -e "[include]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig
   ```

2. **GitHub CLI Issues**
   ```bash
   # Verify GitHub CLI installation
   gh --version
   
   # Re-authenticate if needed
   gh auth login
   ```

### Common Errors

1. **Not a Git Repository**
   ```bash
   # Error: not a git repository
   # Solution: Ensure you're in the correct directory and initialize if needed
   git init
   ```
   See [Custom Configuration](#%EF%B8%8F-custom-configuration) for repository setup.

2. **Branch Creation Failed**
   ```bash
   # Error: cannot create branch
   # Solution: Fetch latest changes and try again
   git fetch origin
   git start-branch -t PROJ-123
   ```

3. **Merge Conflicts**
   ```bash
   # Error: merge conflicts detected
   # Solution: Resolve conflicts and continue
   # Edit conflicted files, then:
   git add .
   git commit -m "fix: resolve conflicts"
   ```

## ✨ Best Practices

1. **Branch Names**
   - Use descriptive names
   - Follow type prefixes
   - Keep it clean and readable

2. **Commit Messages**
   - Follow conventional commits format
   - Include meaningful descriptions
   - Ticket references are automatic

3. **Pull Requests**
   - One PR per feature/fix
   - Clear descriptions
   - Link related PRs if needed

4. **Ticket References**
   - Set when creating branch
   - Automatically included in commits
   - Visible in PR title and description
   
## 📁 Project Structure

```
git-aliases/
├── bin/              # Main executable scripts
│   ├── conventional-commit.sh
│   ├── start-branch.sh
│   └── open-pr.sh
├── tests/            # Testing scripts
│   ├── test.sh              # Test runner
│   ├── verify-installation.sh  # Tests setup/config
│   └── verify-workflow.sh     # Tests functionality
├── docs/             # Documentation
│   ├── README.md            # Documentation index
│   ├── sync-command.md      # Sync command specification
│   ├── rollback-command.md  # Rollback command docs
│   ├── review-command.md    # Review command docs
│   ├── workspace-command.md # Workspace command docs
│   └── standup-command.md   # Standup command docs
├── .gitconfig        # Git configuration
└── README.md         # Main documentation
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Commit changes using `git cc`
4. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

