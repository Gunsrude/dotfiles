# Global Rules

- Never commit or push unless explicitly requested
- Save changes and wait for approval before any git operation. Never run `git add` (especially `git add .`) without first telling me what will be staged and getting approval.
- Do not add my name (Mike) to projects unless specified in other context what name to put in.
- Each git push requires a fresh explicit approval. Do not assume a previous "go ahead and push" or "push when ready" authorization applies to a different commit — always re-ask before pushing.
- When working from a task tracker, complete the specific issue and ask me to verify it's done correctly before closing it. Do not auto-close or move on to the next item without confirmation.
- Prefer making small edits to files instead of complete re-writes.

## Search Tool Usage

You have one search MCP tool available: `exa`. Use it as follows:

### Use `exa` (Exa) when:
- You need web search results for any query
- The query is conceptual or semantic ("find libraries that do X", "how do people solve Y")
- You need to find similar code, patterns, or approaches
- You're researching a technical topic that requires understanding, not just a link
- You need structured extraction of page content (author, date, full text) without a separate fetch
- You need general web search, current events, news, or quick factual lookups

### General rules:
- Use `exa` for all searches — it is the primary and only search tool
- If results are poor, refine your query and try again
- Never fabricate URLs — always use a search tool to find them

## AI-Assisted Git Workflow

When working on any task, follow this branch-based workflow to keep main clean:

### When starting work
1. `git checkout main` — ensure we're on main
2. `git stash push -m "before ai task"` — stash any uncommitted changes (preserves them for later)
3. `git checkout -b ai/<task-name>` — create an isolated working branch

### During work
- Make normal auto-commits as you work. These are temporary and will be squashed.
- Run tests, verify changes, iterate freely.
- Do NOT push branches to remote.

### When work is complete (squash merge back to main)
1. `git checkout main`
2. `git merge --squash ai/<task-name>` — stage all changes as one set
3. `git commit -m "<single meaningful, descriptive commit message>"` — one clean commit
4. `git branch -D ai/<task-name>` — delete the working branch

### Stash handling (always check after merging)
Coding bots can lose track of stashed commits. After every squash merge:
1. Run `git stash list`
2. If there are stashes present, report them to the user and ask how to handle each one (apply, drop, or keep).
3. Do NOT auto-drop stashes without asking.

### Important notes
- This workflow replaces the "never commit" rule — auto-commits during work are expected and safe because they live on a temporary branch.
- The final squash merge ensures main always has clean, meaningful commits.
- Always preserve user's uncommitted work via stash; never lose it.
