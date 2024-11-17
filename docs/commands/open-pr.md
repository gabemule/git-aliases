# Open PR Command 🔍

Streamlines PR creation with automatic ticket reference inclusion and target branch selection.

## Usage

### Basic Usage

```bash
# Interactive mode
git open-pr

# Non-interactive mode
git open-pr -t production --title "Fix login bug" --body "Fixed authentication flow"
```

### Options

- `-t, --target <branch>` - Specify target branch (development/production)
- `--title <title>` - Specify PR title
- `--body <description>` - Specify PR description
- `--draft` - Create as draft PR
- `--no-browser` - Don't open in browser

## Examples

### 1. Interactive PR Creation

```bash
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
```

### 2. Quick PR Creation

```bash
$ git open-pr -t development --title "Fix login bug"
✓ Created PR: [PROJ-123] Fix login bug
✓ Opening PR in browser...
```

### 3. Draft PR

```bash
$ git open-pr --draft
Select the target branch for your PR:
1) development
2) production
? 1
Enter PR title: [PROJ-456] WIP: Refactor auth system
✓ Created draft PR
✓ Opening PR in browser...
```

### 4. PR Without Browser

```bash
$ git open-pr -t production --title "Hotfix: Security patch" --no-browser
✓ Created PR: [PROJ-789] Hotfix: Security patch
```

### 5. PR with Template

```bash
$ git open-pr
Select the target branch for your PR:
1) development
2) production
? 1
Enter PR title: [PROJ-123] Add search feature
Enter PR description (press Ctrl+D when finished):
[Template loaded from .github/pull_request_template.md]

Changes:
- Implement search functionality
- Add search results page
- Add pagination
✓ Opening PR in browser...
```

## Target Branches

Available target branches:
- `development` - For feature development
- `production` - For production releases

## PR Templates

The command automatically loads PR templates from:
```
.github/pull_request_template.md
```

If a template exists, it will be included in the PR description.

## Ticket Handling

The command automatically:
1. Gets ticket from branch config
2. Adds ticket reference to PR title `[PROJ-123]`
3. Adds ticket reference to PR description
4. Links PR to ticket system

Example:
```bash
# Branch ticket: PROJ-123
$ git open-pr --title "Add search"
✓ Created PR: [PROJ-123] Add search
```

## Related Commands

- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git cc](conventional-commit.md) - Create commits for PR
