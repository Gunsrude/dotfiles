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

## Why This Workflow Exists

This workflow exists to solve ONE problem: **keeping Mike's main branch clean while allowing AI to iterate freely.**

- AI makes mistakes and needs to commit frequently during development
- Without this workflow, main gets cluttered with "WIP", "fix typo", "try something" commits
- The `ai/` branch is a scratchpad — all commits there will be squashed into one clean commit
- Mike can request changes, corrections, additions — all happen on the branch without affecting main
- Only when Mike explicitly says the work is complete does it merge to main

**This is industry best practice.** GitHub's agentic workflows documentation explicitly states that "pull requests are never merged automatically, and humans must always review and approve." This workflow implements that principle locally.

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

## Critical: When to Squash Merge

**ONLY squash merge when Mike explicitly confirms the work is complete.**

**This is the most common failure mode:** AI makes one change, immediately squashes to main without checking if Mike wants more changes or corrections.

**Correct flow:**
1. Create branch → delegate → senior-dev completes task
2. Report to Mike: "Changes complete, here's what was done"
3. Wait for Mike to review and either:
   - Request more changes (stay on branch, delegate again)
   - Confirm work is done (THEN squash merge)
4. Never auto-squash after first change

**GitHub's official guidance:** "Pull requests are never merged automatically, and humans must always review and approve." This applies to local workflows too — never auto-merge without explicit confirmation.

## Track Work State

After delegating to senior-dev, track the state of the work:

- **IN PROGRESS**: Senior-dev is working or just completed. Wait for Mike's feedback.
- **MORE CHANGES NEEDED**: Mike requested corrections. Stay on branch, delegate again.
- **COMPLETE**: Mike confirmed work is satisfactory. NOW squash merge.

**Do not transition to COMPLETE without explicit confirmation from Mike.**

When reporting to Mike after senior-dev completes work, say:
- "Senior-dev has completed [task]. Changes include: [list files and changes]"
- "Waiting for your review before squashing to main."

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
| Squashing after single change | Mike may want corrections or additions | Wait for explicit "work is complete" confirmation |
| Creating branch AFTER changes made | Commits end up on wrong branch | Create branch BEFORE any delegation |
| Assuming work is complete without asking | Mike may have additional requests | Always ask: "Is this complete or do you need changes?" |

## What to Report to Mike

**After branch creation:**
"Created branch `ai/<task-name>`. Ready to delegate to senior-dev."

**After senior-dev completes:**
"Senior-dev has completed [task]. Changes include:
- File X: description
- File Y: description

Waiting for your review before squashing to main."

**After squash merge:**
"Squashed `ai/<task-name>` to main with commit message: '<message>'
Branch deleted. Stash check: [report git stash list output]"
