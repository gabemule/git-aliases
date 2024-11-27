# ✍️ Conventional Commit Command

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, with automatic ticket reference handling.

## Usage

### Basic Usage

```bash
# Show help
git cc -h

# Fully interactive mode (prompts for everything)
git cc

# Semi-interactive mode (message provided, prompts for type)
git cc -m "implement login"
```

### Options

- `-h` - Show help message
- `-m, --message <msg>` - Specify commit message
- `-s, --scope <scope>` - Specify commit scope
- `--no-scope` - Skip scope prompt and create commit without scope
- `--body <text>` - Specify commit body directly
- `--no-body` - Skip body prompt
- `-t, --ticket <id>` - Override ticket for this commit only
- `-p, --push` - Push changes after commit
- `-b, --breaking` - Mark as breaking change
- `--no-verify` - Skip commit hooks
- `--type <type>` - Specify commit type (feat, fix, docs, etc.)

## Interactive Mode

### Type Selection
Use arrow keys (↑/↓) to select commit type:
```bash
$ git cc
Select commit type:
   feat     - New feature
   fix      - Bug fix
   docs     - Documentation only changes
   style    - Changes not affecting code
   refactor - Code change that neither fixes a bug nor adds a feature
   perf     - Code change that improves performance
   test     - Adding missing tests
   chore    - Changes to build process or auxiliary tools
   ci       - Changes to CI configuration
   build    - Changes that affect the build system
```

### Full Interactive Flow

```bash
$ git cc
Select commit type: [Use arrow keys to select]
? Enter scope (optional) []: auth
? Enter short description []: implement login
? Enter commit body (optional, press Ctrl+D when finished):
- Add OAuth2 flow
- Update user model
? Is this a breaking change? (y/N) [N]:
✓ Created commit: feat(auth): implement login [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

### Semi-interactive Flow

When providing message with -m, prompts for remaining options:

```bash
$ git cc -m "implement login"
Select commit type: [Use arrow keys to select]
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

### 4. With Body

```bash
# Provide message and body directly
$ git cc -m "add feature" --body "- Added new feature\n- Updated tests"
```

### 5. Without Body

```bash
# Skip body prompt
$ git cc -m "quick fix" --no-body
```

### 6. Breaking Change

```bash
# Mark as breaking change
$ git cc -m "change api" -s api -b
# Results in:
# feat(api)!: change api [PROJ-123]
# 
# BREAKING CHANGE: Breaking changes introduced
```

### 7. Auto-push

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

## Error Handling

### No Staged Files
```bash
$ git cc -m "fix bug"
Error: No staged files. Stage your changes before committing.

# Status of your changes:
[git status output]
```

### Invalid Commit Type
```bash
$ git cc --type invalid
Invalid type: invalid
Valid types: feat fix docs style refactor perf test chore ci build
```

### Failed Commit
```bash
$ git cc -m "fix bug"
Error: Commit failed! This might be due to husky hooks or other git errors.
Please check the error message above and try again.
```

### Failed Push
```bash
$ git cc -m "fix bug" -p
Commit successful!

Auto-pushing changes...
Failed to push changes. Please push manually.
```

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

## Body Handling

1. Interactive Mode:
   - Prompts for body unless --no-body is used
   - Press Ctrl+D for no body
   - Enter text for body

2. With --body flag:
   - Uses provided body text
   - Adds as separate paragraphs in commit

3. With --no-body:
   - Skips body prompt
   - Creates commit without body

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

Breaking changes are marked in two ways:
1. Exclamation mark after type/scope
2. BREAKING CHANGE footer

Example:
```bash
$ git cc -m "change api" -b -s api
✓ Created commit: feat(api)!: change api [PROJ-123]
BREAKING CHANGE: Breaking changes introduced
```

## Related ChronoGit Commands

- [git chronogit](chronogit.md) - Configure commit settings and ticket patterns
- [git jerrypick](jerrypick.md) - Cherry-pick commits interactively
- [git open-pr](open-pr.md) - Create PR with commit history
- [git rollback](rollback.md) - Safely revert changes in the main branch
- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git sync](sync.md) - Synchronize your branch with the main branch and remote
- [git workspace](workspace.md) - Manage and switch between different workspaces

## Useful Built-in Commands

- [git stash](https://git-scm.com/docs/git-stash) - Temporarily store modified, tracked files
- [git status](https://git-scm.com/docs/git-status) - Show the working tree status
- [git log](https://git-scm.com/docs/git-log) - Show commit logs
- [git diff](https://git-scm.com/docs/git-diff) - Show changes between commits, commit and working tree, etc
