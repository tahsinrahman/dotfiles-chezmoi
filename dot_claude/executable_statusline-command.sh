#!/bin/bash

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir_name=$(basename "$cwd")

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

parts=()
parts+=("$dir_name")

if [ -n "$remaining" ]; then
  parts+=("ctx: ${remaining}%")
fi

if git -C "$cwd" --no-optional-locks rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    parts+=("git: $branch")
  fi
fi

printf "%s" "$(IFS=' | '; echo "${parts[*]}")"
