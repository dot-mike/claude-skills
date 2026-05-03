#!/bin/bash
set -eo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <iterations>"
  exit 1
fi

stream_text='select(.type == "assistant").message.content[]? | select(.type == "text").text // empty | gsub("\n"; "\r\n") | . + "\r\n\n"'
final_result='select(.type == "result").result // empty'

for ((i=1; i<=$1; i++)); do
  echo "=== Iteration $i ==="

  tmpfile=$(mktemp)
  trap "rm -f $tmpfile" EXIT

  # Fetch open issues — GitHub preferred, fall back to local markdown
  if gh auth status &>/dev/null; then
    issues_raw=$(gh issue list --json number,title,body,comments,labels,state --limit 100 2>/dev/null)
    issues=$(printf "Issues JSON:\n%s" "$issues_raw")
  else
    issues_raw=$(cat issues/*.md 2>/dev/null || echo "No issues found.")
    issues=$(printf "Issues (local markdown):\n%s" "$issues_raw")
  fi

  commits=$(git log -n 10 --format="SHA: %H%nDate: %ad%n%nMessage:%n%B%n---" --date=short 2>/dev/null \
    || echo "No commits found.")

  methodology=$(cat PROMPT.md 2>/dev/null || echo "No methodology file found.")

  project=""
  if [ -f PROJECT.md ]; then
    project=$(printf "\nProject context:\n%s" "$(cat PROJECT.md)")
  fi

  prompt_text=$(printf "%s\n\nRecent commits (last 10):\n%s%s\n\n---\n\n%s" \
    "$issues" "$commits" "$project" "$methodology")

  claude \
    --permission-mode acceptEdits \
    --print \
    --verbose \
    --output-format stream-json \
    "$prompt_text" \
  | grep --line-buffered '^{' \
  | tee "$tmpfile" \
  | jq --unbuffered -rj "$stream_text"

  result=$(jq -r "$final_result" "$tmpfile")

  # Append session log entry
  {
    printf "\n## %s — Iteration %d\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$i"
    if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
      printf "Signal: COMPLETE\n"
    elif [[ "$result" == *"<promise>BLOCKED</promise>"* ]]; then
      printf "Signal: BLOCKED\n"
    else
      printf "Signal: none (continuing)\n"
    fi
  } >> afk-log.md

  if [[ "$result" == *"<promise>COMPLETE</promise>"* ]]; then
    echo ""
    echo "All tasks complete after $i iterations."
    exit 0
  fi

  if [[ "$result" == *"<promise>BLOCKED</promise>"* ]]; then
    echo ""
    echo "Agent blocked — check issues and intervene."
    exit 1
  fi
done
