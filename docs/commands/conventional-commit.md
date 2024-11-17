# Conventional Commit Command ✍️

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, with automatic ticket reference handling.

## Usage

### Basic Usage

```bash
# Interactive mode
git cc

# Non-interactive mode
git cc -t PROJ-123 -m "implement login" -s auth -p
```

### Options

- `-t, --ticket <id>` - Override ticket for this commit only
- `-m, --message <msg>` - Specify commit message (skip prompt)
- `-s, --scope <scope>` - Specify commit scope (skip prompt)
- `-p, --push` - Push changes after commit
- `-b, --breaking` - Mark as breaking change
- `--no-verify` - Skip commit hooks
- `--type <type>` - Specify commit type (skip prompt)

## Examples

### 1. Interactive Commit

```bash
$ git cc
Select commit type:
   feat
   fix
   docs
   style
   refactor
   perf
   test
   chore
   ci
   build
? Enter scope (optional) []: auth
? Enter short description []: implement login
? Enter commit body (optional, press Ctrl+D when finished):
- Add OAuth2 flow
- Update user model
? Is this a breaking change? (y/N) [N]:
✓ Created commit: feat(auth): implement login [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

### 2. Quick Commit with Scope

```bash
$ git cc -m "fix button alignment" -s ui
✓ Created commit: fix(ui): fix button alignment [PROJ-123]
```

### 3. Breaking Change

```bash
$ git cc -m "change auth flow" -s api -b
✓ Created commit: feat(api)!: change auth flow [PROJ-123]
BREAKING CHANGE: Breaking changes introduced
```

### 4. Auto-push

```bash
$ git cc -m "update docs" -s readme -p
✓ Created commit: docs(readme): update docs [PROJ-123]
✓ Pushed changes to origin
```

### 5. Skip Hooks

```bash
$ git cc -m "quick fix" --no-verify
✓ Created commit: fix: quick fix [PROJ-123]
```

## Commit Types

| Type | Purpose | Example |
|------|---------|---------|
| feat | New features | feat(auth): add login |
| fix | Bug fixes | fix(ui): align buttons |
| docs | Documentation | docs(api): update endpoints |
| style | Code style | style(lint): format code |
| refactor | Code improvements | refactor(core): optimize flow |
| perf | Performance | perf(db): cache results |
| test | Testing | test(api): add login tests |
| chore | Maintenance | chore(deps): update packages |
| ci | CI changes | ci(deploy): update pipeline |
| build | Build system | build(webpack): optimize config |

## Ticket Handling

### Branch Ticket (Default)
Uses ticket from current branch (set by start-branch):
```bash
$ git cc
✓ Using ticket PROJ-123 from branch config
```

### Override Ticket
Override for single commit:
```bash
$ git cc -t PROJ-456
✓ Using override ticket PROJ-456 for this commit
```

## Breaking Changes

Breaking changes can be marked in two ways:

1. Interactive prompt:
```bash
$ git cc
? Is this a breaking change? (y/N) [N]: y
✓ Created commit: feat(api)!: change auth flow [PROJ-123]
BREAKING CHANGE: Breaking changes introduced
```

2. Direct flag:
```bash
$ git cc -m "change api" -b
✓ Created commit: feat(api)!: change api [PROJ-123]
BREAKING CHANGE: Breaking changes introduced
```

## Related Commands

- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git open-pr](open-pr.md) - Create PR with commit history
