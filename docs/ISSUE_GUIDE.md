# Issue Management Guide

This guide explains when to open issues, which template to use, how agents should update them, and how issues connect to the GitHub Project board.

---

## When to Open an Issue

### ✅ Always Create an Issue For:

- **New features** - any new functionality, no matter how small
- **Bugs** - anything that doesn't work as expected
- **Refactoring** - code improvements that don't change behavior
- **Documentation** - new docs or updates to existing docs
- **Testing** - new tests or test infrastructure
- **Scraper development** - new scrapers or scraper fixes
- **Agent improvements** - enhancements to agent workflows
- **Infrastructure** - CI/CD, deployment, monitoring changes

### ❌ Skip Issues For:

- **Typo fixes** - just fix and commit
- **Formatting** - linting, prettier, etc.
- **Dependency updates** - minor version bumps (unless they fix a bug)

### 🤔 When in Doubt:

**Create the issue.** It's better to have too many issues than to lose track of work.

---

## The Correct Template to Use

We have two main templates:

### 1. `scraper-issue.md` - For Web Scraping Work

**Use when:**
- Building a new scraper
- Fixing a broken scraper
- Improving scraper performance
- Dealing with selector changes
- Handling anti-bot measures
- Data quality issues in scraped data

**File:** [.github/ISSUE_TEMPLATE/scraper-issue.md](../.github/ISSUE_TEMPLATE/scraper-issue.md)

**Example:**
```bash
gh issue create --template scraper-issue.md \
  --title "[Scraper] Target website product pages failing" \
  --label "auto:scraper,scraper:selector"
```

### 2. `agent-issue.md` - For Agent Development & General Tasks

**Use when:**
- Developing agent workflows
- Improving automation
- Adding features to agent tooling
- Testing agent integrations
- Documentation for agents
- Supabase schema changes
- GitHub Project configuration
- Any non-scraping development work

**File:** [.github/ISSUE_TEMPLATE/agent-issue.md](../.github/ISSUE_TEMPLATE/agent-issue.md)

**Example:**
```bash
gh issue create --template agent-issue.md \
  --title "[Agent] Add automatic test runner for Claude sessions" \
  --label "auto:agent,infra:workflow"
```

---

## How Agents Should Update Issues

### Update Pattern

Agents should provide **structured, parseable updates** that humans and other agents can understand.

### Good Update Example

```markdown
## Progress Update - 2025-11-14 13:30

**Status:** In Progress → Needs Test

**Completed:**
- ✅ Implemented core functionality in `src/scraper.ts`
- ✅ Added unit tests for helper functions
- ✅ Updated documentation in README

**Next Steps:**
- [ ] Run integration tests against staging
- [ ] Test with real data from production
- [ ] Performance testing with 1000+ records

**Test Results:**
```
Unit Tests: 45 passed, 0 failed (2.3s)
Coverage: 87%
```

**Blockers:** None

**Changes Made:**
- Commit: abc123 - "Implement scraper core logic"
- Commit: def456 - "Add unit tests"
```

### Bad Update Example

```markdown
made some progress
```

❌ This provides no useful information.

### Update Frequency

| Work Duration | Update Frequency |
|---------------|------------------|
| < 1 hour | Update when done |
| 1-4 hours | Update every hour or at milestones |
| > 4 hours | Update every 1-2 hours |
| Overnight/Long-running | Update before pausing, when resuming |

### Automated Updates

Agents can post updates programmatically:

```bash
#!/bin/bash
ISSUE_NUM=123

# After completing a step
gh issue comment $ISSUE_NUM --body "✅ Completed: Data validation layer"

# After running tests
gh issue comment $ISSUE_NUM --body "$(cat <<'EOF'
## Test Results

\`\`\`
$(pnpm test 2>&1)
\`\`\`

**Status:** All tests passing
EOF
)"
```

---

## Definition of Done

An issue is considered **Done** when ALL of the following are true:

### For Features:
- ✅ Code is written and committed
- ✅ Unit tests are written and passing
- ✅ Integration tests are passing (if applicable)
- ✅ Documentation is updated
- ✅ Code is reviewed (by human or automated checks)
- ✅ Deployed to appropriate environment
- ✅ Verified working in production/staging

### For Bugs:
- ✅ Root cause identified
- ✅ Fix implemented
- ✅ Test added to prevent regression
- ✅ Fix verified in environment where bug occurred
- ✅ Documented in issue comments

### For Scrapers:
- ✅ Scraper implementation complete
- ✅ Selectors/logic validated against current site
- ✅ Data quality checks passing
- ✅ Error handling implemented
- ✅ Tested with real data
- ✅ Integrated into existing pipelines
- ✅ Monitoring/alerting configured

### For Documentation:
- ✅ Written in clear, concise language
- ✅ Reviewed for accuracy
- ✅ Examples provided where relevant
- ✅ Links verified
- ✅ Committed and deployed

### Checklist Template

Copy this into your issue before closing:

```markdown
## Definition of Done Checklist

- [ ] Implementation complete
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Deployed
- [ ] Verified working

**Additional Notes:**
(Add any context about what was done)
```

---

## How Issues Connect to the GitHub Project Board

All issues in `agent-orchestration` are automatically added to the **Agent Kanban** Project:

**Project URL:** https://github.com/users/brent-bartosch/projects/2

### Automatic Column Movement

Issues move between columns based on:

1. **Labels:**
   - Add `in-progress` → moves to **In Progress**
   - Add `needs-test` → moves to **Needs Test**
   - Add `blocked` → moves to **Blocked**
   - Add `ready-for-review` → moves to **Ready for Review**

2. **Assignees:**
   - Assign someone → moves to **In Progress**

3. **State:**
   - Close issue → moves to **Done**

### Manual Movement

You can also drag cards between columns in the Project UI.

### Project Fields

Each issue on the board has custom fields:

| Field | Type | Purpose |
|-------|------|---------|
| **Agent** | Select | Which agent is working on it |
| **Environment** | Select | Where the work happens |
| **Test Status** | Select | Current testing state |
| **Complexity** | Select | Size estimate (S/M/L/XL) |
| **Website** | Text | Target website (for scrapers) |

**Set fields via web UI** or programmatically:

```graphql
mutation {
  updateProjectV2ItemFieldValue(input: {
    projectId: "PVT_kwHOASdJL84BIJoD",
    itemId: "<item-id>",
    fieldId: "<field-id>",
    value: {
      singleSelectOptionId: "<option-id>"
    }
  }) {
    projectV2Item {
      id
    }
  }
}
```

---

## Label Taxonomy

Use these labels consistently:

### Automation / Source
- `auto:agent` - Created by an agent
- `auto:scraper` - From scraping activity
- `auto:test` - From test failures
- `auto:supabase-sync` - Supabase sync issues

### Status / Flow
- `in-progress` - Currently being worked on
- `needs-test` - Awaiting test execution
- `blocked` - Blocked by external factors
- `ready-for-review` - Complete, awaiting review

### Domain / Area
- `scraper:selector` - CSS/XPath selector issues
- `scraper:playwright` - Browser automation
- `scraper:data-quality` - Data validation/quality
- `scraper:website-specific` - Site-specific logic
- `supabase:schema` - Database schema changes
- `supabase:api` - Supabase API integration
- `infra:workflow` - CI/CD, automation
- `documentation` - Documentation work

### How to Apply Labels

```bash
# Add a label
gh issue edit <number> --add-label "needs-test"

# Remove a label
gh issue edit <number> --remove-label "in-progress"

# Replace labels
gh issue edit <number> --add-label "ready-for-review" --remove-label "needs-test"
```

---

## Issue Lifecycle

### Standard Flow

```
1. CREATED
   ↓ (assigned or started)
2. IN PROGRESS
   ↓ (code complete)
3. NEEDS TEST
   ↓ (tests passing)
4. READY FOR REVIEW
   ↓ (reviewed and approved)
5. DONE (closed)
```

### With Blocking

```
1. CREATED
   ↓
2. IN PROGRESS
   ↓ (hit blocker)
3. BLOCKED
   ↓ (blocker resolved)
2. IN PROGRESS (resumed)
   ↓
3. NEEDS TEST
   ...
```

---

## Best Practices

### ✅ DO:

- **Use descriptive titles:** `[Scraper] Amazon product price extraction failing` not `fix scraper`
- **Fill out templates completely:** Don't skip sections
- **Update regularly:** Keep the issue current
- **Link related items:** Reference other issues, PRs, commits
- **Use labels correctly:** Apply all relevant labels
- **Close when done:** Don't leave completed work open

### ❌ DON'T:

- **Use vague titles:** "Bug" or "Fix this"
- **Skip the template:** Templates exist for a reason
- **Ghost the issue:** No updates for days
- **Duplicate issues:** Search first
- **Leave it open forever:** Close when done or mark as blocked
- **Over-label:** Only use relevant labels

---

## Examples

### Good Issue: Feature Request

```markdown
**Title:** [Agent] Add automatic retry logic for failed scraper runs

**Template:** agent-issue.md

**Labels:** auto:agent, scraper:playwright, infra:workflow

**Body:**
## Summary
When scrapers fail due to network issues or temporary site problems, they should automatically retry with exponential backoff.

## Current Behavior
Scraper fails once and stops. Manual restart required.

## Proposed Solution
1. Wrap scraper execution in retry logic
2. Exponential backoff: 1s, 2s, 4s, 8s, 16s
3. Max 5 retries
4. Log each attempt to Supabase

## Success Criteria
- [ ] Retry logic implemented
- [ ] Tests verify retry behavior
- [ ] Logging confirms retries
- [ ] Documentation updated

## Technical Notes
Use existing error handling framework. Integrate with Supabase event logging.
```

### Good Issue: Bug Report

```markdown
**Title:** [Scraper] Product titles contain extra whitespace

**Template:** scraper-issue.md

**Labels:** auto:scraper, scraper:data-quality, scraper:selector

**Body:**
## Target Website
retailer.com/products

## Problem
Product titles extracted from the site include leading/trailing whitespace and multiple spaces between words.

**Current Output:**
```
"  Gaming  Laptop   15  inch  "
```

**Expected Output:**
```
"Gaming Laptop 15 inch"
```

## Technical Notes
Selector: `h1.product-title`
Issue appears to be in DOM, not our extraction logic.

## Test Plan
- [ ] Add unit test with sample HTML
- [ ] Verify fix with real product page
- [ ] Check all products in test run

## Links
- Example product: https://retailer.com/products/123
```

---

## Quick Reference Commands

```bash
# Create issue from template
gh issue create --template scraper-issue.md

# List my issues
gh issue list --assignee "@me"

# Update labels
gh issue edit 123 --add-label "needs-test"

# Add comment
gh issue comment 123 --body "Progress update"

# Close issue
gh issue close 123 --comment "Completed and verified"

# Reopen issue
gh issue reopen 123 --comment "Found regression"
```

---

## Next Steps

- Read [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) for workflow details
- Read [TESTING_GUIDE.md](TESTING_GUIDE.md) for testing practices
- View the Project Board: https://github.com/users/brent-bartosch/projects/2
