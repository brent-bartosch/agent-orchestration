# Architecture Overview

This document describes the vision and architecture of the multi-agent orchestration system, how different repositories fit together, and the role of Supabase as the event ledger.

---

## Vision: Multi-Agent System with Unified Control

The **agent-orchestration** repository serves as the **central control tower** for a distributed, multi-agent development ecosystem.

### Core Principles

1. **GitHub Issues as the Surface**
   - All work is tracked through Issues
   - Issues provide human-readable context
   - Issues can be created/updated by humans or agents

2. **GitHub Project as the Kanban**
   - Visual board at https://github.com/users/brent-bartosch/projects/2
   - Shows all work across all repositories
   - Automated workflows move cards based on labels and state

3. **Supabase as the Event Ledger**
   - Immutable log of all agent actions
   - Queryable history for debugging and analysis
   - Foundation for future analytics and automation

4. **Distributed Repositories**
   - Each project has its own repository
   - All issues flow to the central Kanban
   - Agents can work across repositories

---

## System Components

```
┌─────────────────────────────────────────────────────────────────┐
│                   Agent Kanban Project Board                     │
│          https://github.com/users/brent-bartosch/projects/2     │
│                                                                  │
│   Inbox → To Do → In Progress → Needs Test → Ready → Done      │
└─────────────────────────────────────────────────────────────────┘
                            ▲
                            │ Issues flow here
                            │
┌───────────────────────────┴──────────────────────────────────────┐
│                                                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌────────────────┐ │
│  │ agent-           │  │ github-          │  │ web-scraper-   │ │
│  │ orchestration    │  │ bootstrap        │  │ repos          │ │
│  │                  │  │                  │  │                │ │
│  │ • Issue Templates│  │ • Collector      │  │ • Playwright   │ │
│  │ • Docs           │  │ • Supabase Sync  │  │ • HTTP Clients │ │
│  │ • Scripts        │  │ • Edge Functions │  │ • Data Models  │ │
│  └──────────────────┘  └──────────────────┘  └────────────────┘ │
│                                                                   │
└───────────────────────────┬──────────────────────────────────────┘
                            │ Events logged here
                            ▼
                   ┌─────────────────────┐
                   │  Supabase Ledger    │
                   │                     │
                   │  • events table     │
                   │  • issues table     │
                   │  • agents table     │
                   └─────────────────────┘
```

---

## Repository Roles

### 1. **agent-orchestration** (This Repo)

**Purpose:** Central control tower

**Responsibilities:**
- Issue template definitions
- Documentation for all agent workflows
- Shared scripts (create_issue.sh, sync_supabase.js, etc.)
- Home for cross-cutting concerns and orchestration logic

**Workflow:**
- Agents create issues here for multi-repo tasks
- Documentation lives here as the single source of truth
- Scripts can be called from any repository

**URL:** https://github.com/brent-bartosch/agent-orchestration

---

### 2. **github-bootstrap**

**Purpose:** Agent → GitHub → Supabase infrastructure

**Responsibilities:**
- File-drop collector that watches `~/agent-logs/`
- Parses Claude Code/Codex transcripts
- Promotes action items to GitHub Issues
- Supabase Edge Function for GitHub webhooks
- CLI tool (`agent-progress.js`) for updating issues

**Workflow:**
- Collector runs in background, watching for new transcript files
- When transcripts are saved, action items are extracted
- Issues are created in the appropriate repository
- Webhook syncs changes back to Supabase

**URL:** https://github.com/brent-bartosch/github-bootstrap

**Integration:**
- Transcripts saved to `~/agent-logs/<project>/claude/*.md`
- Collector reads transcripts and creates issues in `agent-orchestration`
- Events logged to Supabase `events` table

---

### 3. **Scraping / Application Repos** (Placeholders)

**Examples:**
- `my-web-scraper-repo`
- `my-crm-repo`
- `data-pipeline-repo`

**Purpose:** Specific application logic

**Responsibilities:**
- Application-specific code (scrapers, APIs, UIs)
- Application-specific tests
- Application-specific workflows

**Workflow:**
- Create issues in `agent-orchestration` for new features/bugs
- Link issues to PRs in the application repo
- Issues automatically appear on the Agent Kanban
- Agent works across repos but tracks everything centrally

**Integration:**
- Issues tagged with `scraper:*` or app-specific labels
- Test results posted back to central issues
- Deployment events logged to Supabase

---

## Data Flow

### Issue Creation Flow

```
1. Agent identifies task
      ↓
2. Agent creates issue in agent-orchestration
      ↓
3. Issue automatically added to Agent Kanban (Project #2)
      ↓
4. GitHub webhook fires → Supabase Edge Function
      ↓
5. Event logged to Supabase events table
      ↓
6. Issue record created/updated in Supabase issues table
```

### Work Completion Flow

```
1. Agent completes work, commits code
      ↓
2. Commit message references issue (#123)
      ↓
3. Tests run (locally or CI)
      ↓
4. Test results posted to issue
      ↓
5. Label updated to "ready-for-review"
      ↓
6. Project board auto-moves to "Ready for Review"
      ↓
7. Human reviews and closes issue
      ↓
8. Project board auto-moves to "Done"
      ↓
9. Supabase logs final state
```

### Scraping Workflow

```
1. Scraper runs (scheduled or manual)
      ↓
2. Results logged to Supabase (custom table or events)
      ↓
3. If errors detected → create issue automatically
      ↓
4. Issue labeled "auto:scraper", "scraper:website-specific"
      ↓
5. Agent diagnoses and fixes
      ↓
6. Fix committed, tests run
      ↓
7. Issue closed when verified working
```

---

## Supabase Integration Goals

### Current State (v0)

**Implemented:**
- `issues` table - mirrors GitHub issues
- `events` table - logs all events (chat transcripts, issue promotions, GitHub webhooks)
- Edge Function - syncs GitHub changes to Supabase
- Collector - creates issues from transcripts

**Schema:**
```sql
-- issues table
CREATE TABLE issues (
  repo TEXT NOT NULL,
  number INTEGER NOT NULL,
  title TEXT NOT NULL,
  body TEXT,
  state TEXT NOT NULL CHECK (state IN ('open','closed')),
  labels TEXT[] DEFAULT '{}',
  assignees TEXT[] DEFAULT '{}',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (repo, number)
);

-- events table
CREATE TABLE events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project TEXT NOT NULL,
  repo TEXT,
  agent_id TEXT,
  type TEXT NOT NULL,
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  ts TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Future Goals (v1+)

**Planned:**
- Agent performance analytics
- Automatic issue prioritization based on event patterns
- Real-time dashboards showing agent activity
- Automated testing triggered by events
- Cross-repository dependency tracking
- Intelligent task routing (which agent for which task type)

**Tables to Add:**
```sql
-- agents table (future)
CREATE TABLE agents (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- 'claude-code', 'codex', 'github-action', etc.
  capabilities JSONB,
  active BOOLEAN DEFAULT TRUE,
  metadata JSONB
);

-- agent_tasks table (future)
CREATE TABLE agent_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT REFERENCES agents(id),
  issue_repo TEXT,
  issue_number INTEGER,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  status TEXT,
  result JSONB
);
```

---

## Agent Types and Capabilities

### Claude Code
- **Capabilities:** Code generation, refactoring, debugging, documentation
- **Integration:** File-drop collector parses `.md` transcripts
- **Issue Creation:** Automatic via collector or manual via `gh` CLI
- **Best For:** Complex development tasks, architecture decisions

### Codex
- **Capabilities:** Code completion, inline suggestions
- **Integration:** Similar to Claude Code
- **Issue Creation:** Manual or via editor integration
- **Best For:** Quick code fixes, boilerplate generation

### GitHub Actions
- **Capabilities:** CI/CD, testing, deployment automation
- **Integration:** Workflow runs create events
- **Issue Creation:** Automatic on test failures
- **Best For:** Automated testing, deployment

### Local Scripts
- **Capabilities:** Data processing, scraping, batch operations
- **Integration:** Scripts call `create_issue.sh` or Supabase API
- **Issue Creation:** Programmatic
- **Best For:** Scheduled jobs, data pipelines

---

## Cross-Repository Workflows

### Example: Adding a Feature Across Repos

1. **Issue created** in `agent-orchestration`:
   ```
   Title: [Feature] Add email notifications
   Labels: auto:agent, in-progress
   ```

2. **Work spans multiple repos:**
   - API changes in `backend-repo`
   - UI changes in `frontend-repo`
   - Email templates in `templates-repo`

3. **PRs link back** to the central issue:
   ```
   In backend-repo PR: "Implements API for #123"
   In frontend-repo PR: "Adds UI for #123"
   ```

4. **Testing happens** in each repo, results posted to central issue

5. **Issue closed** when all PRs merged and feature deployed

---

## Scaling Considerations

### When to Split Repos

**Split into separate repo when:**
- Code has distinct deployment pipeline
- Code has different team ownership
- Code has independent release cycle

**Keep in same repo when:**
- Code is tightly coupled
- Code shares dependencies
- Code deploys together

### When to Create Separate Projects

**Create new GitHub Project when:**
- Separate team needs their own view
- Different workflow/columns needed
- Confidential work requires access control

**Keep in same Project when:**
- Work should be visible across teams
- Unified prioritization needed
- Resource allocation requires full visibility

---

## Next Steps

1. **Set up remaining repos** with issue templates pointing to `agent-orchestration`
2. **Configure webhooks** for all repos to log to Supabase
3. **Build analytics dashboard** on top of Supabase events
4. **Add agent performance tracking**
5. **Implement automated task routing**

---

## References

- **Agent Kanban Project:** https://github.com/users/brent-bartosch/projects/2
- **GitHub Bootstrap Repo:** https://github.com/brent-bartosch/github-bootstrap
- **Agent Orchestration Repo:** https://github.com/brent-bartosch/agent-orchestration
- **Supabase Project:** (configured via environment variables)
