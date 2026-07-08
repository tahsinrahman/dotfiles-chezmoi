---
description: Reviews GPT implementation plans using Claude Opus and drives convergence on a final agreed plan.
mode: subagent
model: anthropic/claude-opus-4-8
variant: high
temperature: 1
prompt: "{file:~/.config/opencode/prompts/shared/plan-reviewer-prompt.md}"
tools:
  write: false
  edit: false
  bash: true
permission:
  bash:
    "*": deny
    "go *": allow
    "git diff *": allow
    "git show *": allow
    "git status *": allow
    "git log *": allow
    "git rev-parse *": allow
    "git grep *": allow
    "rg *": allow
    "ls *": allow
---
