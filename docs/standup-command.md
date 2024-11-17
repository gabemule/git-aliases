# Git Standup Command

## Description
Generates a summary of your recent work across all branches, including commits and work in progress. Perfect for daily standups or weekly reports.

## Features
- Cross-branch work summary
- Work in progress display
- Customizable time range
- Author filtering
- Commit message formatting

## Example Usage
```bash
# Show today's work
$ git standup
Work by dev@company.com since 1 day ago:
==============================

Branch: feature/user-auth
abc123 feat: implement login form [PROJ-123]
def456 test: add login tests [PROJ-123]

Branch: bugfix/nav
ghi789 fix: correct dropdown position [PROJ-124]

Current work in progress:
 M src/components/Login.js
 A src/styles/auth.css

# Show work since last week
$ git standup "1 week ago"

# Show specific author's work
$ git standup "2 days ago" "other.dev@company.com"
```

## Pros and Cons

### Pros
- Quick overview of recent work
- Includes work across all branches
- Shows work in progress
- Customizable time range
- Perfect for standups
- Helps with progress tracking

### Cons
- May show too much information
- Could miss work if commits aren't pushed
- Might need filtering for large projects
- Depends on good commit messages
- Could be noisy in large teams

## Implementation
```bash
#!/bin/bash

show_standup() {
    # Default to last working day
    since=${1:-"1 day ago"}
    author=${2:-$(git config user.email)}
    
    echo "Work by $author since $since:"
    echo "=============================="
    
    # Get all branches worked on
    branches=$(git log --all --since="$since" --author="$author" --format="%D" | grep -v "^$" | sort -u)
    
    while IFS= read -r branch; do
        if [ ! -z "$branch" ]; then
            echo -e "\nBranch: $branch"
            git log --since="$since" --author="$author" --format="%h %s" "$branch"
        fi
    done <<< "$branches"
    
    # Show current work in progress
    if [[ -n $(git status -s) ]]; then
        echo -e "\nCurrent work in progress:"
        git status -s
    fi
}
```

## Future Improvements
1. Add team summary mode
2. Add Markdown/HTML output
3. Add statistics (commits per day, lines changed)
4. Add PR status integration
5. Add JIRA/ticket integration
6. Add custom format templates
7. Add time tracking integration

## Integration
- Works with any git workflow
- Supports team communication
- Integrates with agile processes
- Compatible with CI/CD reporting
- Can feed into time tracking systems
