#!/bin/bash
set -eo pipefail

issues=$(cat issues/*.md 2>/dev/null || echo "No issues found.")
commits=$(git log -n 5 --format="%H%h%ad%n%B---" --date=short 2>/dev/null || echo "No commits found.")
prompt=$(cat PROMPT.md 2>/dev/null || echo "No prompt found.")

claude --permission-mode acceptEdits \
   "Previous issues:\n$issues\n\nRecent commits:\n$commits\n\nPrompt:\n$prompt"