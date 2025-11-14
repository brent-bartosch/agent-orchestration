# Agent Workflow Guide

This document describes how AI agents (Claude Code, Codex, GitHub Actions, local scripts) interact with the **agent-orchestration** system through Issues, the GitHub Project board, and Supabase logging.

---

## Overview

The **agent-orchestration** workflow is designed to:
- Track all agent work through **GitHub Issues**
- Visualize progress on the **Agent Kanban** Project board
- Log all events to **Supabase** for auditing and analysis
- Provide a single source of truth across multiple repositories

---

## How Claude Code Sessions Should Use Issues

### 1. **Starting a New Task**

When you begin working on a task in VS Code / Claude Code:

1. **Check for existing issues** first:
   ```bash
   gh issue list --repo brent-bartosch/agent-orchestration --label "auto:agent"
   ```

2. **Create a new issue** if none exists:
   ```bash
   gh issue create --repo brent-bartosch/agent-orchestration \
     --title "[Agent] Your task description" \
     --label "auto:agent" \
     --label "in-progress" \
     --body "## Task\nDescribe what needs to be done\n\n## Context\nWhy this is needed"
   ```

3. **Assign yourself** to show you're working on it:
   ```bash
   gh issue edit <issue-number> --add-assignee "@me"
   ```

### 2. **During Active Development**

As you work:

- **Update the issue** with progress notes:
  ```bash
  gh issue comment <issue-number> --body "Progress: Completed X, working on Y"
  ```

- **Add relevant labels** as status changes:
  - `needs-test` - when code is written but needs testing
  - `blocked` - when you hit an external constraint
  - `ready-for-review` - when work is complete and passing tests

- **Link commits** by referencing the issue in commit messages:
  ```bash
  git commit -m "Implement feature X (#123)"
  ```

### 3. **Completing Work**

When the task is done:

1. **Add final summary** to the issue
2. **Add test results** if applicable
3. **Close the issue**:
   ```bash
   gh issue close <issue-number> --comment "Completed: All tests passing, deployed to production"
   ```

The issue will automatically move to **Done** on the Kanban board.

---

## How Agents Create or Update Issues

### Automated Issue Creation

Agents can programmatically create issues using:

1. **The provided script**:
   ```bash
   ./scripts/create_issue.sh \
     --title "Task description" \
     --body "Details" \
     --labels "auto:agent,scraper:playwright"
   ```

2. **GitHub CLI directly**:
   ```bash
   gh issue create --repo brent-bartosch/agent-orchestration \
     --title "[Agent] Task" \
     --label "auto:agent"
   ```

3. **GraphQL API** (for advanced integration):
   ```graphql
   mutation {
     createIssue(input: {
       repositoryId: "R_kgDOQV6eIQ",
       title: "Task",
       body: "Details",
       labelIds: ["auto:agent"]
     }) {
       issue {
         id
         number
         url
       }
     }
   }
   ```

### Issue Update Pattern

When an agent makes progress:

```bash
# Add a comment with structured information
gh issue comment <issue-number> --body "$(cat <<'EOF'
## Progress Update

**Status:** In Progress
**Completed:**
- Task A
- Task B

**Next Steps:**
- Task C
- Task D

**Test Results:**
- Unit tests: ✅ Passing
- Integration tests: ⚠️ 1 failure

**Blockers:** None
EOF
)"
```

---

## How Testing Fits Into the Workflow

### Test-Driven Development with Agents

1. **Issue created** → labeled `auto:agent`
2. **Agent writes code** → adds label `needs-test`
3. **Tests run** → results logged to issue
4. **Tests pass** → label changes to `ready-for-review`
5. **Human reviews** → issue closed or sent back with feedback

### Test Result Logging

After running tests, agents should:

```bash
# Run tests and capture output
pnpm test > test-results.txt 2>&1

# Log to issue
gh issue comment <issue-number> --body "$(cat <<'EOF'
## Test Results

\`\`\`
$(cat test-results.txt)
\`\`\`

**Summary:** 42 passed, 0 failed
**Status:** ✅ All tests passing
EOF
)"

# Update label
gh issue edit <issue-number> --add-label "ready-for-review" --remove-label "needs-test"
```

### Test Categories

| Test Type | When to Run | Label if Failing |
|-----------|-------------|------------------|
| **Unit** | Every code change | `auto:test` |
| **Integration** | Before PR merge | `auto:test` |
| **E2E** | Before deployment | `auto:test`, `blocked` |
| **Real Data** | Manual trigger | `scraper:data-quality` |

---

## How Web Scraping Tasks Get Managed

### Scraper Development Workflow

1. **New scraper needed** → create issue with `scraper-issue` template
2. **Agent implements** → adds labels based on what's being worked on:
   - `scraper:selector` - CSS/XPath selectors
   - `scraper:playwright` - Browser automation
   - `scraper:data-quality` - Output validation
   - `scraper:website-specific` - Site-specific logic

3. **Testing phase**:
   - Run against sample data
   - Add label `needs-test`
   - Run against real website
   - Check data quality

4. **Deployment**:
   - Label `ready-for-review`
   - Human reviews output
   - Close issue when deployed

### Scraper Bug Reports

When a scraper breaks:

```bash
gh issue create --repo brent-bartosch/agent-orchestration \
  --template scraper-issue.md \
  --title "[Scraper] Website X failing: Selector not found" \
  --label "auto:scraper,scraper:selector,blocked"
```

The agent investigating should:
1. Comment with diagnosis
2. Update the issue with fix details
3. Add test results showing the fix works
4. Close when deployed

---

## Connection to Supabase Ledger

All agent actions should be logged to Supabase:

### Event Types

- `AGENT_TASK_STARTED` - when work begins
- `AGENT_TASK_COMPLETED` - when work finishes
- `TEST_RUN` - when tests execute
- `SCRAPER_RUN` - when a scraper runs
- `ISSUE_CREATED` - when an issue is created
- `ISSUE_UPDATED` - when an issue is updated

### Logging Pattern

```javascript
// Example: Log a task completion
await supabase.from('events').insert({
  project: 'agent-orchestration',
  repo: 'brent-bartosch/agent-orchestration',
  agent_id: 'claude-code',
  type: 'AGENT_TASK_COMPLETED',
  payload: {
    issue_number: 123,
    task: 'Implement feature X',
    duration_ms: 15000,
    test_status: 'passing'
  }
});
```

---

## Best Practices

### ✅ DO:
- Create issues for all non-trivial work
- Update issues with progress regularly
- Use descriptive labels
- Log test results to issues
- Close issues when done

### ❌ DON'T:
- Skip issue creation for "quick fixes"
- Leave issues open indefinitely
- Use generic titles like "Fix bug"
- Forget to update labels as status changes
- Close issues without documenting what was done

---

## Quick Reference

```bash
# Create issue
./scripts/create_issue.sh --title "Task" --labels "auto:agent"

# List my issues
gh issue list --assignee "@me"

# Update issue
gh issue comment <number> --body "Update"

# Change labels
gh issue edit <number> --add-label "needs-test"

# Close issue
gh issue close <number> --comment "Done"
```

---

## Next Steps

- Read [ISSUE_GUIDE.md](ISSUE_GUIDE.md) for detailed issue management
- Read [TESTING_GUIDE.md](TESTING_GUIDE.md) for testing workflows
- Read [SESSION_LOGGING.md](SESSION_LOGGING.md) for session documentation
