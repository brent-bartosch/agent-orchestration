# Agent Startup Instructions

**Quick start guide for LLM agents beginning work in any project.**

This document contains everything you need to know when starting a new Claude Code, Codex, or other AI agent session.

---

## Table of Contents

1. [Before You Start](#before-you-start)
2. [Creating Issues](#creating-issues)
3. [Attaching to the Kanban Board](#attaching-to-the-kanban-board)
4. [Working on Issues](#working-on-issues)
5. [Logging Tests](#logging-tests)
6. [Writing Session Logs](#writing-session-logs)
7. [Avoiding Duplicate Issues](#avoiding-duplicate-issues)
8. [Running Tests](#running-tests)
9. [Supabase Integration](#supabase-integration)
10. [Quick Reference Commands](#quick-reference-commands)

---

## Before You Start

### 1. Check Your Environment

```bash
# Verify GitHub CLI is authenticated
gh auth status

# Check environment variables
echo $GITHUB_TOKEN
echo $DEFAULT_REPO  # Should be: brent-bartosch/agent-orchestration
```

### 2. Understand the System

- **All issues are created in this repository** (`agent-orchestration`)
- **All issues flow to the Project Board**: https://github.com/users/brent-bartosch/projects/2
- **All events are logged to Supabase** for audit and analytics
- **Session logs go to** `~/agent-logs/<project>/claude/`

### 3. Read the Core Documentation

Start with these (in order):

1. [README.md](README.md) - System overview
2. [docs/AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md) - How agents work with issues
3. [docs/ISSUE_GUIDE.md](docs/ISSUE_GUIDE.md) - Issue templates and labels
4. [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) - Testing best practices

---

## Creating Issues

### Check for Existing Issues First

**ALWAYS check before creating a new issue to avoid duplicates:**

```bash
# Search by keyword
gh issue list --repo brent-bartosch/agent-orchestration --search "keyword"

# View your assigned issues
gh issue list --repo brent-bartosch/agent-orchestration --assignee "@me"

# View all open issues
gh issue list --repo brent-bartosch/agent-orchestration --state open

# View on the web
open https://github.com/brent-bartosch/agent-orchestration/issues
```

### Creating a New Issue

**Method 1: Using the create_issue.sh script (recommended)**

```bash
# For agent/development work
./scripts/create_issue.sh \
  --title "[Agent] Your task description" \
  --body "Detailed description of the work" \
  --labels "auto:agent,in-progress" \
  --assignee "@me"

# For scraping work
./scripts/create_issue.sh \
  --title "[Scraper] Site X product extraction failing" \
  --body "Selectors broken after site update" \
  --labels "auto:scraper,scraper:selector" \
  --assignee "@me" \
  --template scraper
```

**Method 2: Using GitHub CLI directly**

```bash
# With template
gh issue create \
  --repo brent-bartosch/agent-orchestration \
  --template agent-issue.md \
  --title "[Agent] Your task" \
  --assignee "@me"

# Simple issue
gh issue create \
  --repo brent-bartosch/agent-orchestration \
  --title "[Agent] Quick task" \
  --body "Task description" \
  --label "auto:agent,in-progress"
```

### Choosing the Right Template

- **scraper-issue.md**: Web scraping, selector updates, anti-bot measures, data quality
- **agent-issue.md**: Agent development, workflows, infrastructure, documentation, general development

See [docs/ISSUE_GUIDE.md](docs/ISSUE_GUIDE.md#when-to-use-each-template) for detailed guidance.

### Applying the Right Labels

**Automation/Source Labels** (choose one):
- `auto:agent` - Created by an AI agent
- `auto:scraper` - From scraping activity
- `auto:test` - From test failures
- `auto:supabase-sync` - Supabase sync issues

**Status Labels** (update as you work):
- `in-progress` - Actively working
- `needs-test` - Code complete, awaiting tests
- `blocked` - Waiting on external dependency
- `ready-for-review` - Complete, needs review

**Domain Labels** (as applicable):
- `scraper:selector`, `scraper:playwright`, `scraper:data-quality`, `scraper:website-specific`
- `supabase:schema`, `supabase:api`
- `infra:workflow`, `documentation`

See complete label taxonomy in [docs/ISSUE_GUIDE.md](docs/ISSUE_GUIDE.md#label-taxonomy).

---

## Attaching to the Kanban Board

### Automatic Addition

Issues created in `agent-orchestration` should automatically be added to Project #2 via the auto-label workflow.

### Manual Addition (If Needed)

**Known Issue**: GitHub Actions tokens cannot add issues to user-level projects. If auto-addition fails, add manually:

```bash
# Get the issue node_id (you'll need this)
ISSUE_NUMBER=123
ISSUE_NODE_ID=$(gh api repos/brent-bartosch/agent-orchestration/issues/$ISSUE_NUMBER --jq '.node_id')

# Add to Project #2 using GraphQL
gh api graphql -f query='
  mutation($projectId: ID!, $contentId: ID!) {
    addProjectV2ItemById(input: {
      projectId: $projectId
      contentId: $contentId
    }) {
      item { id }
    }
  }
' -f projectId='PVT_kwHOASdJL84BIJoD' -f contentId="$ISSUE_NODE_ID"
```

**Or use the web interface:**

1. Go to https://github.com/users/brent-bartosch/projects/2
2. Click "Add item" at bottom of any column
3. Search for your issue and add it

### Moving Between Columns

Update labels to automatically move issues:

```bash
# Move to "In Progress"
gh issue edit $ISSUE_NUMBER --add-label "in-progress"

# Move to "Needs Test"
gh issue edit $ISSUE_NUMBER --add-label "needs-test" --remove-label "in-progress"

# Move to "Blocked"
gh issue edit $ISSUE_NUMBER --add-label "blocked"

# Move to "Ready for Review"
gh issue edit $ISSUE_NUMBER --add-label "ready-for-review"
```

---

## Working on Issues

### Starting Work

1. **Find or create the issue** (see [Creating Issues](#creating-issues))
2. **Assign yourself** to show you're working on it:
   ```bash
   gh issue edit $ISSUE_NUMBER --add-assignee "@me"
   ```
3. **Add the `in-progress` label**:
   ```bash
   gh issue edit $ISSUE_NUMBER --add-label "in-progress"
   ```
4. **Post a comment** to log what you're doing:
   ```bash
   gh issue comment $ISSUE_NUMBER --body "Starting work on this. Plan:
   1. Step one
   2. Step two
   3. Step three"
   ```

### During Development

Post updates regularly:

```bash
# Progress update
gh issue comment $ISSUE_NUMBER --body "Completed step 1. Moving to step 2: implementing X..."

# Encountered an issue
gh issue comment $ISSUE_NUMBER --body "Blocked on Y. Investigating Z approach..."

# Found solution
gh issue comment $ISSUE_NUMBER --body "Resolved blocker. Solution was to do X. Continuing..."
```

### Completing Work

1. **Run tests** (see [Logging Tests](#logging-tests))
2. **Update the issue** with results
3. **Add `ready-for-review` label** if human review needed, or close if complete:
   ```bash
   gh issue close $ISSUE_NUMBER --comment "Completed:
   - Implemented X
   - Added tests for Y
   - All tests passing
   - Logged session to ~/agent-logs/

   See commit: abc123"
   ```

See [docs/AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md) for complete workflow patterns.

---

## Logging Tests

### Running Tests

```bash
# Run project tests (depends on project)
npm test          # Node.js projects
pnpm test         # pnpm projects
pytest            # Python projects
cargo test        # Rust projects

# Run specific test suite
npm test -- --grep "feature X"
pytest tests/test_feature.py
```

### Posting Test Results

**Always post test results to the issue:**

```bash
gh issue comment $ISSUE_NUMBER --body "## Test Results

**Status**: ✅ PASSING (or ❌ FAILING)
**Duration**: 2.3s
**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")

\`\`\`
Tests:       15 passed, 15 total
Assertions:  42 passed, 42 total
Duration:    2.3s
\`\`\`

**Changed files**:
- src/feature.ts - Implemented X
- tests/feature.test.ts - Added test coverage

All tests passing. Ready for review."
```

### Test-Driven Development Pattern

From [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md):

1. **Write the test first** - Define expected behavior
2. **Verify test fails** - Confirms test is valid
3. **Implement feature** - Make test pass
4. **Run all tests** - Ensure no regressions
5. **Log results** - Post to issue

---

## Writing Session Logs

### File Location and Naming

```bash
# Format: ~/agent-logs/<project>/<agent>/<timestamp>_<session-id>.md
~/agent-logs/my-project/claude/2025-01-14_1430_session-abc123.md
```

### Required Log Format

Create a markdown file with these sections:

```markdown
# Session Log: [Brief description]

**Project**: my-project
**Agent**: Claude Code
**Date**: 2025-01-14
**Duration**: 45 minutes
**Related Issue**: https://github.com/brent-bartosch/agent-orchestration/issues/123

---

## Objective

What you were asked to do.

## Work Completed

- Step 1: Did X
- Step 2: Implemented Y
- Step 3: Tested Z

## Files Changed

- `src/feature.ts` - Added new feature
- `tests/feature.test.ts` - Added tests
- `README.md` - Updated documentation

## Tests Run

```
npm test
Tests: 15 passed, 15 total
Duration: 2.3s
```

## Issues Created/Updated

- #123 - Updated with test results and closed
- #124 - Created new issue for follow-up work

## Action Items

- [ ] Follow-up task 1
- [ ] Follow-up task 2

## Notes

Any blockers, decisions, or context for future sessions.
```

### Automatic Issue Creation from Logs

The file-drop collector watches `~/agent-logs/` and automatically:

1. Detects new markdown files
2. Extracts items from "## Action Items" section
3. Creates issues in agent-orchestration with `auto:agent` label
4. Logs events to Supabase

**To trigger this**: Just save your session log with action items marked with `- [ ]` checkboxes under an "## Action Items" heading.

See [docs/SESSION_LOGGING.md](docs/SESSION_LOGGING.md) for complete format guide.

---

## Avoiding Duplicate Issues

### ALWAYS Search First

Before creating any issue:

```bash
# Search by title keywords
gh issue list --repo brent-bartosch/agent-orchestration --search "scraper product"

# Search by label
gh issue list --repo brent-bartosch/agent-orchestration --label "scraper:selector"

# Search all issues (including closed)
gh issue list --repo brent-bartosch/agent-orchestration --state all --search "keyword"
```

### Check the Project Board

https://github.com/users/brent-bartosch/projects/2

Look through:
- **Inbox** - New issues not yet prioritized
- **To Do** - Ready to work on
- **In Progress** - Actively being worked
- **Needs Test** - Code complete, awaiting tests
- **Blocked** - Waiting on dependencies

### If You Find a Duplicate

**Instead of creating a new issue:**

1. **Comment on the existing issue** with your update
2. **Add yourself as assignee** if you're working on it
3. **Update labels** to reflect current status
4. **Reference the issue** in your session log

```bash
# Update existing issue
gh issue comment $EXISTING_ISSUE --body "I'm working on this now. Current progress:
- Completed X
- Working on Y"

gh issue edit $EXISTING_ISSUE --add-assignee "@me" --add-label "in-progress"
```

### Linking Related Issues

If issues are related but not duplicates:

```bash
gh issue comment $ISSUE_A --body "Related to #$ISSUE_B - shares same root cause"
```

---

## Running Tests

### Project-Specific Test Commands

Check the project's README or package.json for test commands:

```bash
# Node.js - check package.json "scripts" section
cat package.json | grep -A5 '"scripts"'

# Python - look for pytest, unittest, or tox
cat setup.py README.md

# Check for test directory
ls -la tests/ test/ __tests__/
```

### Common Test Patterns

```bash
# Node.js
npm test                          # Run all tests
npm test -- --watch              # Watch mode
npm test -- --coverage           # With coverage
npm test -- tests/specific.test.js  # Single file

# Python
pytest                           # Run all tests
pytest tests/test_feature.py     # Single file
pytest -v                        # Verbose
pytest --cov=src                 # With coverage

# Playwright (scrapers)
npx playwright test              # Run all tests
npx playwright test --headed     # Show browser
npx playwright test --debug      # Debug mode
```

### Test Before Closing Issues

**NEVER close an issue without running tests:**

1. Run full test suite: `npm test` or equivalent
2. Fix any failures
3. Run tests again to confirm
4. Log results to issue
5. Only then close the issue

See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) for comprehensive testing guide.

---

## Supabase Integration

### Event Logging

All agent activity is logged to Supabase for audit, analytics, and debugging.

**Tables:**
- `issues` - Mirrors GitHub issues
- `events` - All agent/system events

### Current Integration Points

1. **File-drop collector** (github-bootstrap)
   - Watches `~/agent-logs/` for session transcripts
   - Logs `CHAT_TRANSCRIPT_ADDED` events
   - Logs `ISSUE_PROMOTED` events when creating issues

2. **GitHub webhook** (Supabase Edge Function)
   - Syncs all GitHub issue events to Supabase
   - Logs `GITHUB_ISSUES` events
   - See: https://gbvogiyztczpryswgbrn.supabase.co/project/default/functions/github-webhook

### Placeholder Scripts

**Note**: These scripts are placeholders for future automation:

- `scripts/sync_supabase.js` - Future bidirectional sync
- `scripts/testing_runner.js` - Future test automation

**Current workaround**: Use GitHub CLI and manual commands.

### Checking Supabase Events

```bash
# View recent events in Supabase dashboard
open https://gbvogiyztczpryswgbrn.supabase.co/project/default/editor

# Or query directly (if you have Supabase CLI configured)
# This requires additional setup - see Supabase docs
```

See [docs/ARCHITECTURE_OVERVIEW.md](docs/ARCHITECTURE_OVERVIEW.md#supabase-event-ledger) for complete integration details.

---

## Quick Reference Commands

### Issue Management

```bash
# Search for issues
gh issue list --repo brent-bartosch/agent-orchestration --search "keyword"

# Create issue
./scripts/create_issue.sh --title "[Agent] Task" --labels "auto:agent,in-progress"

# View issue
gh issue view $ISSUE_NUMBER --repo brent-bartosch/agent-orchestration

# Update issue
gh issue edit $ISSUE_NUMBER --add-label "needs-test"
gh issue comment $ISSUE_NUMBER --body "Progress update"

# Close issue
gh issue close $ISSUE_NUMBER --comment "Completed and tested"
```

### Testing

```bash
# Run tests
npm test                                    # or pnpm test, pytest, etc.

# Post results
gh issue comment $ISSUE_NUMBER --body "## Test Results
✅ All tests passing"
```

### Session Logging

```bash
# Create session log
mkdir -p ~/agent-logs/my-project/claude
cat > ~/agent-logs/my-project/claude/$(date +%Y-%m-%d_%H%M)_session.md << 'EOF'
# Session Log: Brief description

**Project**: my-project
**Date**: $(date +%Y-%m-%d)

## Work Completed
- Task 1
- Task 2

## Action Items
- [ ] Follow-up task 1
- [ ] Follow-up task 2
EOF
```

### Project Board

```bash
# Open project board
open https://github.com/users/brent-bartosch/projects/2

# Add issue to project (if auto-add failed)
ISSUE_NODE_ID=$(gh api repos/brent-bartosch/agent-orchestration/issues/$ISSUE_NUMBER --jq '.node_id')
gh api graphql -f query='mutation($projectId: ID!, $contentId: ID!) {
  addProjectV2ItemById(input: {projectId: $projectId, contentId: $contentId}) {
    item { id }
  }
}' -f projectId='PVT_kwHOASdJL84BIJoD' -f contentId="$ISSUE_NODE_ID"
```

---

## Common Workflows

### Starting a New Task

1. Search for existing issues: `gh issue list --search "task keyword"`
2. Create issue if needed: `./scripts/create_issue.sh --title "[Agent] Task"`
3. Assign yourself: `gh issue edit $N --add-assignee "@me" --add-label "in-progress"`
4. Start work and post progress: `gh issue comment $N --body "Working on X..."`

### Completing a Task

1. Run tests: `npm test`
2. Post results: `gh issue comment $N --body "## Test Results\n✅ Passing"`
3. Write session log: `~/agent-logs/project/claude/session.md`
4. Close issue: `gh issue close $N --comment "Completed and tested"`

### Blocked or Need Help

1. Add blocked label: `gh issue edit $N --add-label "blocked"`
2. Comment with details: `gh issue comment $N --body "Blocked on X. Need Y to proceed."`
3. Create follow-up if needed: `./scripts/create_issue.sh --title "[Agent] Investigate X"`

---

## Important Reminders

1. **ALWAYS search before creating issues** - Avoid duplicates
2. **ALWAYS run tests before closing** - No exceptions
3. **ALWAYS log your session** - Future agents need context
4. **ALWAYS update issues** - Keep the team informed
5. **Use the right labels** - Helps with automation and organization
6. **Reference issue templates** - They have helpful checklists
7. **Post test results** - Document what works
8. **Check the project board** - See the big picture

---

## Getting Help

- **Documentation**: See [docs/](docs/) directory
- **Issue Templates**: See [.github/ISSUE_TEMPLATE/](.github/ISSUE_TEMPLATE/)
- **Scripts**: See [scripts/](scripts/) directory
- **Project Board**: https://github.com/users/brent-bartosch/projects/2
- **Create an issue**: For questions or problems with the system itself

---

## Environment Setup

### Required Environment Variables

Ensure these are set (usually in project `.env` or shell profile):

```bash
# GitHub
GITHUB_TOKEN=ghp_...                              # Your personal access token
GITHUB_OWNER=brent-bartosch                       # Repository owner
DEFAULT_REPO=brent-bartosch/agent-orchestration   # Default issue repository

# Supabase (for event logging)
SUPABASE_URL=https://gbvogiyztczpryswgbrn.supabase.co
SUPABASE_SERVICE_ROLE=...                         # Service role key

# Logging
LOGS_ROOT=~/agent-logs                            # Where to save session logs
```

### Verify Setup

```bash
gh auth status                                    # Check GitHub CLI
echo $DEFAULT_REPO                                # Should show agent-orchestration
ls -la ~/agent-logs                               # Check logs directory exists
```

---

**This guide is your starting point for every session. Bookmark it, reference it often, and update it as workflows evolve.**

**Project Board**: https://github.com/users/brent-bartosch/projects/2
**Repository**: https://github.com/brent-bartosch/agent-orchestration
**Documentation**: [docs/](docs/)
