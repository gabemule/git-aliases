# Conventional Commit Command Updates

## Additional Flags

```bash
# Skip prompts with direct arguments
git cc -m "implement login" -s auth    # Direct message and scope
git cc -p                             # Auto-push after commit
git cc --no-verify                    # Skip commit hooks
```

### Suggested Flags

- `-m, --message <msg>` - Specify commit message (skip prompt)
- `-s, --scope <scope>` - Specify commit scope (skip prompt)
- `-p, --push` - Push changes after commit
- `--no-verify` - Skip commit hooks
- `-b, --breaking` - Mark as breaking change

### Benefits

1. Faster commits with direct arguments
2. Better CI/CD integration with non-interactive mode
3. Automated workflows with push flag
4. Consistent with git commit flags

## Implementation Notes

1. Flag Parsing:
   ```bash
   while getopts "t:m:s:pb" opt; do
       case $opt in
           t) ticket="$OPTARG" ;;
           m) message="$OPTARG" ;;
           s) scope="$OPTARG" ;;
           p) auto_push=true ;;
           b) breaking=true ;;
       esac
   done
   ```

2. Message Building:
   ```bash
   if [[ "$breaking" == true ]]; then
       commit_title="${type}${scope_part}!: ${message}"
   else
       commit_title="${type}${scope_part}: ${message}"
   fi
   ```

3. Auto Push:
   ```bash
   if [[ "$auto_push" == true ]]; then
       git push origin $(git rev-parse --abbrev-ref HEAD)
   fi
   ```

4. Type Validation:
   ```bash
   if [[ ! " ${types[@]} " =~ " ${type} " ]]; then
       echo "Invalid type: $type"
       echo "Valid types: ${types[*]}"
       exit 1
   fi
