# Open PR Command 🔍

Streamlines PR creation with automatic ticket reference inclusion and target branch selection.

## Features

- Interactive target branch selection
- Automatic ticket reference inclusion
- Duplicate PR detection
- Web-based PR opening
- Title and description prompts

## Usage

### Basic Usage

```bash
git open-pr
```

## Examples

### 1. Feature Branch PR

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

### 2. Hotfix Branch PR

```bash
$ git open-pr
Select the target branch for your PR:
1) development
2) production
? 2
Enter PR title: [PROJ-456] Fix critical security issue
Enter PR description (press Ctrl+D when finished):
- Patch XSS vulnerability
- Add security headers
✓ Opening PR in browser...
```

### 3. Existing PR Detection

```bash
$ git open-pr
A PR already exists for this branch: https://github.com/org/repo/pull/123
```

## Target Branches

Available target branches:
- `development` - For feature development
- `production` - For production releases

## Ticket Handling

The command automatically:
1. Gets ticket from branch config
2. Adds ticket reference to PR title `[PROJ-123]`
3. Adds ticket reference to PR description
4. Links PR to ticket system

## Related Commands

- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git cc](conventional-commit.md) - Create commits for PR
