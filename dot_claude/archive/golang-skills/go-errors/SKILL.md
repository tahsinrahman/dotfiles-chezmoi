---
name: go-errors
description: Go error handling - structure, wrapping, logging, panics, error elimination patterns. Use for code reviews checking error handling quality.
---

# Go Error Handling

## Core Rules

1. **Eliminate errors** by preventing error conditions
2. **Handle each error only once** - log OR return, not both
3. **Return early** on errors (guard clauses)
4. **Wrap with context**: `fmt.Errorf("operation: %w", err)` - put `%w` at end
5. **Assert errors for behavior, not type**
6. **Error strings**: lowercase, no trailing punctuation
7. **Don't panic** for normal error handling
8. **Use `error` type** for exported functions (not concrete types)

## Error String Formatting

Error strings should **not** be capitalized (unless proper nouns, exported names, or acronyms) and should **not** end with punctuation:

```go
// Good - lowercase, no punctuation
return errors.New("connection refused")
return fmt.Errorf("user %q not found", id)
return errors.New("TLS handshake failed")  // TLS is an acronym

// Bad - capitalized and punctuated
return errors.New("Connection refused.")
return fmt.Errorf("User not found!")
```

**Exception**: Full messages shown in logs or UI (not wrapped in other errors) can be capitalized.

## Eliminate Errors by Design

The best error handling is no error handling. Redesign APIs to eliminate error conditions.

**Example: CountLines improvement**

```go
// Before - requires error handling on every read
func CountLines(r io.Reader) (int, error) {
    br := bufio.NewReader(r)
    var lines int
    for {
        _, err := br.ReadString('\n')
        if err == io.EOF {
            return lines, nil
        }
        if err != nil {
            return 0, err
        }
        lines++
    }
}

// After - bufio.Scanner handles errors internally
func CountLines(r io.Reader) (int, error) {
    sc := bufio.NewScanner(r)
    var lines int
    for sc.Scan() {
        lines++
    }
    return lines, sc.Err()  // Check once at the end
}
```

`bufio.Scanner` shifts error handling into the type itself. The caller only checks `Err()` once after iteration.

## Helper Types for Error Absorption

Create helper types that absorb error handling internally, checked once at the end:

**errWriter pattern:**

```go
type errWriter struct {
    w   io.Writer
    err error
}

func (ew *errWriter) Write(p []byte) {
    if ew.err != nil {
        return  // Already errored, skip
    }
    _, ew.err = ew.w.Write(p)
}

// Usage - clean sequential writes
func writeResponse(w io.Writer, headers []Header, body []byte) error {
    ew := &errWriter{w: w}

    // No error checks needed inline
    for _, h := range headers {
        ew.Write([]byte(h.Key + ": " + h.Value + "\r\n"))
    }
    ew.Write([]byte("\r\n"))
    ew.Write(body)

    return ew.err  // Check once at the end
}
```

This pattern works when:
- Operations are sequential
- First error makes subsequent operations pointless
- Error details from the first failure are sufficient

## Return Error Type (Not Concrete)

Exported functions should return `error`, not concrete types:

```go
// Good - returns error interface
func Good() error { ... }

// Bad - concrete type can cause subtle bugs
func Bad() *os.PathError { ... }
```

A concrete `nil` pointer can become non-nil when wrapped in an interface.

## Avoid In-Band Errors

Don't return special values like `-1`, `nil`, or empty string to signal errors:

```go
// Bad - in-band error, easy to miss
func Lookup(key string) int  // returns -1 on error

// Good - explicit error return
func Lookup(key string) (value string, ok bool)

// Good - error return
func Lookup(key string) (string, error)
```

In-band errors cause bugs when callers forget to check:

```go
// Bad - Parse receives -1 without knowing it's an error
return Parse(Lookup(missingKey))

// Good - forces error handling
value, ok := Lookup(key)
if !ok {
    return fmt.Errorf("no value for %q", key)
}
return Parse(value)
```

## Indent Error Flow

Handle errors **before** proceeding. Keep the happy path unindented:

```go
// Good - error handling first, normal code unindented
if err != nil {
    // error handling
    return err
}
// normal code continues here

// Bad - normal code indented in else
if err != nil {
    // error handling
} else {
    // normal code awkwardly indented
}
```

For multi-line variable use, prefer standard `if` over `if-with-initializer`:

```go
// Good - when variable used across many lines
x, err := f()
if err != nil {
    return err
}
// lots of code using x...

// Avoid - awkward when variable used extensively
if x, err := f(); err != nil {
    return err
} else {
    // lots of code using x in else block
}
```

## Error Structure

Give errors structure for programmatic inspection:

```go
// Sentinel errors - simple cases
var (
    ErrDuplicate = errors.New("duplicate")
    ErrMarsupial = errors.New("marsupials not supported")
)

// Check with errors.Is
if errors.Is(err, ErrDuplicate) { ... }

// Structured errors - when extra info needed
type PathError struct {
    Op   string
    Path string
    Err  error
}

// Check with errors.As
var pathErr *os.PathError
if errors.As(err, &pathErr) { ... }
```

**Don't match error strings:**
```go
// Bad - brittle
if regexp.MatchString(`duplicate`, err.Error()) { ... }
```

## Adding Context

Add relevant context, don't duplicate underlying error info:

```go
// Good - adds meaning
if err := os.Open("settings.txt"); err != nil {
    return fmt.Errorf("launch codes unavailable: %v", err)
}
// Output: launch codes unavailable: open settings.txt: no such file or directory

// Bad - duplicates path
return fmt.Errorf("could not open settings.txt: %v", err)
// Output: could not open settings.txt: open settings.txt: no such file or directory

// Bad - no value added
return fmt.Errorf("failed: %v", err)  // just return err
```

## %w vs %v Wrapping

**Use %v** for:
- Simple annotation
- System boundaries (RPC, storage, logging)
- Transforming/hiding internal errors

```go
// At RPC boundary - hide internals
return status.Errorf(codes.Internal, "couldn't find database: %v", err)
```

**Use %w** when:
- Caller needs `errors.Is()` / `errors.As()`
- Preserving error chain for programmatic inspection
- Documented as part of API contract

```go
// Internal helper - preserve for inspection
return fmt.Errorf("couldn't find remote file: %w", err)
```

## Placement of %w

**Always place %w at end** so error chain prints newest-to-oldest:

```go
// Good - prints: err3: err2: err1
err1 := fmt.Errorf("err1")
err2 := fmt.Errorf("err2: %w", err1)
err3 := fmt.Errorf("err3: %w", err2)

// Bad - prints: err1: err2: err3 (confusing)
err2 := fmt.Errorf("%w: err2", err1)
```

## Error Documentation

Document significant errors in function signatures:

```go
// Read reads up to len(b) bytes from the File.
// At end of file, Read returns 0, io.EOF.
func (*File) Read(b []byte) (n int, err error)

// Chdir changes the current working directory.
// If there is an error, it will be of type *PathError.
func Chdir(dir string) error
```

Note pointer vs non-pointer: `*PathError` enables correct `errors.Is`/`errors.As` usage.

**Package-level documentation** for common patterns:
```go
// Package os provides a platform-independent interface to operating system
// functionality.
//
// Often, more information is available within the error. For example, if a
// call that takes a file name fails, the error will include the failing file
// name and will be of type *PathError.
package os
```

## Logging Errors

- **Don't duplicate**: if you return an error, don't also log it
- Let caller decide to log, rate-limit, recover, or stop
- Use `log.Error` sparingly - it causes flush and is expensive
- ERROR level should be **actionable**, not just "more serious"

## Intentionally Discarding Errors

When intentionally ignoring an error, document why with a comment:

```go
// Good - documented intentional discard
_ = file.Close() // Best-effort cleanup, already handled main error

// Good - explicit blank identifier with comment
if _, err := writer.Write(data); err != nil {
    // Log but don't fail - this is non-critical telemetry
    log.V(1).Infof("telemetry write failed: %v", err)
}

// Bad - silent discard without explanation
file.Close()  // Error ignored silently
```

**Custom verbosity:**
```go
// Good - cheap check before expensive call
for _, sql := range queries {
    log.V(1).Infof("Handling %v", sql)
    if log.V(2) {
        log.Infof("Handling %v", sql.Explain())
    }
}

// Bad - sql.Explain called even when not logging
log.V(2).Infof("Handling %v", sql.Explain())
```

**Verbosity conventions:**
- V(1): Small amount of extra information
- V(2): Trace more information
- V(3): Dump large internal states

## Program Initialization

- Propagate init errors to `main`
- Use `log.Exit` with actionable message, not `log.Fatal` (stack trace unhelpful)

## Panic

**Don't panic for normal errors.** Use only for:
- Invariant violations indicating bugs (unrecoverable state)
- API misuse (like `reflect` panics)
- Unreachable code after `log.Fatal`

```go
func answer(i int) string {
    switch i {
    case 42:
        return "yup"
    default:
        log.Fatalf("Sorry, %d is not the answer.", i)
        panic("unreachable")
    }
}
```

**Internal panic/recover pattern** (rare):
```go
func Parse(in string) (_ *Node, err error) {
    defer func() {
        if p := recover(); p != nil {
            sErr, ok := p.(*syntaxError)
            if !ok {
                panic(p)  // Not ours, re-panic
            }
            err = fmt.Errorf("syntax error: %v", sErr.msg)
        }
    }()
    // ... parsing code that may panic with *syntaxError
}
```

Never let panics escape package boundaries.

## Must Functions

Only for:
- Package initialization: `var re = regexp.MustCompile(...)`
- Test helpers

```go
// OK - package init
var defaultTemplate = template.Must(template.New("").Parse(tmpl))

// Bad - runtime Must
func handler(w http.ResponseWriter, r *http.Request) {
    t := template.Must(template.ParseFiles(r.URL.Path))  // Don't
}
```
