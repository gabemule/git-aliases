# ✍️ Conventional Commit Command

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, with automatic ticket reference handling.

## Usage

### Basic Usage

```bash
# Fully interactive mode (prompts for everything)
git cc

# Semi-interactive mode (message provided, prompts for type)
git cc -m "implement login"

# Non-interactive mode (for testing)
git cc -m "implement login" --type feat -s auth --non-interactive
```

### Options

- `-m, --message <msg>` - Specify commit message
- `-s, --scope <scope>` - Specify commit scope
- `--no-scope` - Skip scope prompt and create commit without scope
- `-t, --ticket <id>` - Override ticket for this commit only
- `-p, --push` - Push changes after commit
- `-b, --breaking` - Mark as breaking change
- `--no-verify` - Skip commit hooks
- `--type <type>` - Specify commit type (feat, fix, docs, etc.)

## Interactive Mode

### Full Interactive

When running without any flags, prompts for everything:

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

### Semi-interactive

When providing message with -m, prompts for remaining options:

```bash
$ git cc -m "implement login"
Select commit type:
   feat
   fix
   docs
   ...
? Enter scope (optional) []: auth
? Enter commit body (optional, press Ctrl+D when finished):
✓ Created commit: feat(auth): implement login [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

## Examples

### 1. Basic Commit

```bash
# Provide message, prompted for type and scope
$ git cc -m "fix button alignment"
```

### 2. With Scope

```bash
# Provide message and scope, prompted for type
$ git cc -m "update test" -s test
```

### 3. Without Scope

```bash
# Provide message, skip scope prompt
$ git cc -m "update readme" --no-scope
```

### 4. Breaking Change

```bash
# Mark as breaking change
$ git cc -m "change api" -s api -b
```

### 5. Auto-push

```bash
# Push after commit
$ git cc -m "update docs" -p
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

1. Interactive Mode:
   - Prompts for scope unless --no-scope is used
   - Press Enter for no scope
   - Enter value for scope

2. With -s flag:
   - Uses provided scope
   - Adds scope: feat(ui): message

3. With --no-scope:
   - Skips scope prompt
   - No scope: feat: message

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
