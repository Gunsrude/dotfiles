# Global Rules

- Never commit or push unless explicitly requested
- Save changes and wait for approval before any git operation. Never run `git add` (especially `git add .`) without first telling me what will be staged and getting approval.
- Do not add my name (Mike) to projects unless specified in other context what name to put in.
- Each git push requires a fresh explicit approval. Do not assume a previous "go ahead and push" or "push when ready" authorization applies to a different commit — always re-ask before pushing.
- When working from a task tracker, complete the specific issue and ask me to verify it's done correctly before closing it. Do not auto-close or move on to the next item without confirmation.
- Prefer making small edits to files instead of complete re-writes.

## Search Tool Usage

You have two search MCP tools available: `kagi` and `exa`. Use them as follows:

### Use `kagi_search_fetch` (Kagi) when:
- The query is general web search, current events, or news
- You need a quick factual lookup (documentation, error messages, package versions)
- The user asks "search for X" without further qualification
- You need to fetch a specific URL's content
- Searching for anything where recency matters (Kagi's index is fresher)

### Use `exa` (Exa) when:
- The query is conceptual or semantic ("find libraries that do X", "how do people solve Y")
- You need to find similar code, patterns, or approaches
- You're researching a technical topic that requires understanding, not just a link
- You need structured extraction of page content (author, date, full text) without a separate fetch
- Keyword search has already failed or returned poor results

### General rules:
- Default to `kagi_search_fetch` for most searches — it's the primary tool
- Use `exa` as the semantic/research layer when Kagi returns shallow results
- Do NOT run both tools for the same query simultaneously — pick the right one first
- If the first tool returns poor results, try the other before giving up
- Never fabricate URLs — always use a search tool to find them
