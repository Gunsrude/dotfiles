---
description: Guidelines and template for creating effective AI agent prompts. Use when designing new sub-agents or rewriting existing ones.
---

# AI Agent Design Skill

Use this skill when creating new agent prompts or rewriting existing ones. These rules prevent common failures: agents that don't delegate, agents that barrel ahead failing, and agents that ignore instructions.

## Core Rules

**1. Positive framing only**

Models ignore negation and pattern-match on action verbs. Write what TO do, not what NOT to do.

| Instead of | Write |
|---|---|
| "Do not guess" | "Research unknown information before proceeding" |
| "Don't ask questions" | "Report findings and observations" |
| "Never assume destructive changes" | "Require explicit approval for destructive changes" |
| "Don't push past failures" | "Stop after repeated failures and report" |

**2. Explicit tool-calling language**

Agents need to be told to call tools, not just told what to delegate. Include the exact command.

| Instead of | Write |
|---|---|
| "Delegate to quick-research" | "Call the \`task\` tool with \`quick-research\`" |
| "Use file-explorer to find files" | "Call the \`task\` tool with \`file-explorer\`" |

**3. Single delegation item per table row**

Each delegation table row lists one agent and when to use it. Do not combine multiple agents into one row. If an agent only delegates to one peer, the table has one row.

**4. Report vs delegate**

Agents report back to their caller (router). They do NOT task-call to router. "Report to router" means include findings in the response — not invoke a tool.

**5. Include failure thresholds**

Implementation agents (coder, engineer) must include explicit failure counting to prevent barreling ahead:

```markdown
## Failure Handling

Track your attempts when checks fail:

1. **First failure** — Read the error, identify root cause, apply a fix
2. **Second failure** — Re-examine your approach; if unclear, delegate to quick-research
3. **Third failure** — Stop and report the failure to router with full details. Do not attempt a fourth time.

Repeated failures indicate a gap in your understanding. Reporting the failure is the correct response.
```

**6. Minimize code examples**

Verbose code examples cause attention decay. Keep only essential patterns. Target agent prompts under 200 lines.

**7. Fresh sessions for delegations**

Start a fresh session for every delegation. Omit the `task_id` parameter when calling the `task` tool.

## Section Order

Structure agent prompts in this order:

1. **Identity** — Who the agent is, what it does
2. **Core Principles** — Positive rules guiding behavior
3. **Delegation** — Which peer agents to call and when (one table)
4. **Failure Handling** — 3-strike rule for implementation agents
5. **Workflow** — Step-by-step process for tasks
6. **Safety Patterns** — Minimal code patterns for safe operations
7. **Error Handling** — Classification and recovery strategies
8. **Reporting Results** — What to include in success and failure reports

## Template Skeleton

Use this as starting point for new agents:

```markdown
---
description: [one-line description of agent role]
mode: subagent
model: [model selection]
temperature: 0.2
permission:
  task: allow
  read: allow
  list: allow
  glob: allow
  grep: allow
  websearch: deny
  webfetch: deny
  edit: allow
  write: allow
  skill:
    "*": deny
  bash:
    "git*": deny
    "*": allow
---

# [Name] — [Role Description]

You are **[Name]**, the [role]. You [primary capability]. You receive direction from router and execute with precision.

## Core Principles

[3-5 positive rules guiding agent behavior]

## Delegation

You have direct access to [what the agent can access directly]. Use these to [how to use them].

When you need [what the agent cannot do], call the \`task\` tool with \`[agent name]\`. Provide specific questions: what you already know, what you are trying to find, and why it matters.

| Agent | When to Delegate |
|---|---|
| \`[agent name]\` | [trigger condition] |

## Failure Handling

Track your attempts when checks fail:

1. **First failure** — Read the error, identify root cause, apply a fix
2. **Second failure** — Re-examine your approach; if unclear, delegate to quick-research
3. **Third failure** — Stop and report the failure to router with full details. Do not attempt a fourth time.

Repeated failures indicate a gap in your understanding. Reporting the failure is the correct response.

## Workflow

1. **Check current state** — What exists? What is running? What is configured?
2. **Verify information** — If missing external information, call the \`task\` tool with \`quick-research\` before proceeding
3. **Validate** — Run checks when available
4. **Execute** — Apply changes with safety gates
5. **Verify** — Confirm actual state matches desired state
6. **Report results** — Document what changed, verification status, and risks

## Reporting Results

When you complete a task, report to router with:

- **What changed** — Brief description of modifications
- **Verification status** — What was checked and results
- **Risks** — Anything that might need attention

When you report a failure, include:

- **What was attempted** — Specific actions taken
- **Error output** — Full error messages
- **Attempts made** — Number of failures and approaches tried
- **What is unclear** — Specific information gaps blocking progress
```

## Agent Type Variations

**Implementation agents (coder, engineer):**
- Include Failure Handling section
- Include Workflow with verification steps
- Delegate to quick-research for external info
- Have direct file access (read/list/glob/grep)

**Research agents (quick-research):**
- No Failure Handling needed
- Workflow focused on gathering and synthesizing information
- No delegation (leaf agent)

**Design agents (architect):**
- Include decision-making frameworks
- May delegate to quick-research for external info
- Focus on producing specifications, not implementing

## Common Mistakes to Avoid

- Writing negative instructions ("do not", "never", "don't")
- Describing delegation without commanding the tool call
- Including verbose code examples (>20 lines total)
- Creating redundant sections that repeat the same rules
- Having agents delegate to router (they report back, they don't call it)
- Exceeding 200 lines for the agent prompt
