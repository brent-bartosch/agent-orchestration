#!/bin/bash
#
# create_issue.sh - Create GitHub issues from the command line
#
# Usage:
#   ./create_issue.sh --title "Issue title" --body "Issue description" --labels "label1,label2"
#
# Options:
#   --title      Issue title (required)
#   --body       Issue body/description (optional)
#   --labels     Comma-separated list of labels (optional)
#   --assignee   Assign to user (optional, use "@me" for self)
#   --repo       Target repository (optional, defaults to agent-orchestration)
#   --template   Use issue template: scraper or agent (optional)
#   --help       Show this help message
#
# Environment Variables:
#   GITHUB_TOKEN           GitHub personal access token (required)
#   DEFAULT_ISSUE_REPO     Default repository for issues (optional)
#
# Examples:
#   # Simple issue
#   ./create_issue.sh --title "Fix scraper" --labels "auto:scraper,blocked"
#
#   # With full details
#   ./create_issue.sh \
#     --title "[Scraper] Product page failing" \
#     --body "Selector not working on new site layout" \
#     --labels "auto:scraper,scraper:selector" \
#     --assignee "@me"
#
#   # Using template
#   ./create_issue.sh --title "New feature" --template agent
#
# Note: Requires GitHub CLI (gh) to be installed and authenticated
#

set -e

# Default values
REPO="${DEFAULT_ISSUE_REPO:-brent-bartosch/agent-orchestration}"
TITLE=""
BODY=""
LABELS=""
ASSIGNEE=""
TEMPLATE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --title)
      TITLE="$2"
      shift 2
      ;;
    --body)
      BODY="$2"
      shift 2
      ;;
    --labels)
      LABELS="$2"
      shift 2
      ;;
    --assignee)
      ASSIGNEE="$2"
      shift 2
      ;;
    --repo)
      REPO="$2"
      shift 2
      ;;
    --template)
      TEMPLATE="$2"
      shift 2
      ;;
    --help)
      grep "^#" "$0" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Validate required arguments
if [ -z "$TITLE" ]; then
  echo "Error: --title is required"
  echo "Use --help for usage information"
  exit 1
fi

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed"
  echo "Install from: https://cli.github.com/"
  exit 1
fi

# Build the gh issue create command
CMD="gh issue create --repo $REPO --title \"$TITLE\""

# Add optional parameters
if [ -n "$BODY" ]; then
  CMD="$CMD --body \"$BODY\""
fi

if [ -n "$LABELS" ]; then
  CMD="$CMD --label \"$LABELS\""
fi

if [ -n "$ASSIGNEE" ]; then
  CMD="$CMD --assignee \"$ASSIGNEE\""
fi

if [ -n "$TEMPLATE" ]; then
  case $TEMPLATE in
    scraper|scraper-issue)
      CMD="$CMD --template scraper-issue.md"
      ;;
    agent|agent-issue)
      CMD="$CMD --template agent-issue.md"
      ;;
    *)
      echo "Error: Unknown template '$TEMPLATE'"
      echo "Available templates: scraper, agent"
      exit 1
      ;;
  esac
fi

# Execute the command
echo "Creating issue in $REPO..."
echo "Title: $TITLE"
[ -n "$LABELS" ] && echo "Labels: $LABELS"
[ -n "$ASSIGNEE" ] && echo "Assignee: $ASSIGNEE"
[ -n "$TEMPLATE" ] && echo "Template: $TEMPLATE"
echo ""

eval $CMD

# Check if creation was successful
if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Issue created successfully!"
  echo ""
  echo "Next steps:"
  echo "1. View your issue: gh issue view --web"
  echo "2. Add it to the Agent Kanban: https://github.com/users/brent-bartosch/projects/2"
  echo "3. Start working: gh issue comment <number> --body 'Starting work on this'"
else
  echo ""
  echo "❌ Failed to create issue"
  exit 1
fi
