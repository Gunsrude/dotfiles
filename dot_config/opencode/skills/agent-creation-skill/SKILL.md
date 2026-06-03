---
name: agent-creation-skill
description: |-
  Create new subagents following the three-tier guardrail framework. Use when designing agent specifications for team-lead, senior-dev, or other agent types.
  
  Covers:
  - Three-tier guardrail structure (Never Do / Ask First / Always Do)
  - Permission configuration patterns by agent type
  - Verification checklist design
  - Scope boundary definition
  - Complete agent template with YAML header
  
  Examples:
  - Creating a new code-review agent
  - Adding a database-admin specialist
  - Building a documentation agent
---

# Agent Creation Skill

This skill guides you in creating new agents that follow the three-tier guardrail framework. Each agent should be focused, safe, and clear about where its responsibility ends.

## Overview

A well-designed agent has:
1. **Clear purpose** — one primary role it excels at
2. **Three-tier guardrails** — Never Do / Ask First / Always Do sections
3. **Appropriate permissions** — least privilege with explicit allowlists
4. **Verification checklists** — "Before X, verify Y" patterns
5. **Scope boundaries** — explicit statements about what it does NOT do
6. **Visual examples** — ✅/❌ markers showing good vs bad behavior

## Three-Tier Guardrail Structure

The guardrail framework uses three tiers to constrain agent behavior:

| Tier | Purpose | Framing | Examples |
|------|---------|---------|----------|
| **Never Do** | Hard stops — absolute prohibitions | Negative (what NOT to do) | "Never edit production code" |
| **Ask First** | Require human approval | Action-triggered questions | "Ask before git push" |
| **Always Do** | Required behaviors | Positive (what TO do) | "Always verify branch name" |

### Design Principles

**1. Positive Framing for "Always Do"**

The "pink elephant problem" shows that negative constraints can backfire — telling someone "don't think of a pink elephant" makes them think of one. Frame required behaviors positively:

```markdown
### ❌ Bad (Negative Framing)
- Don't forget to run tests
- Don't skip verification steps

### ✅ Good (Positive Framing)
- Always run tests before reporting completion
- Always verify changes with relevant commands
```

**2. Defense in Depth**

Layer multiple guardrails so failure of one doesn't break safety:

```markdown
### Never Do (Hard Stops)
- Edit files without reading them first  # Behavioral constraint
- Proceed if not on an ai/ branch        # State constraint

### Always Do
- Check current branch before starting   # Verification step
- Read files before editing              # Process requirement
```

**3. Specificity Over Generality**

Vague guardrails are hard to follow. Be specific:

```markdown
### ❌ Bad (Too Vague)
- Don't do dangerous things
- Be careful with system changes

### ✅ Good (Specific)
- Never run `rm -rf` without explicit confirmation
- Ask before restarting production services
```

## Permission Configuration Guide

Permissions follow least privilege. Each agent type has a typical permission profile:

### Permission Matrix by Agent Type

| Permission | Team Lead | Senior Dev | Junior Dev | Researcher | Architect | QA | Security | Sys Admin |
|------------|-----------|------------|------------|------------|-----------|----|----|-----------|
| `read` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `edit` | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ |
| `write` | ❌ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ |
| `task` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ |
| `websearch` | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| `webfetch` | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| `bash` | Limited | ✅ | ✅ | ❌ | ❌ | ✅ | ✅ | ✅ |
| `git *` | ✅ | Limited | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |

### Permission Patterns

**1. Wildcard Deny with Explicit Allow**

Deny everything by default, then allow specific commands:

```yaml
permission:
  bash:
    "*": deny
    "git *": allow
    "git push": ask
    "chezmoi *": allow
    "ls *": allow
```

**2. Ask for Dangerous Operations**

Use `ask` for operations that need human approval:

```yaml
permission:
  bash:
    "*": allow
    "sudo rm *": ask
    "git push": ask
```

**3. Skill Access Control**

Control which skills an agent can load:

```yaml
permission:
  skill:
    "*": deny
    "ai-git-workflow": allow
```

### Agent Type Permission Templates

**Read-Only Analyst (Architect, Security):**
```yaml
permission:
  read: allow
  list: allow
  glob: allow
  grep: allow
  edit: deny
  write: deny
  bash: deny
  task: deny
  skill:
    "*": deny
```

**Implementation Agent (Senior Dev, Junior Dev):**
```yaml
permission:
  read: allow
  list: allow
  glob: allow
  grep: allow
  edit: allow
  write: allow
  bash:
    "*": allow
    "git *": deny
  task: allow  # Senior Dev only
  skill:
    "*": deny
```

**Infrastructure Agent (Sys Admin):**
```yaml
permission:
  read: allow
  list: allow
  glob: allow
  grep: allow
  edit: allow
  write: allow
  bash:
    "*": allow
    "git *": deny
    "sudo rm *": ask
  task: allow
  skill:
    "*": allow
```

**Research Agent:**
```yaml
permission:
  read: allow
  list: allow
  glob: allow
  grep: allow
  edit: deny
  write: deny
  bash: deny
  websearch: allow
  webfetch: allow
  skill:
    "*": deny
  exa_*: allow
```

## Verification Checklist Patterns

Verification checklists ensure preconditions are met before critical actions. Use the "Before X, verify Y" pattern.

### Structure

```markdown
## Before [Critical Action]

**Verify these conditions first:**
1. ✅ [Condition 1]
2. ✅ [Condition 2]
3. ✅ [Condition 3]

**If check fails:** [Escalation or remediation instruction]
```

### Examples by Agent Type

**Implementation Agent:**
```markdown
## Before Starting Any Coding Task

**Verify these conditions first:**
1. ✅ Current branch starts with `ai/` (run `git branch --show-current`)
2. ✅ You have clear requirements from Team Lead
3. ✅ You understand the files that need to change

**If branch check fails:** Immediately re-escalate to Team Lead with message:
> "Not on an ai/ branch. Current branch: <branch-name>. Please set up the proper git branch before I proceed."
```

**On-Call Agent (QA, Security):**
```markdown
## Before Reviewing Any Code

**Verify these conditions first:**
1. ✅ User explicitly requested [your role] review
2. ✅ You understand what changed and why
3. ✅ Existing tests are run for baseline

**If user didn't request you:** Wait. Do not auto-activate.
```

**Infrastructure Agent:**
```markdown
## Before Making Any System Change

**Verify these conditions first:**
1. ✅ You understand what needs to change and why
2. ✅ You know which system/service is affected
3. ✅ Commands are verified or researched

**If unsure about a command:** Delegate to researcher subagent. Do not guess.
```

### Checklist Design Rules

1. **3-5 items maximum** — more becomes overwhelming
2. **Actionable checks** — each item should be verifiable
3. **Clear escalation path** — what to do if a check fails
4. **Ordered by importance** — most critical checks first

## Scope Boundaries Section

Every agent needs explicit scope boundaries — statements about where its responsibility ends. This prevents scope creep and ensures clean handoffs.

### Structure

```markdown
## Scope Boundaries

**You [primary responsibility], [other team] handles [other responsibility].** If you encounter:
- [Issue type 1]: [Action], don't [prohibited action]
- [Issue type 2]: [Action], don't [prohibited action]
- [Issue type 3]: [Action], don't [prohibited action]

**Why:** [Rationale for the boundary]
```

### Examples

**Junior Dev:**
```markdown
## Scope Boundaries

**You are delegated specific tasks.** If you notice:
- Unrelated bugs: Report them, don't fix them
- Code smell nearby: Mention it, don't refactor it
- Missing features: Suggest it, don't implement it

**Why:** Senior Dev owns the task breakdown. Your job is to execute cleanly, not expand scope.
```

**QA Engineer:**
```markdown
## Scope Boundaries

**You identify issues, dev team fixes them.** If you find:
- Bugs in production code: Report with specifics, don't fix
- Missing error handling: Suggest additions, don't implement
- Code smell: Recommend refactoring, don't refactor

**Why:** QA owns quality assurance, not implementation. Your job is to find issues cleanly, not expand into dev work.
```

**Sys Admin:**
```markdown
## Scope Boundaries

**You manage infrastructure, dev team manages code.** If you encounter:
- Code bugs: Report to Team Lead/Senior Dev, don't fix
- Configuration in source files: Report, don't edit directly
- Unclear system behavior: Research first, don't guess

**Why:** Infrastructure and application code are separate concerns. Your job is to keep the system running cleanly, not expand into development work.
```

### Scope Boundary Design Rules

1. **Use contrast structure** — "You do X, team does Y"
2. **List specific scenarios** — what to do when encountering out-of-scope items
3. **Explain the why** — rationale helps the agent understand the principle
4. **Use parallel structure** — "Report, don't fix" pattern is memorable

## Visual Examples Format

Use ✅/❌ markers to show good vs bad behavior. This makes expectations concrete and memorable.

### Structure

```markdown
### ❌ Bad ([Specific Problem])
```[example code or text]```

**Problems:** [List specific issues]

### ✅ Good ([Specific Quality])
```[example code or text]```

**Why this works:** [Explain the principle]
```

### Examples by Category

**Delegation Criteria:**
```markdown
### Should Delegate ✅
- Add `import { foo } from 'bar'` to 10 files
- Rename parameter `userId` → `user_id` across 8 function signatures
- Update version number in 6 config files

### Should NOT Delegate ❌
- Refactoring authentication logic across 5 files (requires understanding)
- Adding error handling to 4 API endpoints (each needs different logic)
- Any change over 10 lines per file
- Changes where files need different modifications
```

**Code Quality:**
```markdown
### ❌ Bad (Too Vague)
```
"There might be an issue with error handling"
"Consider improving this function"
```

**Problems:** No specifics, unclear action items

### ✅ Good (Specific and Actionable)
```
"Line 47: Missing null check before calling `user.getName()` — could throw NPE if user is null"
"Lines 23-45: Function exceeds 50 lines — consider extracting `validateInput()` and `processOutput()` helpers"
```

**Why this works:** Dev team can fix immediately without clarification.
```

**Command Safety:**
```markdown
### ❌ Bad (Risky or Destructive Without Verification)
```bash
rm -rf /some/path  # No verification exists
service nginx restart  # No check if nginx is running
```

**Problems:** Destructive, no verification, assumes state

### ✅ Good (Safe and Verified)
```bash
# Check first, then act with confirmation
if [ -d "/some/path" ]; then
  echo "Found /some/path, removing..."
  rm -rf /some/path
else
  echo "/some/path does not exist, nothing to remove"
fi
```

**Why this works:** Verifies state first, idempotent operations, clear feedback
```

### Visual Example Design Rules

1. **Label the problem/quality** — "(Too Vague)", "(Specific and Actionable)"
2. **Keep examples short** — 2-4 lines maximum
3. **Explain both sides** — why bad is bad, why good is good
4. **Use real patterns** — examples should match actual use cases

## Complete Agent Template

Use this template when creating a new agent. Fill in the bracketed sections.

```markdown
---
description: [One-sentence description of agent role and when it's called]
mode: subagent
model: [model name]
temperature: [0.1-0.7 based on creativity needed]
permission:
  read: allow
  list: allow
  glob: allow
  grep: allow
  edit: [allow/deny]
  write: [allow/deny]
  bash:
    "*": [allow/deny]
    "git *": deny
  task: [allow/deny]
  websearch: deny
  webfetch: deny
  skill:
    "*": deny
---

# [Agent Name]

You are the **[Agent Name]**, [brief role description]. [Who calls you and when].

## Guardrails

### Never Do (Hard Stops)
- [Absolute prohibition 1]
- [Absolute prohibition 2]
- [Absolute prohibition 3]
- [Absolute prohibition 4]

### Ask First
- [Clarification need 1]
- [Clarification need 2]

### Always Do
- [Required behavior 1]
- [Required behavior 2]
- [Required behavior 3]
- [Required behavior 4]

## Before [Primary Action]

**Verify these conditions first:**
1. ✅ [Condition 1]
2. ✅ [Condition 2]
3. ✅ [Condition 3]

**If check fails:** [Escalation or remediation instruction]

## What You [Handle/Do]

- **[Responsibility 1]** — [brief description]
- **[Responsibility 2]** — [brief description]
- **[Responsibility 3]** — [brief description]

## Scope Boundaries

**You [primary responsibility], [other team] handles [other responsibility].** If you encounter:
- [Out-of-scope item 1]: [Action], don't [prohibited action]
- [Out-of-scope item 2]: [Action], don't [prohibited action]
- [Out-of-scope item 3]: [Action], don't [prohibited action]

**Why:** [Rationale for the boundary]

## [Relevant Section Title]

### ❌ Bad ([Problem Type])
```[bad example]```

**Problems:** [Specific issues]

### ✅ Good ([Quality Type])
```[good example]```

**Why this works:** [Principle explanation]
```

## Model and Temperature Guidelines

| Agent Type | Model | Temperature | Rationale |
|------------|-------|-------------|-----------|
| Orchestrator (Team Lead) | `Stellar/full` | 0.1 | Maximum reliability for coordination |
| Implementation (Senior Dev) | `Stellar/coder` | 0.2 | Balance of creativity and precision |
| Junior tasks (Junior Dev) | `opencode/big-pickle` | 0.3 | Cost-effective for simple tasks |
| Analysis (Architect) | `opencode/kimi-k2.5` | 0.2 | Strong reasoning for design |
| Research | `Stellar/research` | 0.7 | Higher creativity for exploration |
| Infrastructure (Sys Admin) | `Stellar/full` | 0.2 | Reliability for system changes |

## Common Agent Types and When to Create Them

### Create a New Agent When

1. **Specialized expertise needed** — task requires domain knowledge (database, security, DevOps)
2. **Clear separation of concerns** — role is distinct from existing agents
3. **Repeated delegation pattern** — you find yourself giving the same type of task repeatedly
4. **Different permission profile** — role needs unique access (read-only, web access, bash access)

### Agent Type Patterns

**Specialist Implementation Agent:**
- Like senior-dev but focused on one domain (database, frontend, API)
- Has edit/write/bash permissions
- Can delegate to junior-dev for mechanical work

**Read-Only Analyst Agent:**
- Like architect or security
- No edit/write permissions
- Produces reports, specs, or findings

**On-Call Review Agent:**
- Like QA or security
- Only activates when explicitly requested
- Reviews work done by implementation agents

**Infrastructure Agent:**
- Like sys-admin
- Full bash access with safety constraints
- Handles system-level operations

## Checklist for Agent Creation

Before finalizing a new agent, verify:

1. ✅ **Purpose is clear** — one sentence describes the role
2. ✅ **Guardrails are specific** — no vague "be careful" statements
3. ✅ **Permissions follow least privilege** — deny by default, allow explicitly
4. ✅ **Verification checklist exists** — "Before X, verify Y" section present
5. ✅ **Scope boundaries defined** — explicit statements about what it doesn't do
6. ✅ **Visual examples included** — ✅/❌ markers showing good vs bad
7. ✅ **Model and temperature appropriate** — matches agent type guidelines
8. ✅ **No websearch/webfetch** — unless this IS the researcher agent

## Anti-Patterns to Avoid

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| Vague guardrails ("don't do bad things") | Unenforceable, unclear | Be specific: "Never run rm -rf without confirmation" |
| Too many permissions | Increases risk surface | Deny by default, allow only what's needed |
| Missing scope boundaries | Agent expands into other roles | Add explicit "Scope Boundaries" section |
| Negative framing in "Always Do" | Pink elephant problem | Use positive: "Always verify" not "Don't forget to verify" |
| No escalation path | Agent stuck when checks fail | Add "If check fails:" instruction |
| Websearch on non-researcher agents | Violates research delegation pattern | Move to `deny`, delegate to researcher |
