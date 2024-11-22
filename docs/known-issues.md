# Known Issues & Behaviors

## Git Alias Help Flag Behavior

### Issue Description
When using `--help` with git aliases, git shows the alias configuration instead of the command's help message:

```bash
$ git cc --help
'cc' is aliased to '!bash $(dirname $(git config --get include.path))/bin/conventional-commit.sh'
```

### Solution
Use the short `-h` flag instead to see the command's help message:

```bash
$ git cc -h
Usage: git cc [options]

Create a commit following conventional commit format

Options:
  -t <id>          Override ticket for this commit
  -m <msg>         Specify commit message
  ...
```

This behavior applies to all our git aliases:
- `git cc -h`
- `git start-branch -h` (or `git start -h`)
- `git open-pr -h` (or `git pr -h`)
- `git chronogit -h`

### Technical Details
This is standard git behavior - when using `--help` with an alias:
1. Git intercepts the flag before executing the alias
2. Git displays the alias definition instead of passing the flag to the aliased command
3. This is by design to help users understand what commands their aliases map to

Using `-h` bypasses this behavior, allowing the flag to reach our scripts and display their help messages.
