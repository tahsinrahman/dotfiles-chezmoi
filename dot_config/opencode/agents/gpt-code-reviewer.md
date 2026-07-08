---
description: Reviews code changes using GPT-5.5 for quality, bugs, and best practices. Invoke this agent for code review after writing code.
mode: subagent
model: openai/gpt-5.5
variant: high
prompt: "{file:~/.config/opencode/prompts/shared/code-reviewer-prompt.md}"
tools:
  write: false
  edit: false
  bash: false
---
