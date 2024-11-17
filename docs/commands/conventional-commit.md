# Conventional Commit Command ✍️

Creates standardized commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification, with automatic ticket reference handling.

## Features

- Interactive type selection
- Optional scope support
- Breaking change detection
- Automatic ticket reference inclusion
- Optional one-time ticket override
- Optional body/description
- Push changes prompt

## Usage

### Basic Usage

```bash
git cc
```

### Options

- `-t <ticket>` - Override ticket for this commit only (e.g., PROJ-123)

## Examples

### 1. Basic Commit

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
? Is this a breaking change? (y/N) [N]:
✓ Created commit: feat(auth): implement login [PROJ-123]
? Do you want to push the changes now? (Y/n)
```

### 2. Override Ticket

```bash
$ git cc -t PROJ-456
Select commit type:
   feat
   fix
   docs
? Enter scope (optional) []: ui
? Enter short description []: correct button alignment
✓ Created commit: fix(ui): correct button alignment [PROJ-456]
```

### 3. Breaking Change

```bash
$ git cc
Select commit type: feat
? Enter scope (optional) []: api
? Enter short description []: change authentication flow
? Enter commit body (optional, press Ctrl+D when finished):
- Switch to OAuth2
- Remove basic auth
? Is this a breaking change? (y/N) [N]: y
? Describe the breaking change: Basic auth no longer supported
✓ Created commit: feat(api)!: change authentication flow [PROJ-123]
BREAKING CHANGE: Basic auth no longer supported
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

## Related Commands

- [git start-branch](start-branch.md) - Create branches with ticket tracking
- [git open-pr](open-pr.md) - Create PR with commit history
