# Global Rules

- Never commit or push unless explicitly requested
- Save changes and wait for approval before any git operation. Never run `git add` (especially `git add .`) without first telling me what will be staged and getting approval.
- Do not add my name (Mike) to projects unless specified in other context what name to put in.
- Each git push requires a fresh explicit approval. Do not assume a previous "go ahead and push" or "push when ready" authorization applies to a different commit — always re-ask before pushing.
- When working from a task tracker, complete the specific issue and ask me to verify it's done correctly before closing it. Do not auto-close or move on to the next item without confirmation.
- Prefer making small edits to files instead of complete re-writes.

## Prohibited Phrases

Never use these phrases or variations:
- "Found it!" or "Found it" - Just present the results without fanfare
- "Ready to commit?" or "Do you want to commit?" - Wait for explicit instruction about committing
- Any variation of asking if the user wants to commit during active work

## Search Tool Usage

Two search tools are available via the Exa MCP server. Use them as follows:

### Use `web_search_exa` (basic) for standard searches:
- General web search for any topic
- Conceptual or semantic queries ("find libraries that do X", "how do people solve Y")
- Finding similar code, patterns, or approaches
- Researching a technical topic that needs understanding, not just a link
- General web search, current events, news, or quick factual lookups

### Use `web_search_advanced_exa` (advanced) ONLY for deep or complex research:
- Multi-faceted research topics requiring synthesis across many sources
- Company/people research (uses category filters)
- Domain-restricted searches with date range filtering
- Subpage crawling needs
- **Only activate this tool if you determine the query is a deep or highly complex research topic** — it uses more expensive API endpoints.

### General rules:
- Use `web_search_exa` for all searches as the default — it covers 90% of needs
- If basic results are poor, try `web_search_advanced_exa` before giving up
- Never fabricate URLs — always use a search tool to find them

### Parameter Defaults & Best Practices

Always use these conservative defaults unless you have a specific reason to increase them:

**For all searches:**
- `numResults`: 5 (start small, increase to 10 only if needed)
- Use highlights instead of full text when possible (10x fewer tokens)

**For highlights:**
- `highlightsMaxCharacters`: 2000 (sufficient for most factual queries)
- Include a `highlightsQuery` to guide relevance when the search query is broad

**For full text extraction (use sparingly):**
- `textMaxCharacters`: 3000 maximum for initial fetches
- Only use when you need complete context or the highlights are insufficient

**When to escalate:**
1. Start with `web_search_exa` and `numResults: 5`
2. If results are poor, try a refined query before switching tools
3. Only use `web_search_advanced_exa` for genuinely complex research requiring:
   - Domain restrictions (`includeDomains`/`excludeDomains`)
   - Date range filtering
   - Subpage crawling (`subpages` parameter)
   - Category filters (company/people research)

**Why these limits matter:**
- Default Exa behavior can return ~10,000 characters per result
- 3 searches × 10 results × 10k chars = 300k+ characters easily
- Local models process slowly with massive context — be conservative

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
