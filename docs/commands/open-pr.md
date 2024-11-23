# 🔍 Open PR Command

Streamlines PR creation with automatic ticket reference inclusion and target branch selection.

## Prerequisites

### GitHub CLI
This command requires the GitHub CLI (gh) to be installed and authenticated:

```bash
# Install GitHub CLI
brew install gh  # macOS
winget install GitHub.cli  # Windows
# See https://cli.github.com/ for other platforms

# Authenticate
gh auth login
```

## Usage

### Basic Usage

```bash
# Show help
git open-pr -h
# or
git pr -h

# Interactive mode (full command)
git open-pr

# Interactive mode (short alias)
git pr

# With target branch
git open-pr -t production --title "Fix login bug" --body "Fixed authentication flow"

# Short alias with target
git pr -t production --title "Fix login bug" --body "Fixed authentication flow"
```

### Options

- `-h` - Show help message
- `-t, --target <branch>` - Specify target branch (development/production)
- `--title <title>` - Specify PR title
- `--body <description>` - Specify PR description
- `--draft` - Create as draft PR
- `--no-browser` - Don't open in browser
- `--no-template` - Skip PR template
- `--no-ticket` - Skip ticket references

## Branch Requirements

Your current branch must:
1. Be a valid branch type with correct prefix:
   - feature/ - For new features
   - bugfix/ - For bug fixes
   - hotfix/ - For critical fixes
   - release/ - For releases
   - docs/ - For documentation
2. Not have an existing PR to the target branch

## Interactive PR Creation

```bash
# Using full command
$ git open-pr
Select the target branch for your PR:
1) development
2) production
? 1
Enter PR title: [PROJ-123] Add user authentication
Enter PR description (press Ctrl+D when finished):
- Implement login flow
- Add password reset
- Add session management
✓ Opening PR in browser...

# Using short alias
$ git pr
Select the target branch for your PR:
1) development
2) production
? 1
Enter PR title: [PROJ-123] Add user authentication
✓ Opening PR in browser...
```

## Examples

### 1. Quick PR Creation

```bash
# Using full command
$ git open-pr -t development --title "Fix login bug"
✓ Created PR: [PROJ-123] Fix login bug
✓ Opening PR in browser...

# Using short alias
$ git pr -t development --title "Fix login bug"
✓ Created PR: [PROJ-123] Fix login bug
✓ Opening PR in browser...
```

### 2. Draft PR

```bash
# Using full command
$ git open-pr --draft
Select the target branch for your PR:
1) development
2) production
? 1
Enter PR title: [PROJ-456] WIP: Refactor auth system
✓ Created draft PR
✓ Opening PR in browser...

# Using short alias
$ git pr --draft
Select the target branch for your PR:
1) development
2) production
? 1
Enter PR title: [PROJ-456] WIP: Refactor auth system
✓ Created draft PR
✓ Opening PR in browser...
```

### 3. PR Without Browser

```bash
# Using full command
$ git open-pr -t production --title "Hotfix: Security patch" --no-browser
✓ Created PR: [PROJ-789] Hotfix: Security patch

# Using short alias
$ git pr -t production --title "Hotfix: Security patch" --no-browser
✓ Created PR: [PROJ-789] Hotfix: Security patch
```

### 4. PR Without Template

```bash
# Skip loading PR template
$ git open-pr --no-template
✓ Created PR without template
```

### 5. PR Without Ticket

```bash
# Skip ticket references
$ git open-pr --no-ticket
✓ Created PR without ticket references
```

## Error Handling

### Not in Git Repository
```bash
$ git pr
Error: This script must be run in a git repository.
```

### GitHub CLI Not Found
```bash
$ git pr
Error: GitHub CLI (gh) is not installed.
Please install it following the instructions at: https://cli.github.com/

Quick install commands:
  Homebrew (macOS): brew install gh
  Windows: winget install GitHub.cli
  Linux: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
```

### Invalid Branch Type
```bash
$ git pr
Error: You must be on a feature, bugfix, hotfix, or docs branch to open a PR.
Current branch: main
```

### Invalid Target Branch
```bash
$ git pr -t invalid
Invalid target branch: invalid
Valid targets: development, production
```

### Existing PR
```bash
$ git pr
A PR already exists for this branch: https://github.com/org/repo/pull/123
```

## Ticket Handling

The command automatically:
1. Gets ticket from branch config
2. Adds ticket reference to PR title `[PROJ-123]`
3. Adds "Related ticket: PROJ-123" to PR description
4. Links PR to ticket system

Example:
```bash
# Branch ticket: PROJ-123
$ git pr --title "Add search"
✓ Created PR: [PROJ-123] Add search

# Skip ticket references
$ git pr --title "Add search" --no-ticket
✓ Created PR: Add search
```

## Template Handling

1. Default template location: `.github/pull_request_template.md`
2. Template is automatically loaded and prepended to PR description
3. Can be skipped with --no-template flag
4. Custom template path can be configured using chronogit:
   ```bash
   git chronogit
   # Select: 2) Set configuration
   # Choose: workflow.prTemplatePath
   # Enter: custom/template.md
   ```

## Related Commands

- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git cc](conventional-commit.md) - Create commits for PR
- [git chronogit](chronogit.md) - Configure PR settings
