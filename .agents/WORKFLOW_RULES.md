# Cloud Agent Workflow Rules

## Mandatory Workflow for All Changes

### 1. Always Create an Issue FIRST
- **REQUIRED**: Create a GitHub issue before starting work
- Use clear, descriptive titles
- **MUST SET**:
  - **Assignees**: Assign to yourself or team member
  - **Labels**: Use appropriate labels (bug, feature, documentation, enhancement, etc.)
  - **Milestone**: Link to current sprint/release milestone if applicable
  - **Projects**: Add to relevant project board if exists
  - **Relationships**: Link related issues if applicable
  - **Development**: Link branch when created
- Include in description:
  - Problem description
  - Proposed solution
  - Acceptance criteria
- Get the issue number to reference in commits and PR

### 2. Always Create a Branch
- **NEVER** commit directly to `main`
- Always create a feature branch: `cursor/<descriptive-name>-6df9`
- Use lowercase and kebab-case for branch names
- Branch name should reflect the issue being addressed

### 3. Always Create a Pull Request
- **REQUIRED**: Every branch MUST have an associated Pull Request
- Create PR immediately after pushing the branch
- **NEVER** leave branches without PRs
- PR should be created even if you plan to merge immediately

### 4. PR Requirements
- **Title**: Clear, descriptive title starting with conventional commit type (feat:, fix:, chore:, etc.)
- **Description**: Include:
  - What changes were made
  - Why the changes were necessary
  - How to verify the changes
  - Any breaking changes or migration notes
- **Draft Status**: Create as draft if work is in progress, mark ready when complete
- **Reviewers**: Tag appropriate reviewers if known

### 5. After Merge
- **REQUIRED**: Delete the branch after merging
- Use GitHub's automatic branch deletion setting OR
- Manually delete with: `git push origin --delete <branch-name>`
- Clean up local branches: `git branch -d <branch-name>`

### 6. Commit Messages
- Follow conventional commits format
- Be descriptive about what and why
- Reference issue numbers when applicable

## Example Workflow

```bash
# 1. Create issue FIRST
gh issue create --title "Add new feature" \
  --body "Problem: ...\nSolution: ...\nAcceptance Criteria: ..." \
  --label "enhancement"
# Note the issue number (e.g., #123)

# 2. Create and checkout branch
git checkout -b cursor/add-new-feature-6df9

# 3. Make changes
# ... edit files ...

# 4. Commit changes (reference issue)
git add .
git commit -m "feat: add new feature

Implements XYZ functionality to solve ABC problem.

Resolves #123"

# 5. Push branch
git push -u origin cursor/add-new-feature-6df9

# 6. Create PR immediately (reference issue)
gh pr create --title "feat: add new feature" \
  --body "Resolves #123\n\nDescription of changes..." \
  --base main

# 7. After approval and merge
git push origin --delete cursor/add-new-feature-6df9
git branch -d cursor/add-new-feature-6df9
```

## Why These Rules Exist

1. **Traceability**: Every change has a clear history and discussion
2. **Review Process**: Changes can be reviewed before merging
3. **Rollback**: Easy to identify and revert problematic changes
4. **Collaboration**: Team members can see what's being worked on
5. **Clean Repository**: No orphaned branches cluttering the repo
6. **Automation**: CI/CD can run on PRs before merge

## Exceptions

The ONLY exception is urgent hotfixes where:
1. The main branch is broken
2. Immediate fix is needed to unblock others
3. Even then, create a PR retroactively for documentation

## Branch Cleanup

Regularly check for stale branches:
```bash
# List branches without PRs
gh api /repos/OWNER/REPO/branches | jq -r '.[].name' | \
  while read branch; do
    if ! gh pr list --head "$branch" --state all | grep -q .; then
      echo "⚠️  Branch without PR: $branch"
    fi
  done
```

## Automated Enforcement

Consider enabling these GitHub branch protection rules:
- Require pull request before merging
- Require status checks to pass
- Require branches to be up to date
- Automatically delete head branches after merge

---

**Remember**: Always Issue → Always Branch → Always PR → Always Delete After Merge

The complete flow is:
1. 🎫 **Create Issue** - Document the problem/feature
2. 🌿 **Create Branch** - Start work in isolation
3. 📝 **Make Changes** - Implement the solution
4. 🔀 **Create PR** - Request review (reference issue)
5. ✅ **Merge** - After approval
6. 🗑️ **Delete Branch** - Keep repo clean
