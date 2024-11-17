# Open PR Command Updates

## Additional Flags

```bash
# Skip prompts with direct arguments
git open-pr -t production              # Target branch
git open-pr --title "Fix login bug"    # PR title
git open-pr --body "Bug fixes"         # PR description
git open-pr --draft                    # Create draft PR
```

### Suggested Flags

- `-t, --target <branch>` - Specify target branch
- `--title <title>` - Specify PR title
- `--body <description>` - Specify PR description
- `--draft` - Create as draft PR
- `--no-browser` - Don't open in browser

### Benefits

1. Faster PR creation with direct arguments
2. Better CI/CD integration with non-interactive mode
3. Support for draft PRs
4. Consistent with gh pr create flags

## Implementation Notes

1. Flag Parsing:
   ```bash
   while getopts "t:b:" opt; do
       case $opt in
           t) target="$OPTARG" ;;
           b) body="$OPTARG" ;;
       esac
   done
   ```

2. Target Branch Validation:
   ```bash
   if [[ ! "$target" =~ ^(development|production)$ ]]; then
       echo "Invalid target branch: $target"
       echo "Valid targets: development, production"
       exit 1
   fi
   ```

3. Draft PR Support:
   ```bash
   if [[ "$draft" == true ]]; then
       gh_args="--draft"
   fi
   gh pr create $gh_args --base "$target" --head "$current_branch" --title "$title" --body "$body"
   ```

4. Browser Control:
   ```bash
   if [[ "$no_browser" != true ]]; then
       gh pr view --web
   fi
   ```

## Additional Features

1. **Template Support**
   ```bash
   # Load PR template if exists
   if [[ -f .github/pull_request_template.md ]]; then
       template=$(cat .github/pull_request_template.md)
       body="$template\n\n$body"
   fi
   ```

2. **Labels & Reviewers**
   ```bash
   git open-pr --label "bug" --reviewer "username"
   ```

3. **Auto-merge Settings**
   ```bash
   git open-pr --auto-merge --merge-method squash
