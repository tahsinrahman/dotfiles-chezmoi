---
name: go-api-design
description: Go API and package design - zero values, interfaces, options, guard clauses, project structure. Use for code reviews checking API quality.
---

# Go API & Package Design

**Principle**: "APIs should be easy to use and hard to misuse." — Josh Bloch

## Make the Zero Value Useful

Design types so their zero value is immediately usable without initialization:

```go
// sync.Mutex - zero value is unlocked, ready to use
var mu sync.Mutex  // No init needed
mu.Lock()

// bytes.Buffer - zero value is empty, ready for writes
var buf bytes.Buffer  // No init needed
buf.WriteString("hello")

// Slices - nil slice works with append
var items []string  // No init needed
items = append(items, "first")
```

**Nil receivers can provide default behavior:**

```go
type Config struct {
    path string
}

func (c *Config) Path() string {
    if c == nil {
        return "/usr/home"  // Sensible default
    }
    return c.path
}

// Usage
var cfg *Config  // nil
fmt.Println(cfg.Path())  // Works! Returns "/usr/home"
```

This enables callers to use types without checking for nil or calling constructors.

## Same-Type Parameters

```go
func Max(a, b int) int                // OK - commutative
func CopyFile(to, from string) error  // Dangerous - order matters!

// Fix with helper type
type Source string
func (src Source) CopyTo(dest string) error

// Or use options struct
func Copy(src, dst string, opts CopyOptions) error
```

## Nil Parameters

- Don't mix nil and non-nilable parameters
- Clear is better than concise
- Avoid public APIs with test-only parameters

## Varargs over Slices

```go
// Bad - forces caller to box single value
func ShutdownVMs(ids []string) error

// Good - clean call site
func ShutdownVMs(ids ...string) error

// Require at least one argument
func anyPositive(first int, rest ...int) bool
```

## Option Structs

When signature is growing complex, use option struct:

```go
type ReplicationOptions struct {
    Config              *replicator.Config
    PrimaryRegions      []string
    ReadonlyRegions     []string
    ReplicateExisting   bool
    ReplicationInterval time.Duration
    CopyWorkers         int
}

func EnableReplication(ctx context.Context, opts ReplicationOptions) {
    // ...
}

// Usage - self-documenting, omit defaults
storage.EnableReplication(ctx, storage.ReplicationOptions{
    Config:         config,
    PrimaryRegions: []string{"us-east1", "us-central2"},
})
```

Use when: all callers need options, many callers need many options, options shared between functions.

## Functional Options

```go
type ReplicationOption func(*replicationOptions)

func ReadonlyCells(cells ...string) ReplicationOption {
    return func(opts *replicationOptions) {
        opts.readonlyCells = append(opts.readonlyCells, cells...)
    }
}

func EnableReplication(ctx context.Context, config *Config, primary []string, opts ...ReplicationOption)

// Usage
storage.EnableReplication(ctx, config, []string{"po", "is"},
    storage.ReadonlyCells("ix", "gg"),
    storage.ReplicationInterval(1*time.Hour),
)
```

Use when: most callers need no options, many options exist, options need parameters.

**Accept parameters, not presence**: `FailFast(enable bool)` not `EnableFailFast()`.

## Interface Segregation

```go
// Bad - too specific
func Save(f *os.File, doc *Document) error

// Best - most specific requirement
func Save(w io.Writer, doc *Document) error
```

**Return concrete types, accept interfaces.**

Interfaces belong in the **consumer** package, not the implementation package.

## Variable Declarations

```go
// Zero value - use var
var coords Point
var primes []int

// Non-zero - use :=
name := "default"
i := 42

// Pointer to zero value - use new()
msg := new(pb.Message)
buf := new(bytes.Buffer)

// Known values - use composite literal
coords := Point{X: 10, Y: 20}
primes := []int{2, 3, 5, 7}
```

## Size Hints

Preallocate when size known from **empirical analysis**:

```go
buf := make([]byte, 131072)           // Known buffer size
q := make([]Node, 0, 16)              // Typical 8-10 elements
seen := make(map[string]bool, size)   // Known shard size
```

**Warning**: Preallocating more than needed wastes memory. When in doubt, use zero initialization.

## Nil Slices

```go
// Good - nil slice
var users []User

// Bad - unnecessary empty slice
users := []User{}
```

Check emptiness with `len(s) == 0`, not `s == nil`. Don't distinguish nil vs empty in APIs.

## Channel Direction

```go
func consume(ch <-chan int)   // receive only
func produce(ch chan<- int)   // send only
```

## Context

- Always first parameter: `func Do(ctx context.Context, ...)`
- Use `context.Background()` only in `main`, `init`, or tests (use `t.Context()` in Go 1.24+)
- Never store context in structs
- Don't create custom context types

## Guard Clauses - Return Early

Return early rather than nesting deeply. Preconditions and errors should exit immediately:

```go
// Bad - deeply nested happy path
func process(data *Data) error {
    if data != nil {
        if data.Valid {
            if data.Size > 0 {
                // actual work here (deeply indented)
                return nil
            } else {
                return errors.New("empty data")
            }
        } else {
            return errors.New("invalid data")
        }
    }
    return errors.New("nil data")
}

// Good - guard clauses, happy path at indent level 1
func process(data *Data) error {
    if data == nil {
        return errors.New("nil data")
    }
    if !data.Valid {
        return errors.New("invalid data")
    }
    if data.Size == 0 {
        return errors.New("empty data")
    }

    // actual work here (minimal indentation)
    return nil
}
```

**Benefits:**
- Reduces nesting and cognitive load
- Error conditions are explicit and front-loaded
- Happy path is clear and easy to follow
- Easier to add new preconditions

## Copying

Be careful copying structs from other packages. Some types **must not be copied**:

```go
// Bad - sync.Mutex must not be copied
b1 := bytes.Buffer{}
b2 := b1  // Slice in copy may alias array in original!

// Bad - value receiver makes a copy
type Record struct {
    buf bytes.Buffer
}
func (r Record) Process() { ... }  // Copies r.buf!

// Good - use pointer receiver
func (r *Record) Process() { ... }
```

If methods are on `*T`, don't copy values of type `T`.

## Pass by Value

Use pointers only when:
- Function needs to mutate the value
- Type contains sync primitives (sync.Mutex, etc.)
- Type is very large (benchmark first)

**Don't pass pointers just to save bytes:**

```go
// Good - small values passed by value
func Process(name string, count int) { ... }

// Bad - unnecessary pointer for small type
func Process(name *string, count *int) { ... }
```

## Receiver Type

Choose based on correctness, not performance:

| Condition | Receiver |
|-----------|----------|
| Method mutates receiver | Pointer `*T` |
| Contains sync.Mutex or similar | Pointer `*T` |
| Large struct or array | Pointer `*T` (may be more efficient) |
| Slice method doesn't reslice | Value `T` |
| Map, func, or channel | Value `T` |
| Small struct, no pointers | Value `T` |
| Built-in type (int, string) | Value `T` |

```go
// Good - value receiver for slice that doesn't reslice
type Buffer []byte
func (b Buffer) Len() int { return len(b) }

// Good - pointer receiver for mutation
func (c *Counter) Inc() { *c++ }

// Good - pointer for sync types
type Counter struct {
    mu    sync.Mutex
    total int
}
func (c *Counter) Add(n int) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.total += n
}
```

**Consistency**: Make all methods on a type either all pointer or all value receivers.

## Generics

Use generics when they fulfill business requirements, but **avoid premature use**:

```go
// Good - generic function when multiple types needed
func Keys[K comparable, V any](m map[K]V) []K { ... }

// Bad - generic when only one type used in practice
func Process[T Widget](w T) { ... }  // Just use Widget directly
```

**Rules:**
- If only one type instantiation exists, don't use generics
- Don't invent DSLs with generics (especially error handling)
- Prefer interfaces when they solve the problem
- Don't use `any` with excessive type switching

## Type Aliases

Use **type definitions** (`type T1 T2`) for new types.
Use **type aliases** (`type T1 = T2`) **only** for migration:

```go
// Type definition - creates new type
type UserID int64

// Type alias - refers to existing type (rare, for migration only)
type OldName = NewName
```

## Use `any` Over `interface{}`

Go 1.18+ - prefer `any` as it's more readable:

```go
// Good - Go 1.18+
func Process(data any) { ... }

// Acceptable - older code
func Process(data interface{}) { ... }
```

## Switch and Break

**Don't use `break` at end of switch cases** - Go breaks automatically:

```go
// Good - no break needed
switch x {
case "A", "B":
    buf.WriteString(x)
case "C":
    // handled elsewhere
default:
    return fmt.Errorf("unknown: %q", x)
}

// Bad - redundant break
switch x {
case "A":
    doSomething()
    break  // Unnecessary!
}
```

**In loops**, `break` in switch exits switch, not loop. Use labels:

```go
loop:
    for {
        switch x {
        case "done":
            break loop  // Exits the for loop
        }
    }
```

## Package Design

- Name for **service provided**, not contents
- Prefer fewer, larger packages
- Use `internal/` for project-private APIs

### Project Structure

**Prefer fewer, larger packages** over many small ones:

- Every package adds coordination cost
- Small packages often indicate premature abstraction
- Combine related functionality until a clear split emerges

**Keep `main` small:**

```go
// Good - main just wires things together
func main() {
    cfg := config.Load()
    db := database.Connect(cfg.DB)
    srv := server.New(db, cfg.Server)
    log.Fatal(srv.ListenAndServe())
}
```

`main` should only:
- Parse flags/config
- Initialize dependencies
- Run the application
- Handle fatal errors

**Arrange files by import statements:**

- Files with similar imports likely have similar concerns
- Group related files in the same package
- Consider splitting when import patterns diverge significantly

**Prefer internal tests to external tests:**

```go
// Internal test - same package, tests unexported functions
package server

func TestHandleRequest(t *testing.T) { ... }

// External test - different package, tests public API only
package server_test

func TestServer(t *testing.T) { ... }
```

Internal tests (`package foo`) allow testing unexported functions. External tests (`package foo_test`) ensure your public API is usable. Prefer internal tests for unit testing; use external tests to validate API ergonomics.

## Imports

### Blank Imports (Side-Effect Only)

Blank imports (`import _ "pkg"`) limited to:
- `main` packages
- Test files
- `embed` package with `//go:embed` directives

```go
// Good - in main.go
import _ "github.com/lib/pq"  // Register Postgres driver

// Bad - in library package
import _ "github.com/lib/pq"  // Don't force driver on all users
```

### Dot Imports (NEVER)

Never use dot imports - they make code origin unclear:

```go
// Bad - where does Println come from?
import . "fmt"
Println("hello")

// Good - explicit origin
import "fmt"
fmt.Println("hello")
```

## Flags

Define flags **only in `package main`**:

```go
// Good - flag names use snake_case
var (
    serverAddr = flag.String("server_addr", "localhost:8080", "Server address")
    maxRetries = flag.Int("max_retries", 3, "Maximum retry attempts")
)

// Bad - flag defined in library package (forces side effects on importers)
// Bad - camelCase flag names
var serverAddr = flag.String("serverAddr", "...", "...")
```

**Rules:**
- Flag names: `snake_case` (e.g., `server_addr`)
- Go variables: `camelCase` (e.g., `serverAddr`)
- Never export flags from library packages

## Global State (AVOID)

```go
// Bad - global registry
package sidecar
var registry = make(map[string]*Plugin)
func Register(name string, p *Plugin) error { ... }

// Good - instance-based
type Registry struct { plugins map[string]*Plugin }
func New() *Registry { ... }
func (r *Registry) Register(name string, p *Plugin) error { ... }
```

Global state problems:
- Multiple clients can't use different configurations
- Tests can't run in isolation or parallel
- Order-dependent initialization bugs
- Hidden coupling across packages

**Safe global state**:
- Logically constant (image.RegisterFormat)
- Observable behavior is stateless
- No external side effects

## String Concatenation

| Method | Use Case |
|--------|----------|
| `+` | Simple concatenation of few strings |
| `fmt.Sprintf` | Formatting with placeholders |
| `strings.Builder` | Loop concatenation (amortized O(n)) |
| `text/template` | Complex formatting |

```go
// Simple - use +
key := "projectid: " + p

// Formatting - use Sprintf
str := fmt.Sprintf("%s [%s:%d]-> %s", src, qos, mtu, dst)

// Loop - use strings.Builder
b := new(strings.Builder)
for i, d := range digits {
    fmt.Fprintf(b, "digit %d: %d\n", i, d)
}
str := b.String()
```

**Constant strings** - use backticks:
```go
usage := `Usage:

custom_tool [args]`
```

## Complex CLI with Subcommands

For CLI tools with subcommands (like `kubectl create`, `kubectl run`):

| Library | Notes |
|---------|-------|
| `subcommands` | Simple, recommended if no extra features needed |
| `cobra` | Many features, common outside Google, use `cmd.Context()` |

**Keep `main` small** - just wire dependencies and run.

**Warning**: cobra command functions should use `cmd.Context()` to obtain context, not `context.Background()`.

## Literal Formatting

### Field Names in Struct Literals

**Always use field names** for types from other packages:

```go
// Good - field names for external types
r := csv.Reader{
    Comma:   ',',
    Comment: '#',
}

// Bad - positional arguments break when fields change
r := csv.Reader{',', '#', 4, false}
```

For package-local types, field names are optional but often clearer.

### Matching Braces

Closing brace must align with opening line's indentation:

```go
// Good - closing brace aligns
good := []*Type{
    {Key: "multi"},
    {Key: "line"},
}

// Bad - closing brace on value line
bad := []*Type{
    {Key: "multi"},
    {Key: "line"}}
```

### Zero-Value Fields

Omit zero-value fields for cleaner code:

```go
// Good - only non-zero fields
ldb := leveldb.Open("/my/table", &db.Options{
    BlockSize:       1 << 16,
    ErrorIfDBExists: true,
})

// Bad - cluttered with zero values
ldb := leveldb.Open("/my/table", &db.Options{
    BlockSize:            1 << 16,
    ErrorIfDBExists:      true,
    BlockRestartInterval: 0,    // zero value - omit
    Comparer:             nil,  // zero value - omit
})
```

## Function Formatting

**Keep function signatures on a single line** to avoid indentation confusion:

```go
// Good - single line
func (r *SomeType) Method(foo1, foo2 string, bar int) error {
    // ...
}

// Bad - split signature causes confusion
func (r *SomeType) Method(foo1, foo2 string,
    bar int) error {  // Looks like function body!
    // ...
}
```

If too long, refactor (extract locals, use option struct) rather than splitting.

## Conditional Formatting

**Don't line-break `if` statements** - causes indentation confusion:

```go
// Good - condition on one line
if db.InTransaction() && db.KeysMatch(row.Key()) {
    return db.Error(...)
}

// Good - extract to locals
inTxn := db.InTransaction()
keysMatch := db.KeysMatch(row.Key())
if inTxn && keysMatch {
    return db.Error(...)
}

// Bad - second line looks like body
if db.InTransaction() &&
    db.KeysMatch(row.Key()) {  // Confusing!
    return db.Error(...)
}
```

**Variable on left in comparisons** (not "Yoda style"):

```go
// Good
if result == "foo" { ... }

// Bad - Yoda style
if "foo" == result { ... }
```
