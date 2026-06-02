---
name: ai-git-workflow
description: |-
  Manage git branch workflow for AI-assisted coding tasks. Use when delegating coding work to senior-dev or junior-dev subagents.
  Handles branch creation (ai/<task-name>), stash management, and squash merges back to main.
  
  Use proactively when:
  - Starting any new coding task that requires file changes
  - Delegating implementation work to developer subagents
  - Preparing to commit completed work back to main
  
  Examples:
  - user: "Add a dark mode toggle" → create ai/dark-mode-toggle branch before delegating
  - user: "Fix the login bug" → create ai/fix-login bug branch, stash current work if needed
  - user: "Refactor the API handlers" → create ai/refactor-api-handlers branch
---

# AI-Assisted Git Workflow

This workflow keeps `main` clean while allowing subagents to commit freely during development.

## Before Delegating Any Coding Task

**Execute these steps in order:**

1. **Return to main**: `git checkout main`
2. **Preserve uncommitted work**: `git stash push -m "before ai task"`
3. **Create isolated branch**: `git checkout -b ai/<task-name>`

   - Use kebab-case for task name (e.g., `ai/add-user-auth`, `ai/fix-navigation-bug`)
   - Branch name should describe the work, not just "ai-task"

4. **Delegate to subagent** with clear instructions and file paths

## During Development

- Subagents make normal auto-commits on the `ai/` branch — these are temporary and will be squashed
- They run tests, verify changes, iterate freely
- **Do NOT push branches to remote** — they're local-only
- Confirm with Mike that work is completed correctly before proceeding to merge

## When Work Is Complete (Squash Merge)

**Execute these steps after subagent reports completion:**

1. `git checkout main`
2. `git merge --squash ai/<task-name>` — stages all changes as one set
3. `git commit -m "<descriptive commit message>"` — single clean commit
4. `git branch -D ai/<task-name>` — delete the working branch

## Stash Handling (Critical - Always Check)

Subagents can lose track of stashed commits. **After every squash merge:**

1. Run `git stash list`
2. If stashes are present, report them to Mike with context:
   - How many stashes
   - When they were created (from `git stash list` output)
   - Ask: apply, drop, or keep?
3. **Do NOT auto-drop stashes** without explicit approval

## Important Principles

- **You (Team Lead) own all git operations** — subagents will re-escalate if not on an `ai/` branch
- Auto-commits during work are safe because they live on temporary branches
- The final squash merge ensures `main` always has clean, meaningful commits
- Always preserve Mike's uncommitted work via stash; never lose it

## Anti-Patterns to Avoid

| Violation | Why It's Bad | Correct Approach |
|-----------|--------------|------------------|
| Delegating without creating branch | Subagent will re-escalate, wasting time | Create `ai/<task>` branch first |
| Auto-dropping stashes | Could lose Mike's work | Always ask before dropping |
| Pushing `ai/` branches to remote | Clutters remote with temp branches | Keep them local-only |
| Multiple squash merges without checking stash | Could lose intermediate work | Check `git stash list` after each merge |
