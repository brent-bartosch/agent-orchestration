# Agent Orchestration

**Central control tower for multi-agent workflows, web scraping projects, testing agents, and Claude Code sessions.**

This repository serves as the unified orchestration layer for all agent-driven development work across multiple projects and repositories.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [How It Works](#how-it-works)
- [Issue Templates](#issue-templates)
- [GitHub Project Board](#github-project-board)
- [Agent Workflows](#agent-workflows)
- [Documentation](#documentation)
- [Scripts & Tools](#scripts--tools)
- [Integration Points](#integration-points)
- [Contributing](#contributing)

---

## Overview

The **agent-orchestration** repository is the control tower for a distributed, multi-agent development ecosystem:

- **📝 All Issues Live Here** - Central tracking for work across all projects
- **📊 Visual Kanban** - Connected to [Agent Kanban Project Board](https://github.com/users/brent-bartosch/projects/2)
- **📚 Single Source of Documentation** - How agents work, best practices, workflows
- **🔧 Shared Scripts** - Reusable automation for creating issues, running tests, syncing data
- **📖 Issue Templates** - Standardized formats for scraper and agent development tasks
- **🔄 Supabase Integration** - Event ledger for all agent activity

---

## 🤖 For AI Agents: Start Here

**If you're an LLM agent (Claude Code, Codex, etc.) starting a new session, read this first:**

👉 **[AGENT_START_HERE.md](AGENT_START_HERE.md)** 👈

This guide contains everything you need to:
- Create and manage issues
- Log tests and results
- Write session logs
- Avoid duplicate issues
- Integrate with the Kanban board
- Use Supabase event logging

**Bookmark it. Reference it every session.**

---

## Quick Start

### 1. Create Your First Issue

```bash
# Using the script
./scripts/create_issue.sh \
  --title "[Agent] Your task description" \
  --labels "auto:agent,in-progress" \
  --assignee "@me"

# Or using GitHub CLI directly
gh issue create --repo brent-bartosch/agent-orchestration \
  --title "[Scraper] Fix product extraction" \
  --template scraper-issue.md
```

### 2. View All Issues

```bash
# List all open issues
gh issue list --repo brent-bartosch/agent-orchestration

# List your assigned issues
gh issue list --repo brent-bartosch/agent-orchestration --assignee "@me"

# View on the Kanban board
open https://github.com/users/brent-bartosch/projects/2
```

### 3. Work on an Issue

```bash
# View issue details
gh issue view 123 --repo brent-bartosch/agent-orchestration

# Add a progress update
gh issue comment 123 --body "Working on this. Completed step 1, moving to step 2."

# Update labels as you progress
gh issue edit 123 --add-label "needs-test" --remove-label "in-progress"

# Close when done
gh issue close 123 --comment "Completed and verified working"
```

---

## Repository Structure

```
agent-orchestration/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── scraper-issue.md       # Template for scraping tasks
│   │   └── agent-issue.md         # Template for agent development
│   └── workflows/
│       ├── auto-label.yml         # Auto-label issues and add to project
│       └── sync-template.yml      # Placeholder for future Supabase sync
│
├── docs/
│   ├── AGENT_WORKFLOW.md          # How agents use issues and workflows
│   ├── ARCHITECTURE_OVERVIEW.md   # System architecture and vision
│   ├── ISSUE_GUIDE.md             # Complete guide to issue management
│   ├── TESTING_GUIDE.md           # Testing best practices
│   └── SESSION_LOGGING.md         # Session log format and best practices
│
├── scripts/
│   ├── create_issue.sh            # Create issues from command line
│   ├── sync_supabase.js           # Supabase sync (placeholder)
│   └── testing_runner.js          # Test automation (placeholder)
│
├── logs/
│   └── .gitkeep                   # Session logs, test results
│
└── README.md                      # This file
```

---

## How It Works

### The Agent Workflow

```
1. Work Identified → 2. Issue Created → 3. Added to Kanban → 4. Agent Works → 5. Tests Run → 6. Issue Closed
         ↓                ↓                  ↓                  ↓               ↓               ↓
    (Manual or       (This repo)      (GitHub Project)   (Any repo)      (CI/GitHub)     (Supabase logs)
     Automated)
```

### Data Flow

```
┌──────────────────────────────────────────────────────────────┐
│                 Agent Kanban Project Board                    │
│         https://github.com/users/brent-bartosch/projects/2   │
│                                                               │
│    Inbox → To Do → In Progress → Needs Test → Done           │
└───────────────────────────┬──────────────────────────────────┘
                            │ All issues appear here
                            ↓
┌───────────────────────────────────────────────────────────────┐
│                   agent-orchestration (This Repo)             │
│                                                               │
│  • Issue Templates                                            │
│  • Documentation                                              │
│  • Scripts                                                    │
│  • Workflows                                                  │
└───────────────────────────┬───────────────────────────────────┘
                            │ Issues reference work in
                            ↓
┌────────────────┬─────────────────┬──────────────────────────┐
│                │                 │                          │
│ github-        │  scraper-       │  other-application       │
│ bootstrap      │  projects       │  repos                   │
│                │                 │                          │
│ • Collector    │  • Playwright   │  • APIs                  │
│ • Edge Funcs   │  • HTTP Clients │  • UIs                   │
│ • CLI Tools    │  • Data Models  │  • Services              │
└────────┬───────┴────────┬────────┴───────────┬──────────────┘
         │                │                    │
         └────────────────┴────────────────────┘
                          │ All events logged to
                          ↓
                 ┌────────────────────┐
                 │  Supabase Ledger   │
                 │                    │
                 │  • issues table    │
                 │  • events table    │
                 └────────────────────┘
```

---

## Issue Templates

We have two main templates optimized for different types of work:

### 1. Scraper Issue Template

**Use for:**
- Building new scrapers
- Fixing broken scrapers
- Selector updates
- Data quality issues
- Anti-bot measures

**Create:**
```bash
gh issue create --template scraper-issue.md \
  --title "[Scraper] Target site product extraction failing"
```

### 2. Agent / General Issue Template

**Use for:**
- Agent development tasks
- Workflow improvements
- Infrastructure changes
- Documentation
- General development work

**Create:**
```bash
gh issue create --template agent-issue.md \
  --title "[Agent] Add automatic test runner"
```

See [docs/ISSUE_GUIDE.md](docs/ISSUE_GUIDE.md) for complete details on when to use each template and how to fill them out.

---

## GitHub Project Board

All issues in this repository are automatically added to the **Agent Kanban** project:

**🔗 Project URL:** https://github.com/users/brent-bartosch/projects/2

### Columns

| Column | Purpose |
|--------|---------|
| **Inbox** | New issues, not yet prioritized |
| **To Do** | Ready to work on, prioritized |
| **In Progress** | Actively being worked on |
| **Needs Test** | Code complete, awaiting tests |
| **Blocked** | Waiting on external dependency |
| **Ready for Review** | Complete, needs human review |
| **Done** | Closed and verified |

### Custom Fields

Each issue can have:
- **Agent** - Which agent is working (Claude Code, Codex, etc.)
- **Environment** - Where work happens (Local, Cloud, Browser, etc.)
- **Test Status** - Testing state (Not Tested, Passing, Failing, etc.)
- **Complexity** - Size estimate (S, M, L, XL)
- **Website** - Target site (for scrapers)

### Automatic Movement

Issues move between columns automatically:
- Assign someone → **In Progress**
- Add `needs-test` label → **Needs Test**
- Add `blocked` label → **Blocked**
- Add `ready-for-review` label → **Ready for Review**
- Close issue → **Done**

---

## Agent Workflows

Different agents interact with the system in different ways:

### Claude Code / Codex

1. Start VS Code session
2. Create or find relevant issue
3. Update issue with progress
4. Run tests and log results
5. Close issue when complete

**See:** [docs/AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md)

### GitHub Actions

1. Triggered by events (push, PR, schedule)
2. Run automated tasks
3. Create issues on failures
4. Post results to existing issues

### Local Scripts

1. Run on schedule or on-demand
2. Create issues for failures/anomalies
3. Update issues with status
4. Log events to Supabase

---

## Documentation

Comprehensive guides for all aspects of the system:

| Document | Purpose |
|----------|---------|
| **[AGENT_START_HERE.md](AGENT_START_HERE.md)** | **🤖 Quick start guide for AI agents - read this first!** |
| [AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md) | How agents use issues, testing, and logging |
| [ARCHITECTURE_OVERVIEW.md](docs/ARCHITECTURE_OVERVIEW.md) | System architecture and vision |
| [ISSUE_GUIDE.md](docs/ISSUE_GUIDE.md) | Complete issue management guide |
| [TESTING_GUIDE.md](docs/TESTING_GUIDE.md) | Testing best practices and automation |
| [SESSION_LOGGING.md](docs/SESSION_LOGGING.md) | Session log format and practices |

**For AI agents, start here:** [AGENT_START_HERE.md](AGENT_START_HERE.md)
**For humans, start here:** [docs/AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md)

---

## Scripts & Tools

### create_issue.sh

Create issues from the command line with rich options:

```bash
# Simple
./scripts/create_issue.sh --title "Fix bug"

# Full options
./scripts/create_issue.sh \
  --title "[Scraper] Site X failing" \
  --body "Detailed description" \
  --labels "auto:scraper,scraper:selector,blocked" \
  --assignee "@me" \
  --template scraper
```

**Help:** `./scripts/create_issue.sh --help`

### sync_supabase.js (Placeholder)

Future script for Supabase synchronization:
- Sync issues to/from Supabase
- Log agent events
- Query event history

**Current workaround:** Use the [github-webhook](https://github.com/brent-bartosch/github-bootstrap) Edge Function

### testing_runner.js (Placeholder)

Future script for automated test orchestration:
- Run tests across projects
- Aggregate results
- Post to issues
- Log to Supabase

**Current workaround:** Run `pnpm test` manually and post results

---

## Integration Points

### github-bootstrap Repository

The [github-bootstrap](https://github.com/brent-bartosch/github-bootstrap) repo provides infrastructure:

- **File-drop collector** - Watches `~/agent-logs/` for transcripts
- **Automatic issue creation** - Extracts action items from logs
- **Supabase Edge Function** - Syncs GitHub webhooks to Supabase
- **CLI tool** - `agent-progress.js` for updating issues

**Integration:**
1. Save Claude Code sessions to `~/agent-logs/<project>/claude/*.md`
2. Collector extracts action items marked with `## Action Items`
3. Issues auto-created in this repository
4. Events logged to Supabase

### Supabase

All agent activity is logged to Supabase for:
- Audit trail
- Analytics
- Debugging
- Performance tracking

**Tables:**
- `issues` - Mirrors GitHub issues
- `events` - All agent/system events

**Configuration:** Set in environment variables

### Other Repositories

Any repository can integrate by:
1. Creating issues in this repository
2. Linking PRs to issues here
3. Posting test results to issues
4. Using shared scripts from this repo

---

## Contributing

### Creating Issues

All work should start with an issue:

1. Check if issue already exists
2. Choose appropriate template
3. Fill out all sections
4. Add relevant labels
5. Assign if you'll work on it

### Working on Issues

1. Assign yourself to show you're working
2. Update issue with progress regularly
3. Log test results
4. Link commits/PRs
5. Close when complete

### Documentation

- Keep docs up to date as workflows change
- Add examples for clarity
- Link between related docs
- Use clear, concise language

### Testing

- Always run tests before closing issues
- Log test results to issues
- Fix failing tests before moving on
- Add tests for new features

See [docs/TESTING_GUIDE.md](docs/TESTING_GUIDE.md) for details.

---

## Labels

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
- `scraper:data-quality` - Data validation
- `scraper:website-specific` - Site-specific logic
- `supabase:schema` - Database schema
- `supabase:api` - Supabase API integration
- `infra:workflow` - CI/CD, automation
- `documentation` - Documentation work

---

## Environment Variables

Set these in your environment for full functionality:

```bash
# GitHub
GITHUB_TOKEN=ghp_...                    # Personal access token
DEFAULT_ISSUE_REPO=brent-bartosch/agent-orchestration

# Supabase (optional, for future scripts)
SUPABASE_URL=https://...
SUPABASE_SERVICE_ROLE=...

# Logging (optional)
LOGS_ROOT=~/agent-logs
```

---

## Next Steps

### For AI Agents

1. **Read [AGENT_START_HERE.md](AGENT_START_HERE.md)** - Everything you need for your first session
2. **Search for existing issues** before creating new ones
3. **Create or claim an issue** and add yourself as assignee
4. **Start working** and update the issue with progress
5. **Log your session** to `~/agent-logs/<project>/claude/` when done

### For Humans

1. **Create your first issue** using one of the templates
2. **Read the documentation** starting with [AGENT_WORKFLOW.md](docs/AGENT_WORKFLOW.md)
3. **Connect to the project** at https://github.com/users/brent-bartosch/projects/2
4. **Set up file-drop collector** from [github-bootstrap](https://github.com/brent-bartosch/github-bootstrap)
5. **Start working!** Update issues as you go

---

## Support & Questions

- **Issues:** Create an issue in this repository
- **Documentation:** Check the [docs/](docs/) directory
- **Examples:** See existing issues for templates

---

## License

This repository and its documentation are for internal use in coordinating multi-agent development workflows.

---

**Project Board:** https://github.com/users/brent-bartosch/projects/2
**GitHub Bootstrap:** https://github.com/brent-bartosch/github-bootstrap
**Supabase:** (configured via environment)
