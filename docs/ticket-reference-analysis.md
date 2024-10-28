# Git Ticket Reference Analysis: Industry Practices

## Common Approaches

### 1. Ticket in Branch Name
```bash
feature/PROJ-123-user-auth
bugfix/PROJ-456-login-fix
```

#### Pros
- Immediately visible which ticket branch relates to
- Easy to see ticket context in PR
- Some CI/CD systems can auto-link PRs to tickets
- Forces one branch per ticket
- Helps enforce work item isolation

#### Cons
- Clutters branch names
- Makes branch names longer
- Can be redundant with commit messages
- Complicates branch naming convention
- Can be problematic with multiple tickets

### 2. Ticket in Commits Only
```bash
feat(auth): implement login [PROJ-123]
fix(auth): correct validation [PROJ-123]
```

#### Pros
- Creates permanent historical reference
- Enables powerful searching (`git log --grep`)
- Cleaner branch names
- More flexible (can reference multiple tickets)
- Better aligned with conventional commits

#### Cons
- Less visible which ticket branch is for
- Requires discipline to include in every commit
- May need tooling to enforce
- Can forget to include ticket number

### 3. Both Branch and Commits
```bash
# Branch
feature/PROJ-123-user-auth

# Commits
feat(auth): implement login [PROJ-123]
fix(auth): correct validation [PROJ-123]
```

#### Pros
- Maximum traceability
- Redundancy can help ensure nothing is missed
- Clear connection at all levels

#### Cons
- Redundant information
- More complex to maintain
- Cluttered naming
- Overkill for most projects

## Industry Best Practices

### 1. Google's Approach
- Uses change IDs in commits
- Keeps branch names descriptive
- Focuses on commit message quality
- Emphasizes searchable history

### 2. GitLab's Practice
- Includes issue numbers in commits
- Uses descriptive branch names
- Leverages merge request descriptions for issue linking
- Emphasizes automated tooling

### 3. Atlassian's Guidelines
- Recommends ticket numbers in commits
- Suggests clean, descriptive branch names
- Focuses on searchable history
- Emphasizes automation over manual processes

## Analysis of Common Tools

### 1. GitHub
- Auto-links issues mentioned in commits
- Provides powerful search across commits
- Branch names don't affect issue linking
- Focuses on commit messages for references

### 2. GitLab
- Similar to GitHub
- Strong commit message parsing
- Branch names used for UI/UX
- Emphasizes commit-based tracking

### 3. Bitbucket
- Integrates well with Jira
- Uses smart commits
- Branch names for display
- Commit messages for tracking

## Real-World Examples

### Linux Kernel
- Uses descriptive branch names
- Includes references in commit messages
- Focuses on commit message quality
- Clean branch naming

### VS Code
- Uses issue numbers in commits
- Keeps branch names descriptive
- Automated issue linking
- Clean branch structure

## Conclusion Based on Evidence

### Recommended Approach: Tickets in Commits Only

1. **Why This Works Better**
   - Aligns with industry leaders' practices
   - Maintains clean branch names
   - Provides permanent tracking
   - More flexible and maintainable

2. **Supporting Factors**
   - Most major tools focus on commit messages
   - Better integration with automation
   - Cleaner workflow
   - More scalable approach

3. **Best Implementation**
   ```bash
   # Branch name (clean, descriptive)
   feature/user-authentication

   # Commits (with ticket reference)
   feat(auth): implement login [PROJ-123]
   fix(auth): correct validation [PROJ-123]
   docs(auth): update API docs [PROJ-123]
   ```

4. **Key Benefits**
   - Clean, readable branch names
   - Permanent historical tracking
   - Better tool integration
   - More flexible workflow
   - Easier maintenance

## Recommendations for Implementation

1. **Tooling**
   - Add ticket reference prompt to commit script
   - Implement validation
   - Add search helpers
   - Create commit hooks if needed

2. **Process**
   - Keep branch names descriptive
   - Always include tickets in commits
   - Use automated tools
   - Maintain consistent format

3. **Documentation**
   - Clear guidelines
   - Examples
   - Search tips
   - Best practices

This analysis shows that keeping ticket references in commits only is the most balanced and effective approach, supported by industry practices and tool capabilities.
