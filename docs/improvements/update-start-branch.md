# Start Branch Command Updates

## Additional Flags

```bash
# Skip prompts with direct arguments
git start-branch -t PROJ-123 -n user-authentication -b feature

# Control behavior
git start-branch --no-sync    # Skip main branch sync
git start-branch --no-stash   # Skip stashing changes
git start-branch --current    # Override: use current branch instead of main

# Shorter alias (automatically configured)
git start                    # Alias for git start-branch
```

### Suggested Flags

- `-n, --name <name>` - Specify branch name (skip prompt)
- `-b, --branch-type <type>` - Specify branch type (skip prompt)
- `--no-sync` - Skip main branch sync
- `--no-stash` - Skip stashing changes
- `--current` - Override: create branch from current branch instead of main branch (default: uses main branch)

### Branch Source Behavior

By default, new branches are created from the configured main branch:
```bash
# Default behavior: uses main branch
git start-branch -t PROJ-123
# 1. Switches to main branch
# 2. Pulls latest changes
# 3. Creates new branch

# Override: use current branch
git start-branch -t PROJ-123 --current
# Creates branch from current branch without switching to main
```

### Automatic Alias Configuration

The shorter `git start` alias will be automatically configured in our `.gitconfig` file:

```ini
[alias]
    # Existing aliases...
    start = "!f() { $HOME/path/to/git-aliases/bin/start-branch.sh $@; }; f"
```

This way, when users install our git-aliases, they automatically get access to both:
- `git start-branch` (full command)
- `git start` (shorter alias)

### Benefits

1. Faster branch creation with direct arguments
2. Better CI/CD integration with non-interactive mode
3. More control over branch source and behavior
4. Consistent with other git command patterns
5. Shorter command automatically available

## Implementation Notes

1. Flag Parsing:
   ```bash
   while getopts "t:n:b:c" opt; do
       case $opt in
           t) ticket="$OPTARG" ;;
           n) branch_name="$OPTARG" ;;
           b) branch_type="$OPTARG" ;;
           c) use_current_branch=true ;;
       esac
   done
   ```

2. Branch Source Selection:
   ```bash
   # Default: use main branch
   source_branch=$main_branch
   if [[ "$no_sync" != true ]]; then
       git checkout $main_branch
       git pull origin $main_branch
   fi

   # Override with --current flag
   if [[ "$use_current_branch" == true ]]; then
       source_branch=$(git rev-parse --abbrev-ref HEAD)
   fi
   ```

3. Error Handling:
   ```bash
   if [[ ! "$branch_type" =~ ^(feature|bugfix|hotfix|release|docs)$ ]]; then
       echo "Invalid branch type: $branch_type"
       exit 1
   fi
   ```

4. .gitconfig Updates:
   ```bash
   # In .gitconfig
   [alias]
       start = "!f() { $HOME/path/to/git-aliases/bin/start-branch.sh $@; }; f"
       # This ensures the alias is automatically available after installation
