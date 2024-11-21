# Conventional Commit Command ✍️

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, with automatic ticket reference handling.

## Usage

### Basic Usage

```bash
# Fully interactive mode (prompts for everything)
git cc

# Message provided, prompts for type and scope
git cc -m "implement login"
```

### Options

- `-m, --message <msg>` - Specify commit message
- `-s, --scope <scope>` - Specify commit scope (optional)
- `--no-scope` - Skip scope prompt and create commit without scope
- `-t, --ticket <id>` - Override ticket for this commit only
- `-p, --push` - Push changes after commit
- `-b, --breaking` - Mark as breaking change
- `--no-verify` - Skip commit hooks

## Interactive Workflows

### 1. Fully Interactive
When running without -m flag:
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
✓ Created commit: feat(auth): implement login [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

### 2. Message Provided
When using -m flag, prompts for remaining options:
```bash
$ git cc -m "implement login"
Select commit type:
   feat
   fix
   docs
   ...
? Enter scope (optional) []: auth
✓ Created commit: feat(auth): implement login [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

### 3. Message and Scope
When using -m and -s flags:
```bash
$ git cc -m "fix alignment" -s ui
Select commit type:
   feat
   fix
   docs
   ...
✓ Created commit: fix(ui): fix alignment [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

### 4. Message without Scope
When using -m and --no-scope flags:
```bash
$ git cc -m "update docs" --no-scope
Select commit type:
   feat
   fix
   docs
   ...
✓ Created commit: docs: update docs [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

## Commit Types

| Type | Purpose | Example |
|------|---------|---------|
| feat | New features | feat(auth): add login |
| fix | Bug fixes | fix(ui): align buttons |
| docs | Documentation | docs: update readme |
| style | Code style | style(lint): format code |
| refactor | Code improvements | refactor(core): optimize flow |
| perf | Performance | perf(db): cache results |
| test | Testing | test(api): add login tests |
| chore | Maintenance | chore(deps): update packages |
| ci | CI changes | ci(deploy): update pipeline |
| build | Build system | build(webpack): optimize config |

## Scope Handling

1. No flags:
   - Prompts for scope
   - Press Enter for no scope
   - Enter value for scope

2. With -s flag:
   - Uses provided scope
   - Still prompts for type
   - Example: feat(ui): message

3. With --no-scope:
   - Skips scope prompt
   - Still prompts for type
   - Example: feat: message

## Ticket Handling

### Branch Ticket (Default)
Uses ticket from current branch (set by start-branch):
```bash
$ git cc -m "add feature"
✓ Created commit: feat(ui): add feature [PROJ-123]
```

### Override Ticket
Override for single commit:
```bash
$ git cc -m "fix bug" -t PROJ-456
✓ Created commit: feat(core): fix bug [PROJ-456]
```

## Breaking Changes

Breaking changes can be marked with -b flag:

```bash
# Will still prompt for type
$ git cc -m "change api" -b -s api
✓ Created commit: feat(api)!: change api [PROJ-123]
BREAKING CHANGE: Breaking changes introduced
```

## Related Commands

- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git open-pr](open-pr.md) - Create PR with commit history
