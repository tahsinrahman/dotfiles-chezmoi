---
description: Creates detailed implementation plans using GPT-5.5 and pressure-tests them with Claude Opus.
mode: primary
model: openai/gpt-5.5
variant: high
color: "#10a37f"
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
