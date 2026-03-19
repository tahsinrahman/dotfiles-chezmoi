---
name: go-testing
description: Go testing patterns - table tests, helpers, acceptance tests, TestMain. Use for code reviews checking test quality.
---

# Go Testing Patterns

## Don't Use Assertion Libraries

Assertion libraries are **not idiomatic** in Go. They:
- Stop tests early (missing other failures)
- Produce less useful failure messages
- Fragment the developer experience

```go
// Bad - assertion library
assert.IsNotNil(t, "obj", obj)
assert.StringEq(t, "obj.Type", obj.Type, "blogPost")

// Good - standard testing with cmp
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("Foo() mismatch (-want +got):\n%s", diff)
}
```

Use `cmp.Equal` and `cmp.Diff` from `github.com/google/go-cmp/cmp` instead.

## Leave Testing to Test Function

**Test helpers** do setup/cleanup - failures indicate environment issues.
**Assertion helpers** check correctness - not idiomatic in Go.

Keep failure logic in the Test function:
- Inline validation in Test, even if repetitive
- Use table-driven tests for similar inputs
- Validation functions should return errors, not take `testing.T`

```go
// Good - return error, don't accept testing.T
func ValidatePlayer(p Player) error {
    if p.Move() == nil {
        return errors.New("player returned nil move")
    }
    return nil
}

// Test uses the validator
func TestPlayer(t *testing.T) {
    if err := ValidatePlayer(NewPlayer()); err != nil {
        t.Errorf("ValidatePlayer failed: %v", err)
    }
}
```

## Test Failure Messages

Follow `YourFunc(%v) = %v, want %v` format:

```go
// Good - function, input, got, want
t.Errorf("Sum(%v, %v) = %v, want %v", a, b, got, want)

// Bad - unclear what failed
t.Errorf("wrong result")

// Bad - "expected" instead of "want"
t.Errorf("got %v, expected %v", got, want)
```

### Identify the Function

Include the function name even if it seems obvious:

```go
// Good
t.Errorf("Encode(%q) = %q, want %q", input, got, want)

// Bad - which function?
t.Errorf("got %q, want %q", got, want)
```

### Identify the Input

Include inputs, especially for short values:

```go
// Good - input included
t.Errorf("Parse(%q) = %v, want %v", input, got, want)

// Good - for complex inputs, use descriptive test name
t.Run("empty_input", func(t *testing.T) {
    // test name provides context
})
```

## t.Error vs t.Fatal (Keep Going)

| Use | When |
|-----|------|
| `t.Fatal` | Setup failures where test can't proceed |
| `t.Error` | Test failures - **keep going** to find all problems |

```go
// t.Fatal for setup - can't continue without DB
db, err := setupDB()
if err != nil {
    t.Fatalf("setup failed: %v", err)
}

// t.Error for assertions - find ALL failures in one run
if got != want {
    t.Errorf("Got %v, want %v", got, want)
}
```

**Keep going** - prefer `t.Error` to show all failures:

```go
// Good - reports all mismatches
if diff := cmp.Diff(wantMean, gotMean); diff != "" {
    t.Errorf("mean mismatch (-want +got):\n%s", diff)
}
if diff := cmp.Diff(wantVariance, gotVariance); diff != "" {
    t.Errorf("variance mismatch (-want +got):\n%s", diff)
}

// Bad - stops at first failure
if gotMean != wantMean {
    t.Fatalf("mean = %v, want %v", gotMean, wantMean)
}
```

In table tests with `t.Run`, `t.Fatal` ends only the subtest.

## Don't Call t.Fatal from Goroutines

```go
// Good - use t.Error in goroutines
go func() {
    defer wg.Done()
    if err := engine.Vroom(); err != nil {
        t.Errorf("No vroom: %v", err)  // Not t.Fatalf
        return
    }
}()
```

`t.Parallel` does NOT make `t.Fatal` unsafe in the test function itself.

## Test Helpers

```go
func setupTestDB(t *testing.T) *DB {
    t.Helper()  // Failures report caller's line
    db, err := NewDB()
    if err != nil {
        t.Fatalf("setup failed: %v", err)
    }
    t.Cleanup(func() { db.Close() })
    return db
}
```

- Call `t.Helper()` so failures attribute to test function
- Use `t.Cleanup()` for teardown
- Describe what went wrong in failure messages

## Test Error Semantics

**Don't match error strings** - they change:

```go
// Bad - brittle string matching
if !strings.Contains(err.Error(), "not found") { ... }

// Good - use errors.Is for sentinel errors
if !errors.Is(err, ErrNotFound) { ... }

// Good - use errors.As for error types
var pathErr *os.PathError
if errors.As(err, &pathErr) { ... }
```

For simple error presence checks, use bool:

```go
// Good - when only error presence matters
if gotErr := err != nil; gotErr != test.wantErr {
    t.Errorf("f(%q) error = %v, want error presence = %v", input, err, test.wantErr)
}
```

## Table-Driven Tests

```go
tests := []struct {
    name    string
    input   string
    want    int
    wantErr bool
}{
    {
        name:  "valid_input",  // Underscores, not spaces or slashes
        input: "42",
        want:  42,
    },
    {
        name:    "invalid_input",
        input:   "abc",
        wantErr: true,
    },
}

for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got, err := Parse(tt.input)
        if (err != nil) != tt.wantErr {
            t.Errorf("Parse(%q) error = %v, wantErr %v", tt.input, err, tt.wantErr)
        }
        if got != tt.want {
            t.Errorf("Parse(%q) = %v, want %v", tt.input, got, tt.want)
        }
    })
}
```

- Use **field names** in struct literals
- **Omit zero-value fields**
- **Avoid slashes** in subtest names - issues with test filters

### Subtest Naming

Names should be **readable** and **filterable**:

```go
// Good - underscores, descriptive
t.Run("valid_email_format", ...)
t.Run("missing_required_field", ...)

// Bad - slashes break test filters
t.Run("AM/PM confusion", ...)  // Problematic!

// Bad - too verbose
t.Run("check that there is no mention of scratched records", ...)
```

Spaces become underscores in output. Slashes have special meaning for filters.

### Don't Use Index as Test Name

```go
// Bad - "Failed on case #3" is unhelpful
for i, tc := range tests {
    if got != tc.want {
        t.Errorf("Failed on case #%d", i)
    }
}

// Good - descriptive name
for _, tc := range tests {
    t.Run(tc.name, func(t *testing.T) {
        if got != tc.want {
            t.Errorf("Parse(%q) = %v, want %v", tc.input, got, tc.want)
        }
    })
}
```

## Equality Comparison

**Prefer `cmp.Diff`** over field-by-field comparison:

```go
// Good - full structure comparison
want := &Doc{Type: "blogPost", Comments: 2, Body: "..."}
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("AddPost() mismatch (-want +got):\n%s", diff)
}

// Bad - tedious field-by-field
if got.Type != want.Type {
    t.Errorf("Type = %v, want %v", got.Type, want.Type)
}
if got.Comments != want.Comments {
    t.Errorf("Comments = %v, want %v", got.Comments, want.Comments)
}
```

**Don't use `reflect.DeepEqual`** - it's sensitive to unexported fields:

```go
// Bad - breaks on unexported field changes
if !reflect.DeepEqual(got, want) { ... }

// Good - use cmp with options
if !cmp.Equal(got, want) { ... }
```

For protos, use `protocmp.Transform()`:

```go
if diff := cmp.Diff(want, got, protocmp.Transform()); diff != "" {
    t.Errorf("mismatch (-want +got):\n%s", diff)
}
```

## Compare Stable Results

Don't compare against output that may change:

```go
// Bad - json.Marshal output may change between Go versions
gotJSON, _ := json.Marshal(data)
if string(gotJSON) != `{"key":"value"}` { ... }

// Good - compare parsed structure
var got MyStruct
json.Unmarshal(gotJSON, &got)
if diff := cmp.Diff(want, got); diff != "" { ... }
```

## Print Diffs

Always include a **legend** explaining the diff direction:

```go
// Good - (-want +got) legend matches cmp.Diff output
if diff := cmp.Diff(want, got); diff != "" {
    t.Errorf("Foo() mismatch (-want +got):\n%s", diff)
}
```

Print newline before diff for readability.

## Use Real Transports

```go
// Good - real client with test server
srv := httptest.NewServer(handler)
client := &http.Client{}
resp, err := client.Get(srv.URL)
```

Use actual HTTP/RPC clients with test servers - minimizes differences from production.

## Scope Setup to Specific Tests

```go
// Good - only tests that need it call setup
func TestParseData(t *testing.T) {
    data := mustLoadDataset(t)  // Called explicitly
    // ...
}

func TestRegression(t *testing.T) {
    // Doesn't need dataset - doesn't pay for it
}
```

**Bad**: package-level `init()` that loads expensive data for all tests.

## Amortizing Common Setup

Use `sync.Once` when setup is expensive but doesn't need teardown:

```go
var dataset struct {
    once sync.Once
    data []byte
    err  error
}

func mustLoadDataset(t *testing.T) []byte {
    t.Helper()
    dataset.once.Do(func() {
        dataset.data, dataset.err = os.ReadFile("testdata/dataset")
    })
    if dataset.err != nil {
        t.Fatalf("Could not load dataset: %v", dataset.err)
    }
    return dataset.data
}
```

## TestMain

Use only when ALL tests need common setup WITH teardown:

```go
func TestMain(m *testing.M) {
    code, err := runMain(context.Background(), m)
    if err != nil {
        log.Fatal(err)
    }
    os.Exit(code)
}

func runMain(ctx context.Context, m *testing.M) (int, error) {
    db, err := setupDatabase(ctx)
    if err != nil {
        return 0, err
    }
    defer db.Close()

    globalDB = db
    return m.Run(), nil
}
```

## Acceptance Testing

For validating user implementations of your interfaces:

```go
// Good - return error, let test decide how to fail
func ExercisePlayer(b *chess.Board, p chess.Player) error {
    move := p.Move()
    if putsOwnKingIntoCheck(b, move) {
        return PutsSelfIntoCheckError{Move: move}
    }
    return nil
}

// User's test
func TestAcceptance(t *testing.T) {
    err := chesstest.ExerciseGame(t, chesstest.SimpleGame, player)
    if err != nil {
        t.Errorf("Player failed acceptance: %v", err)
    }
}
```

**Design principles:**
- Return structured errors for programmatic inspection
- Use `t.Fatal` only for setup failures, not test failures
- Aggregate all failures when tests are slow-running
- Keep "fail fast" for quick tests

**Providing cmp.Options:**
```go
// Good - reusable comparison option
func polygonCmp() cmp.Option {
    return cmp.Options{
        cmp.Transformer("polygon", func(p *s2.Polygon) []*s2.Loop { return p.Loops() }),
        cmpopts.EquateApprox(0.00000001, 0),
        cmpopts.EquateEmpty(),
    }
}

func TestFenceposts(t *testing.T) {
    got := Fencepost(tomsDiner, 1*meter)
    if diff := cmp.Diff(want, got, polygonCmp()); diff != "" {
        t.Errorf("Fencepost() mismatch (-want+got):\n%v", diff)
    }
}
```

## Context in Tests

Use `t.Context()` (Go 1.24+) instead of `context.Background()`:

```go
// Good - Go 1.24+
func TestFoo(t *testing.T) {
    ctx := t.Context()
    result, err := Foo(ctx)
    // ...
}

// Before Go 1.24
func TestFoo(t *testing.T) {
    ctx := context.Background()
    // ...
}
```

Document context behavior when non-obvious:

```go
// Good - document when context behavior differs
// Run executes the worker's run loop.
// If the context is cancelled, Run returns a nil error.
func (Worker) Run(ctx context.Context) error

// Good - document special context requirements
// NewReceiver starts receiving messages.
// The context should not have a deadline.
func NewReceiver(ctx context.Context) *Receiver
```

## Test Package Placement

### Same Package (Internal Tests)

```go
// foo_test.go
package foo  // Same package - can test unexported functions

func TestInternalHelper(t *testing.T) {
    // Can access unexported identifiers
}
```

**Prefer internal tests** for unit testing - they allow testing unexported functions and provide better coverage.

### Different Package (External Tests)

Use `_test` suffix for black-box testing:

```go
// foo_test.go
package foo_test  // Different package - only exported API

import "path/to/foo"

func TestPublicAPI(t *testing.T) {
    // Can only access foo.ExportedFunc
}
```

**When to use external tests:**
- Integration tests without obvious owning package
- Avoiding circular dependencies
- Validating public API ergonomics

## Runnable Examples

Include runnable examples in test files - they appear in Godoc and demonstrate intended usage:

```go
// example_test.go
package strings_test

import (
    "fmt"
    "strings"
)

func ExampleTrimSpace() {
    fmt.Println(strings.TrimSpace("  hello  "))
    // Output: hello
}

func ExampleBuilder() {
    var b strings.Builder
    b.WriteString("hello")
    b.WriteString(" world")
    fmt.Println(b.String())
    // Output: hello world
}
```

Examples must have `// Output:` comment to be runnable as tests.
