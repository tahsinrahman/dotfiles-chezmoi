---
description: Creates detailed implementation plans using Claude Opus. Use for planning features and bug fixes before writing code.
mode: primary
model: anthropic/claude-opus-4-8
variant: high
color: "#e040fb"
prompt: "{file:~/.config/opencode/prompts/shared/planner-prompt.md}"
tools:
  write: false
  edit: false
  bash: true
permission:
  bash:
    "*": deny
    "go *": allow
    "git *": allow
    "grep *": allow
    "rg *": allow
    "find *": allow
    "ls *": allow
    "cat *": allow
    "head *": allow
    "tail *": allow
    "wc *": allow
    "make *": deny
---
