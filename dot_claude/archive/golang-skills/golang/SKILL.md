---
name: golang
description: Go style overview and guiding principles. Use specific modules for targeted guidance on naming, errors, testing, API design, or concurrency.
---

# Go Style Guidelines

Sources:
- [Google Go Style Guide](https://google.github.io/styleguide/go/guide)
- [Google Go Style Decisions](https://google.github.io/styleguide/go/decisions)
- [Google Go Best Practices](https://google.github.io/styleguide/go/best-practices)

## Style Principles (in order of importance)

1. **Clarity** - Code's purpose and rationale is clear to the reader
2. **Simplicity** - Accomplishes goals in the simplest way possible
3. **Concision** - High signal-to-noise ratio
4. **Maintainability** - Easy to modify correctly
5. **Consistency** - Consistent with broader codebase

## Focused Modules

| Skill | Purpose |
|-------|---------|
| `go-naming` | Identifiers, packages, constants, imports, comments, initialisms |
| `go-errors` | Error handling, wrapping, in-band errors, indent flow, panics |
| `go-testing` | Table tests, assertion anti-patterns, cmp.Diff, subtest naming |
| `go-api-design` | Interfaces, options, receiver types, generics, literal formatting |
| `go-concurrency` | Goroutine lifetimes, channels, synchronization |

## Core Formatting

- All code must pass `gofmt`
- Use `MixedCaps` not `snake_case`
- No fixed line length - prefer refactoring over splitting

## Least Mechanism

Prefer simpler solutions:
1. Core language (channel, slice, map, loop, struct)
2. Standard library
3. Well-known libraries
4. New dependencies (last resort)

## Quick Reference

### Variable Declarations
```go
var count int           // zero value
name := "default"       // non-zero
msg := new(pb.Message)  // pointer to zero
items := []int{1, 2, 3} // known values
```

### Imports
```go
import (
    "context"                    // 1. Standard library
    "github.com/org/repo/pkg"    // 2. Third-party
    foopb "path/to/foo_go_proto" // 3. Protos with pb suffix
    _ "github.com/lib/pq"        // 4. Side-effects (main/tests only)
)
```

### Error Handling
```go
// Handle errors first, keep happy path unindented
if err != nil {
    return fmt.Errorf("operation: %w", err)  // %w at end
}
// normal code continues here
```

### Testing
```go
// Use cmp.Diff, not assertion libraries
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("Foo() mismatch (-want +got):\n%s", diff)
}

// Format: Function(input) = got, want expected
t.Errorf("Parse(%q) = %v, want %v", input, got, want)
```

### Comments
- Doc comments start with the name being described
- **Focus on WHY** - code shows what/how, comments explain rationale
- All exported symbols should have doc comments
- Don't comment bad code - rewrite it

### String Concatenation
```go
key := "prefix: " + s                    // Simple cases
str := fmt.Sprintf("%s [%d]", name, id)  // Formatting
b := new(strings.Builder)                // Loop concatenation
for _, v := range items {
    fmt.Fprintf(b, "%v\n", v)
}
```

### Common Patterns
- Use `%q` for strings in logs/errors
- Preallocate only when size known empirically
- Check emptiness with `len(s) == 0`, not `s == nil`
- Signal boost unusual conditions: `if err == nil { // if NO error`
- Don't use assertion libraries - use `cmp.Diff`
- Constants use `MixedCaps`, never `ALL_CAPS` or `kPrefix`
- Keep function signatures on single line
- Don't line-break `if` conditions
- Error strings: lowercase, no trailing punctuation

### Cryptography

**NEVER use `math/rand` for security-sensitive values:**

```go
// Good - cryptographically secure
import "crypto/rand"

key := make([]byte, 32)
rand.Read(key)

// Bad - predictable, insecure
import "math/rand"

key := rand.Int63()  // NEVER for tokens, keys, or secrets
```

Use `crypto/rand` for: keys, tokens, secrets, nonces, session IDs, anything security-related.
