# 🔑 SSH Config Command

Configure repository-specific SSH keys and identity information. Allows you to use different SSH keys for different repositories, which is especially useful for separating personal and organizational identities.

## Usage

```bash
# Interactive mode (local scope by default)
git ssh-config

# List available SSH keys
git ssh-config -l

# Show current SSH configuration (keys and identities)
git ssh-config -s

# Configure only identity (name and email)
git ssh-config -i

# Configure identity for specific scope
git ssh-config -i global
git ssh-config -i local
git ssh-config -i branch

# Reset SSH configuration to defaults
git ssh-config -r                # Reset both local and branch
git ssh-config -r local          # Reset only local
git ssh-config -r branch         # Reset only branch

# Global configuration (for all repositories)
git ssh-config -g -k ~/.ssh/id_ed25519

# Local configuration (for current repository only)
git ssh-config --local -k ~/.ssh/id_ed25519_work

# Branch configuration (for current branch only)
git ssh-config -b -k ~/.ssh/id_ed25519_project

# Set identity along with key
git ssh-config -k ~/.ssh/id_ed25519 -n "Work User" -e "work@example.com"

# Show help
git ssh-config -h
```

## Options

- `-k, --key <path>` - Specify SSH key path directly
- `-n, --name <name>` - Set user name
- `-e, --email <email>` - Set user email
- `-i, --identity [scope]` - Configure only identity (name and email)
  - Scope can be: global, local, branch, or none for interactive
- `-l, --list` - List available SSH keys
- `-s, --show` - Show current SSH configuration (keys and identities)
- `-r, --reset [scope]` - Reset SSH configuration to defaults
  - Scope can be: local, branch, or both (default)
- `-g, --global` - Set configuration at global level (all repositories)
- `-b, --branch` - Set configuration at branch level (current branch only)
- `--local` - Set configuration at local level (current repository only, default)
- `--no-identity` - Skip identity configuration
- `-h, --help` - Show help message

## How It Works

The `ssh-config` command configures Git to use a specific SSH key for all operations by setting the `core.sshCommand` configuration at the specified scope (global, local, or branch). This ensures that all Git commands that use SSH (like clone, fetch, pull, and push) will use the specified key.

The command detects all valid SSH private keys in your SSH directory, regardless of their naming convention. This allows you to use both standard SSH key names (like `id_rsa`, `id_ed25519`) and custom key names (like `company_key`, `project_key`).

### Configuration Scopes

- **Global**: Applies to all repositories for the current user
- **Local**: Applies only to the current repository (default)
- **Branch**: Applies only to the current branch in the current repository

The configuration follows a precedence order: Branch > Local > Global. This means that if a branch-specific configuration exists, it will override local and global configurations.

Under the hood, the command configures Git to use the specified SSH key for all operations and can also set user name and email at the chosen scope.

## Interactive Usage

When run without arguments, `ssh-config` enters interactive mode:

1. Prompts you to select a configuration scope (global, local, or branch)
2. Lists all available SSH keys in your SSH directory
3. Allows you to select a key from the list
4. Configures Git to use the selected key at the chosen scope
5. Optionally prompts for user name and email

## Examples

### Basic Usage

```bash
# Start interactive configuration
git ssh-config
```

Output:
```
Configure SSH Key

Select configuration scope:
1) Global (all repositories)
2) Local (current repository only)
3) Branch (current branch only)

Select scope (1-3) [2]: 2
Selected scope: local

1) id_rsa (ED25519) - personal@example.com
2) id_ed25519_work (ED25519) - work@company.com
3) id_ed25519_project (ED25519) - project@organization.com

Select key (1-3): 2
Repository configured to use /home/user/.ssh/id_ed25519_work

Configure name/email for this local? [Y/n]: Y
Name [Current User]: Work User
Email [user@example.com]: work@company.com
Repository identity configured
Name: Work User
Email: work@company.com
```

### Show Current Configuration

```bash
git ssh-config -s
```

Output:
```
Current SSH Configuration:

SSH Keys:
  Global:    /home/user/.ssh/id_rsa
  Local:     /home/user/.ssh/id_ed25519_work
  Branch:    Not set (feature/task)
  Effective: /home/user/.ssh/id_ed25519_work (local)

Identities:
  Global:    Personal User <personal@example.com>
  Local:     Work User <work@company.com>
  Branch:    Not set <Not set> (feature/task)
  Effective: Work User <work@company.com> (local)
```

### List Available Keys

```bash
git ssh-config -l
```

Output:
```
Available SSH Keys:

/home/user/.ssh/id_rsa (ED25519) - personal@example.com
/home/user/.ssh/id_ed25519_work (ED25519) - work@company.com
/home/user/.ssh/id_ed25519_project (ED25519) - project@organization.com
```

### Configure Identity Only

```bash
# Configure identity interactively
git ssh-config -i
```

Output:
```
Select configuration scope:
1) Global - Apply to all repositories (saved in ~/.gitconfig)
2) Local  - Apply to current repository only (saved in .git/config)
3) Branch - Apply to current branch 'feature/task' only

Select scope (1-3) [2]: 1
Configure Identity for Repository

Name [Current User]: Personal User
Email [user@example.com]: personal@example.com
Global identity configured
Name: Personal User
Email: personal@example.com
```

```bash
# Configure identity for specific scope
git ssh-config -i global -n "Personal User" -e "personal@example.com"
```

Output:
```
Global identity configured
Name: Personal User
Email: personal@example.com
```

### Reset Configuration

```bash
# Reset both local and branch configurations
git ssh-config -r
```

Output:
```
Resetting local SSH configuration...
Local SSH configuration reset to defaults
Resetting branch 'feature/task' SSH configuration...
Branch 'feature/task' SSH configuration reset to defaults
```

```bash
# Reset only local configuration
git ssh-config -r local
```

Output:
```
Resetting local SSH configuration...
Local SSH configuration reset to defaults
```

```bash
# Reset only branch configuration
git ssh-config -r branch
```

Output:
```
Resetting branch 'feature/task' SSH configuration...
Branch 'feature/task' SSH configuration reset to defaults
```

### Direct Configuration Examples

```bash
# Global configuration
git ssh-config -g -k ~/.ssh/id_rsa -n "Personal User" -e "personal@example.com"
```

Output:
```
Global SSH configuration set to use /home/user/.ssh/id_rsa
Global identity configured
Name: Personal User
Email: personal@example.com
```

```bash
# Local (repository) configuration
git ssh-config --local -k ~/.ssh/id_ed25519_work -n "Work User" -e "work@company.com"
```

Output:
```
Repository configured to use /home/user/.ssh/id_ed25519_work
Repository identity configured
Name: Work User
Email: work@company.com
```

```bash
# Branch-specific configuration
git ssh-config -b -k ~/.ssh/id_ed25519_project
```

Output:
```
Branch 'feature/task' configured to use /home/user/.ssh/id_ed25519_project
```

## Configuration

The behavior of `ssh-config` can be customized through the following Git configurations:

| Setting | Default | Description |
|---------|---------|-------------|
| workflow.ssh.keyDir | ~/.ssh | Directory for SSH keys |
| workflow.ssh.confirmChange | true | Confirm before changing SSH key |
| workflow.ssh.displayFormat | both | SSH key display format (name, comment, both) |
| workflow.ssh.promptIdentity | true | Always prompt for identity when setting SSH key |

You can customize these settings through the ChronoGit configuration system:

```bash
# Using the interactive menu
git chronogit

# Select option: 2) Set configuration
# Choose: workflow.ssh.keyDir
# Enter: ~/.ssh/custom-keys
```

## Use Cases

### Personal and Work Separation

```bash
# Set personal key globally (default for all repositories)
git ssh-config -g -k ~/.ssh/id_personal

# Set work key for specific repositories
cd ~/work/project
git ssh-config -k ~/.ssh/id_work -n "Work Name" -e "work@company.com"
```

### Project-Specific Keys

```bash
# Set different keys for different projects
cd ~/projects/personal
git ssh-config -k ~/.ssh/id_personal

cd ~/projects/client
git ssh-config -k ~/.ssh/id_client
```

### Branch-Specific Identities

```bash
# Use different identities for different branches
git checkout feature/personal
git ssh-config -b -k ~/.ssh/id_personal -n "Personal Name" -e "personal@example.com"

git checkout feature/work
git ssh-config -b -k ~/.ssh/id_work -n "Work Name" -e "work@company.com"
```

## Related ChronoGit Commands

- [git chronogit](chronogit.md) - Configure SSH settings through interactive menu
- [git cc](conventional-commit.md) - Create commits with the configured identity
- [git pr](open-pr.md) - Create PRs that will use the configured SSH key
- [git sync](sync.md) - Sync branches using the configured SSH key

## Useful Built-in Commands

- [git config](https://git-scm.com/docs/git-config) - View and set Git configurations
- [git remote](https://git-scm.com/docs/git-remote) - Manage repository remotes
- [ssh-keygen](https://man.openbsd.org/ssh-keygen.1) - Generate SSH keys
- [ssh-add](https://man.openbsd.org/ssh-add.1) - Add SSH keys to the SSH agent
