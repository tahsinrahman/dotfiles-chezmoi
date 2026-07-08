---
description: Reviews code changes using Claude Opus for deep analysis, architectural review, and subtle bug detection. Invoke for thorough code review.
mode: subagent
model: anthropic/claude-opus-4-8
variant: high
temperature: 1
prompt: "{file:~/.config/opencode/prompts/shared/code-reviewer-prompt.md}"
tools:
  write: false
  edit: false
  bash: false
---
