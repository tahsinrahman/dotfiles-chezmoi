---
name: go-code-review
description: Run comprehensive Go code review with all Go best practice skills loaded
help: |
  Reviews Go code changes with comprehensive best practices from all Go skills.

  Usage: /go-code-review

  This command loads all Go-specific skills and performs inline code review:
  - golang: Go style overview and guiding principles
  - go-naming: Naming conventions for identifiers, packages, functions
  - go-errors: Error handling, wrapping, logging, panic patterns
  - go-testing: Table tests, helpers, acceptance tests, TestMain
  - go-api-design: API design, zero values, interfaces, options, guard clauses
  - go-concurrency: Goroutines, channels, synchronization patterns
---

# Go Code Review Command

## Step 1: Load All Go Skills

Load each Go skill using the Skill tool to get best practices context:

```
Skill tool: golang:golang
Skill tool: golang:go-naming
Skill tool: golang:go-errors
Skill tool: golang:go-testing
Skill tool: golang:go-api-design
Skill tool: golang:go-concurrency
```

## Step 2: Get Branch Changes

```bash
git fetch origin
git diff origin/main...HEAD --name-only -- "*.go"
git diff origin/main...HEAD -- "*.go"
```

## Step 3: Review Go Code

For each changed Go file, apply the loaded skills to check:

### Naming (go-naming)
- Variable and function naming clarity
- Package naming conventions
- Constant and type naming
- Comment quality and documentation
- Initialism handling (HTTP, URL, ID)

### Error Handling (go-errors)
- Error wrapping with context
- Error logging placement (log at handling point, not propagation)
- Panic vs error return decisions
- In-band error handling avoidance
- Error elimination patterns

### Testing (go-testing)
- Table-driven test structure
- Test helper usage with t.Helper()
- Subtest naming conventions
- Test coverage adequacy
- Mock and fake patterns

### API Design (go-api-design)
- Zero value usability
- Interface minimality (accept interfaces, return structs)
- Functional options pattern
- Guard clause usage
- Package structure

### Concurrency (go-concurrency)
- Goroutine lifecycle management
- Channel usage patterns
- Mutex and synchronization
- Race condition prevention
- Context cancellation handling

## Step 4: Present Findings

Summarize issues by category with:
- File path and line number
- Issue description
- Relevant Go guideline reference
- Suggested fix

Format:
```
## Code Review Summary

### Critical Issues
- {file}:{line} - {description}

### Naming
- {findings}

### Error Handling
- {findings}

### Testing
- {findings}

### API Design
- {findings}

### Concurrency
- {findings}

### Recommendations
- {actionable suggestions}
```
