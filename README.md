# Git Workflow Scripts

A collection of Git workflow automation scripts designed to streamline development processes and enforce consistent conventions with ticket tracking.

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/git-aliases.git
   ```

2. Set up Git aliases (one-liner):
   ```bash
   echo -e "[gab]\n    path = $(pwd)/.gitconfig" >> ~/.gitconfig
   ```
   This will automatically add the include directive to your global Git config.

3. Ensure you have:
   - SSH key configured for GitHub ([Setup Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent))
   - GitHub CLI installed ([Installation Guide](https://cli.github.com/))
   - Authenticated with GitHub CLI:
     ```bash
     gh auth login
     ```

## Available Commands

### `start-branch.sh`

Creates new branches with standardized naming and stores ticket references.

**Features:**
- Clean, descriptive branch names
- Ticket reference storage in Git config
- Automatic stashing of changes
- Production branch sync

**Usage:**
```bash
./start-branch.sh -t PROJ-123
# Select branch type (feature, bugfix, etc.)
# Enter task name
# Creates: feature/user-authentication
# Stores: PROJ-123 in branch config
```

### `conventional-commit.sh`

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, automatically including ticket references.

**Features:**
- Interactive type selection
- Optional scope support
- Breaking change detection
- Automatic ticket reference inclusion
- Optional auto-push

**Usage:**
```bash
# Make changes and stage them
git add .

# Create commit
./conventional-commit.sh
# Select type (feat, fix, etc.)
# Enter description
# Automatically includes [PROJ-123]

# Or set specific ticket
./conventional-commit.sh -t PROJ-456
```

### `open-pr.sh`

Streamlines PR creation with automatic ticket reference inclusion.

**Features:**
- Target branch selection
- Automatic ticket inclusion in title
- Duplicate PR detection
- Web-based PR opening

**Usage:**
```bash
./open-pr.sh
# Select target (development/production)
# Enter title (ticket automatically included)
# Enter description
```

## Branch Types

| Type | Purpose | Example |
|------|---------|---------|
| feature/ | New features | feature/user-authentication |
| bugfix/ | Non-critical fixes | bugfix/login-validation |
| hotfix/ | Critical production fixes | hotfix/security-vulnerability |
| release/ | Release preparation | release/v1.2.0 |
| docs/ | Documentation updates | docs/api-endpoints |

## Commit Types

| Type | Purpose | Example |
|------|---------|---------|
| feat | New features | feat(auth): add password reset [PROJ-123] |
| fix | Bug fixes | fix(ui): correct button alignment [PROJ-123] |
| docs | Documentation | docs(api): update endpoints [PROJ-123] |
| style | Code style changes | style(lint): format according to rules [PROJ-123] |
| refactor | Code improvements | refactor(core): optimize data flow [PROJ-123] |
| perf | Performance improvements | perf(queries): optimize database calls [PROJ-123] |
| test | Testing changes | test(auth): add login tests [PROJ-123] |
| chore | Maintenance tasks | chore(deps): update packages [PROJ-123] |
| ci | CI/CD changes | ci(deploy): update pipeline [PROJ-123] |
| build | Build system changes | build(webpack): optimize config [PROJ-123] |

## Workflow Example

1. Start new feature branch:
   ```bash
   ./start-branch.sh -t PROJ-123
   # Select: feature
   # Name: user-authentication
   ```

2. Make changes and commit:
   ```bash
   git add .
   ./conventional-commit.sh
   # Select: feat
   # Scope: auth
   # Description: implement login
   # Results in: feat(auth): implement login [PROJ-123]
   ```

3. Create PR:
   ```bash
   ./open-pr.sh
   # Select: development
   # Title auto-includes: [PROJ-123]
   ```

## Best Practices

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

## Troubleshooting

1. **Missing Ticket Reference**
   ```bash
   # Set ticket for current branch
   git config branch.$(git rev-parse --abbrev-ref HEAD).ticket PROJ-123
   ```

2. **Branch Issues**
   ```bash
   # View current ticket
   git config branch.$(git rev-parse --abbrev-ref HEAD).ticket
   ```

3. **Commit Issues**
   ```bash
   # Set current ticket
   ./conventional-commit.sh -t PROJ-123
   ```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit changes using `conventional-commit.sh`
4. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
