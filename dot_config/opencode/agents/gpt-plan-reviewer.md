---
description: Reviews implementation plans using GPT-5.5. Critiques plans for completeness, correctness, and missed edge cases.
mode: subagent
model: openai/gpt-5.5
variant: high
prompt: "{file:~/.config/opencode/prompts/shared/plan-reviewer-prompt.md}"
tools:
  write: false
  edit: false
  bash: false
---
