# Session Logging Guide

This guide explains how to use session logs, how agents should log changes, and best practices for accuracy and reproducibility.

---

## Overview

Session logging provides a detailed, chronological record of what happened during an agent session. These logs are essential for:

- **Debugging** - Understanding what went wrong
- **Auditing** - Tracking who changed what and when
- **Reproducibility** - Recreating the exact steps taken
- **Learning** - Understanding patterns and improving workflows
- **Compliance** - Meeting documentation requirements

---

## Session Log Format

### File Naming Convention

```
~/agent-logs/<project>/<agent>/<timestamp>_<session-id>.md
```

**Examples:**
```
~/agent-logs/scraper-project/claude/20251114_143022_feature-123.md
~/agent-logs/crm-app/codex/20251114_150000_bugfix-456.md
~/agent-logs/orchestration/claude/20251114_160000_docs-update.md
```

### Components:

- **`<project>`** - Project identifier (matches repo name or logical grouping)
- **`<agent>`** - Agent type: `claude`, `codex`, `github-action`, `local-script`
- **`<timestamp>`** - Format: `YYYYMMDD_HHMMSS`
- **`<session-id>`** - Short descriptor: `feature-123`, `bugfix-456`, `docs-update`

---

## Standard Session Log Template

### Basic Template

```markdown
# Session Log: [Brief Description]

**Date:** YYYY-MM-DD HH:MM:SS UTC
**Agent:** Claude Code / Codex / GitHub Action / Local Script
**Project:** project-name
**Related Issue:** #123 (if applicable)
**Repository:** owner/repo-name

---

## Objective

Clear statement of what this session aims to accomplish.

**Success Criteria:**
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

---

## Actions Taken

### HH:MM - Action Description

**What:** Brief description of the action
**Why:** Reason for taking this action
**How:** Method or approach used

**Files Changed:**
- `path/to/file1.ts` - Added new function `foo()`
- `path/to/file2.ts` - Updated type definitions

**Commands Run:**
```bash
pnpm install new-package
pnpm test
```

**Output/Results:**
```
[Relevant output from commands]
```

---

### HH:MM - Next Action

[Repeat for each major action]

---

## Test Results

**Test Command:**
```bash
pnpm test
```

**Results:**
```
Test Suites: 5 passed, 5 total
Tests:       45 passed, 45 total
Time:        2.345s
```

**Coverage:**
- Statements: 87.5%
- Branches: 82.1%
- Functions: 91.2%
- Lines: 87.3%

---

## Issues Encountered

### Issue 1: [Brief Description]

**Problem:** What went wrong
**Investigation:** Steps taken to diagnose
**Solution:** How it was resolved
**Prevention:** How to avoid in the future

---

## Decisions Made

### Decision 1: [Decision Title]

**Context:** Why this decision was needed
**Options Considered:**
1. Option A - Pros/Cons
2. Option B - Pros/Cons
3. Option C - Pros/Cons

**Decision:** Chose Option B
**Rationale:** Reasoning for this choice
**Implications:** What this means going forward

---

## Action Items / Follow-up

- [ ] Task to be done later
- [ ] Another follow-up task
- [ ] Research needed for X

---

## Session Summary

**Start Time:** HH:MM
**End Time:** HH:MM
**Duration:** X hours Y minutes

**Accomplishments:**
- Completed objective A
- Partially completed objective B
- Discovered issue C

**Incomplete Work:**
- Objective D still in progress
- Waiting on external dependency for E

**Next Session:**
- Continue with objective D
- Address issue C
- Review and refactor code from this session

---

## Metadata

**Commits:**
- abc123: "Add feature X"
- def456: "Update tests for feature X"

**Issues:**
- Created: #124 - "Follow-up task for X"
- Updated: #123 - "Added test results"
- Closed: #122 - "Bug fix verified"

**Dependencies Added:**
- package-name@1.2.3

**Environment:**
- Node: v18.17.0
- npm: 9.8.1
- OS: macOS 14.0
```

---

## How Agents Should Log Changes

### Logging Principles

1. **Log continuously** - Don't wait until the end
2. **Be specific** - Include exact commands, file paths, line numbers
3. **Include context** - Why, not just what
4. **Timestamp everything** - Makes debugging easier
5. **Log errors in full** - Stack traces, error messages, context

### Real-Time Logging Pattern

As Claude Code works:

```markdown
## Actions Taken

### 14:30 - Initialize Project Structure

**What:** Created initial folder structure and package.json
**Why:** Setting up new scraper project from scratch
**How:** Using npm init and manual folder creation

**Commands:**
```bash
mkdir -p src tests docs
npm init -y
npm install playwright typescript @types/node
```

**Files Created:**
- `src/index.ts` - Main entry point
- `src/scraper.ts` - Scraper logic
- `tests/scraper.test.ts` - Test suite
- `package.json` - Project configuration

---

### 14:45 - Implement Core Scraper Logic

**What:** Added product scraping functionality
**Why:** Need to extract product data from target website
**How:** Using Playwright to navigate and CSS selectors to extract data

**Files Changed:**
- `src/scraper.ts` - Lines 1-85 (new file)
  - Added `scrapePage()` function
  - Added `extractProductData()` helper
  - Added error handling and retry logic

**Key Code:**
```typescript
async function scrapePage(url: string): Promise<Product[]> {
  const browser = await chromium.launch();
  const page = await browser.newPage();

  try {
    await page.goto(url, { waitUntil: 'networkidle' });
    const products = await page.$$eval('.product-card', cards =>
      cards.map(card => ({
        title: card.querySelector('.title')?.textContent,
        price: card.querySelector('.price')?.textContent
      }))
    );
    return products;
  } finally {
    await browser.close();
  }
}
```

**Testing:**
```bash
$ pnpm test
✓ scrapePage should extract products (1234ms)
✓ scrapePage should handle empty results (234ms)
```

---

### 15:00 - Debug Selector Issue

**What:** Fixed failing test for product price extraction
**Why:** Selector was too specific and broke on some product pages
**How:** Made selector more generic and added fallback

**Problem:**
```
Expected: 99.99
Received: null
```

**Investigation:**
- Inspected HTML structure of failing product
- Found price in different element: `.sale-price` vs `.regular-price`
- Updated selector to handle both cases

**Solution:**
```typescript
const price = card.querySelector('.sale-price, .regular-price')?.textContent;
```

**Files Changed:**
- `src/scraper.ts:42` - Updated price selector

**Verification:**
```bash
$ pnpm test
✓ scrapePage should extract products (1234ms)
✓ scrapePage should handle sale prices (345ms)
✓ scrapePage should handle regular prices (234ms)
```
```

---

## Best Practices for Accuracy

### ✅ DO:

1. **Log immediately** - Don't rely on memory
2. **Include exact paths** - `src/components/Button.tsx:45-67`
3. **Copy/paste commands and output** - Don't paraphrase
4. **Document why, not just what** - Future you will thank you
5. **Log failed attempts** - Mistakes are valuable learning
6. **Use timestamps** - Makes correlation easier
7. **Include environment info** - Versions, OS, etc.
8. **Link to related issues/PRs** - Maintain traceability
9. **Save regularly** - Don't lose work if session crashes
10. **Use code blocks** - For commands, output, code snippets

### ❌ DON'T:

1. **Summarize too much** - Details matter
2. **Skip "obvious" steps** - Nothing is obvious later
3. **Omit errors** - Especially ones you fixed
4. **Forget to update** - Keep log current
5. **Use vague descriptions** - "Fixed the thing" isn't helpful
6. **Leave out timing** - When things happened matters
7. **Skip test results** - Always log tests
8. **Forget to commit the log** - It's only useful if it's saved

---

## Reproducibility

A good session log should allow someone (including future you) to:

1. **Understand the objective** - What were you trying to do?
2. **Follow the steps** - What exact commands were run?
3. **Reproduce the result** - Get the same outcome
4. **Understand decisions** - Why things were done a certain way
5. **Identify issues** - What went wrong and how it was fixed

### Reproducibility Checklist

Before closing a session:

- [ ] All commands include exact syntax
- [ ] All file changes are documented with paths
- [ ] All dependencies and versions are noted
- [ ] All environment variables are documented (values redacted if sensitive)
- [ ] All errors and solutions are captured
- [ ] All test results are included
- [ ] All commits are listed
- [ ] All related issues are linked

---

## Integration with Issue Tracking

### Linking Logs to Issues

Reference the log file in the issue:

```markdown
## Session Log

See detailed session log: [session_20251114_143022.md](https://github.com/brent-bartosch/agent-orchestration/blob/main/logs/session_20251114_143022.md)

**Summary:**
- Implemented feature X
- Added tests (45 passing)
- Deployed to staging
```

### Extracting Action Items from Logs

After a session, review the log and create issues for:

- Incomplete work
- Follow-up tasks
- Bugs discovered
- Improvements identified

```bash
# Example: Create issue from session log finding
gh issue create --title "[Follow-up] Refactor scraper error handling" \
  --body "During session on 2025-11-14, discovered error handling could be improved. See session log for details: logs/session_20251114.md" \
  --label "auto:agent"
```

---

## Automated Session Logging

### Using the Collector

The file-drop collector automatically processes session logs:

1. Save session log to `~/agent-logs/<project>/claude/*.md`
2. Collector watches directory
3. Extracts action items from `## Action Items` section
4. Creates GitHub issues automatically
5. Logs events to Supabase

### Session Log Action Items

Include an action items section in your log:

```markdown
## Action Items

- [ ] Add pagination to product scraper
- [ ] Improve error messages in validator
- TODO: Research anti-bot bypass techniques
- [ ] Update documentation with new API
```

These will be automatically promoted to GitHub Issues.

---

## Session Log Repository

### Organization

```
logs/
├── manual-tests/
│   └── 20251114-scraper-test.md
├── sessions/
│   ├── 2025-11/
│   │   ├── 20251114_143022_feature-123.md
│   │   ├── 20251114_160000_docs-update.md
│   │   └── 20251115_090000_bugfix-456.md
│   └── 2025-12/
│       └── ...
└── deployments/
    └── 20251114_deployment.md
```

### Retention Policy

- **Keep all logs** in git history (they compress well)
- **Archive old logs** to separate directory after 6 months
- **Never delete logs** - disk space is cheap, context is valuable

---

## Example: Real Session Log

See [example-session-log.md](../logs/example-session-log.md) for a complete, real-world example.

---

## Quick Start

### Create Session Log

```bash
# Create log file
mkdir -p ~/agent-logs/my-project/claude
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SESSION_FILE=~/agent-logs/my-project/claude/${TIMESTAMP}_feature-123.md

# Copy template
cp templates/session-log-template.md $SESSION_FILE

# Open in editor
code $SESSION_FILE

# ... work on task, update log as you go ...

# When done, copy to repo
cp $SESSION_FILE logs/sessions/$(date +%Y-%m)/
git add logs/sessions/
git commit -m "Add session log for feature 123"
```

---

## Next Steps

- Create your first session log using the template
- Review [AGENT_WORKFLOW.md](AGENT_WORKFLOW.md) for how logs fit into the workflow
- Review [ISSUE_GUIDE.md](ISSUE_GUIDE.md) for linking logs to issues
- Set up the file-drop collector to process your logs automatically
