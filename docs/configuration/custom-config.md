# 🛠️ Custom Configuration

Complete guide to all available ChronoGit configurations and their underlying git commands.

## Configuration Structure

### Global Configuration (~/.gitconfig)
```ini
[workflow]
    # Branch settings
    mainBranch = production      # Default branch for repository
    defaultTarget = development  # Default PR target
    
    # Branch prefixes
    featurePrefix = feature/     # Feature branch prefix
    bugfixPrefix = bugfix/      # Bugfix branch prefix
    hotfixPrefix = hotfix/      # Hotfix branch prefix
    releasePrefix = release/    # Release branch prefix
    docsPrefix = docs/         # Documentation branch prefix
    
    # Ticket settings
    ticketPattern = ^[A-Z]+-[0-9]+$  # Ticket reference pattern
    
    # PR settings
    prTemplatePath = .github/pull_request_template.md  # PR template location

    # Mergetool settings
    mergetool =                 # Preferred mergetool
    mergetoolAuto = false       # Auto-launch mergetool on conflicts
    mergetool.path =            # Custom path to mergetool binary
    mergetool.args =            # Additional mergetool arguments
    
    # SSH settings
    ssh.keyDir = ~/.ssh         # Directory for SSH keys
    ssh.confirmChange = true    # Confirm before changing SSH key
    ssh.displayFormat = both    # SSH key display format (name, comment, both)
    ssh.promptIdentity = true   # Always prompt for identity when setting SSH key
```

### Local Configuration (.git/config)
```ini
[workflow]
    # Repository-specific overrides
    mainBranch = main
    defaultTarget = staging
    ticketPattern = ^TEAM-[0-9]+$
    mergetool = kdiff3
    mergetoolAuto = true
```

### Branch Configuration
```ini
[branch "feature/task"]
    ticket = PROJ-123  # Ticket reference for this branch
```

## Direct Git Commands

### View Configuration

```bash
# View all workflow settings
git config --list | grep workflow

# View specific setting (checks all levels)
git config workflow.mainBranch

# View global setting only
git config --global workflow.mainBranch

# View local setting only
git config --local workflow.mainBranch

# View branch setting
git config branch.feature/task.ticket

# Show setting source
git config --show-origin workflow.mainBranch
```

### Set Configuration

```bash
# Set global setting
git config --global workflow.mainBranch main

# Set local setting
git config --local workflow.defaultTarget staging

# Set branch ticket
git config branch.feature/task.ticket PROJ-123

# Set mergetool
git config workflow.mergetool kdiff3

# Enable auto-launch of mergetool
git config workflow.mergetoolAuto true
```

### Remove Configuration

```bash
# Remove global setting
git config --global --unset workflow.mainBranch

# Remove local setting
git config --local --unset workflow.defaultTarget

# Remove branch setting
git config --unset branch.feature/task.ticket
```

## Available Settings

### Branch Settings

| Setting | Default | Description | Command to View | Command to Set |
|---------|---------|-------------|-----------------|----------------|
| workflow.mainBranch | production | Main branch for repository | `git config workflow.mainBranch` | `git config workflow.mainBranch main` |
| workflow.defaultTarget | development | Default target for PRs | `git config workflow.defaultTarget` | `git config workflow.defaultTarget staging` |
| workflow.featurePrefix | feature/ | Feature branch prefix | `git config workflow.featurePrefix` | `git config workflow.featurePrefix feat/` |
| workflow.bugfixPrefix | bugfix/ | Bugfix branch prefix | `git config workflow.bugfixPrefix` | `git config workflow.bugfixPrefix fix/` |
| workflow.hotfixPrefix | hotfix/ | Hotfix branch prefix | `git config workflow.hotfixPrefix` | `git config workflow.hotfixPrefix hotfix/` |
| workflow.releasePrefix | release/ | Release branch prefix | `git config workflow.releasePrefix` | `git config workflow.releasePrefix rel/` |
| workflow.docsPrefix | docs/ | Documentation branch prefix | `git config workflow.docsPrefix` | `git config workflow.docsPrefix docs/` |

### Ticket Settings

| Setting | Default | Description | Command to View | Command to Set |
|---------|---------|-------------|-----------------|----------------|
| workflow.ticketPattern | ^[A-Z]+-[0-9]+$ | Pattern for ticket references | `git config workflow.ticketPattern` | `git config workflow.ticketPattern "^TEAM-[0-9]+$"` |
| branch.*.ticket | - | Branch's ticket reference | `git config branch.feature/task.ticket` | `git config branch.feature/task.ticket PROJ-123` |

### PR Settings

| Setting | Default | Description | Command to View | Command to Set |
|---------|---------|-------------|-----------------|----------------|
| workflow.prTemplatePath | .github/pull_request_template.md | Path to PR template | `git config workflow.prTemplatePath` | `git config workflow.prTemplatePath .github/custom-template.md` |

### Mergetool Settings

| Setting | Default | Description | Command to View | Command to Set |
|---------|---------|-------------|-----------------|----------------|
| workflow.mergetool | - | Preferred mergetool | `git config workflow.mergetool` | `git config workflow.mergetool kdiff3` |
| workflow.mergetoolAuto | false | Auto-launch mergetool on conflicts | `git config workflow.mergetoolAuto` | `git config workflow.mergetoolAuto true` |
| workflow.mergetool.path | - | Custom path to mergetool binary | `git config workflow.mergetool.path` | `git config workflow.mergetool.path /usr/local/bin/kdiff3` |
| workflow.mergetool.args | - | Additional mergetool arguments | `git config workflow.mergetool.args` | `git config workflow.mergetool.args "--auto"` |

### SSH Settings

| Setting | Default | Description | Command to View | Command to Set |
|---------|---------|-------------|-----------------|----------------|
| workflow.ssh.keyDir | ~/.ssh | Directory for SSH keys | `git config workflow.ssh.keyDir` | `git config workflow.ssh.keyDir ~/.ssh/custom-keys` |
| workflow.ssh.confirmChange | true | Confirm before changing SSH key | `git config workflow.ssh.confirmChange` | `git config workflow.ssh.confirmChange false` |
| workflow.ssh.displayFormat | both | SSH key display format (name, comment, both) | `git config workflow.ssh.displayFormat` | `git config workflow.ssh.displayFormat name` |
| workflow.ssh.promptIdentity | true | Always prompt for identity when setting SSH key | `git config workflow.ssh.promptIdentity` | `git config workflow.ssh.promptIdentity false` |

## Under the Hood

### Branch Creation
- `workflow.mainBranch`: Used by start-branch to determine source branch
- `workflow.*Prefix`: Used to prefix branch names based on type
- Branch ticket is stored using `branch.<name>.ticket`

### SSH Configuration
- `core.sshCommand`: Used by ssh-config to set repository-specific SSH key
- `user.name` and `user.email`: Used to set repository-specific identity
- `workflow.ssh.*`: Used to customize SSH key management behavior

### Commit Creation
- Branch ticket is read from `branch.<name>.ticket`
- Can be overridden with -t flag
- Ticket pattern validated against `workflow.ticketPattern`

### PR Creation
- Default target from `workflow.defaultTarget`
- Template loaded from `workflow.prTemplatePath`
- Ticket reference from `branch.<name>.ticket`

### Conflict Resolution
- Mergetool is determined by `workflow.mergetool`
- Auto-launch behavior controlled by `workflow.mergetoolAuto`
- Custom path and arguments used if specified in `workflow.mergetool.path` and `workflow.mergetool.args`

## Examples

### Team Setup
```ini
# In ~/.gitconfig
[workflow]
    mainBranch = main
    defaultTarget = development
    ticketPattern = ^TEAM-[0-9]+$
    mergetool = vscode
    mergetoolAuto = true
```

### Project Setup
```ini
# In .git/config
[workflow]
    mainBranch = develop
    defaultTarget = staging
    featurePrefix = feat/
    mergetool = kdiff3
    mergetool.path = /usr/local/bin/kdiff3
```

### Branch Ticket
```ini
# In git config
[branch "feat/login"]
    ticket = TEAM-123
```

## Related Documentation

- [Configuration Guide](README.md) - Main configuration guide
- [chronogit command](../commands/chronogit.md) - Interactive configuration management
- [Installation Guide](../installation/README.md) - Initial setup
- [Troubleshooting](../installation/troubleshooting.md) - Common issues
- [Mergetool Integration](../workflow/mergetool-integration.md) - Detailed guide on mergetool integration
