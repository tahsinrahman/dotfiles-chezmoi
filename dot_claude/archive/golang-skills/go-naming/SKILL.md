---
name: go-naming
description: Go naming conventions - identifiers, packages, functions, test doubles, comments. Use for code reviews checking naming and documentation quality.
---

# Go Naming Conventions

## Three Qualities of Good Names

1. **Concise** - High signal-to-noise ratio, not necessarily shortest
2. **Descriptive** - Describes application/result/purpose, not contents/implementation
3. **Predictable** - Infer usage from name alone, follow idiom

## Context is Key

Name length should reflect **distance from declaration to use**:

| Scope | Appropriate Names |
|-------|-------------------|
| Loop index | `i`, `j`, `k` |
| Few lines | `d` for `database` |
| Long functions | `database`, `reader` |
| Package level | `userService`, `configLoader` |

```go
// Good - short names for short scope
for i := range items { ... }

// Good - longer name for wider scope, more context needed
func processOrders(orderProcessor *OrderProcessor) { ... }
```

## Don't Let Packages Steal Good Names

Avoid using variable names that match imported package names:

```go
// Bad - now you can't use context package
func Handler(context context.Context) { ... }

// Good - use idiomatic abbreviation
func Handler(ctx context.Context) { ... }

// Bad - shadows url package
url := "https://example.com"

// Good - be more specific
requestURL := "https://example.com"
```

## Be a Team Player

When in doubt, **follow local conventions**. Uniformity matters more than individual preference:

- If the codebase uses `userID`, don't switch to `userId`
- Match existing abbreviation patterns
- Consistency across a codebase trumps your preferred style

## Variable Name Scope Guidelines

| Scope | Lines | Appropriate Names |
|-------|-------|-------------------|
| Small | 1-7 | Single word or letter (`c` for counter) |
| Medium | 8-15 | Short descriptive (`count`, `opts`) |
| Large | 15-25 | More descriptive (`userCount`, `options`) |
| Very Large | 25+ | Full descriptive names, multiple words if needed |

## Naming Rules

| Rule | Good | Bad |
|------|------|-----|
| Length proportional to scope | `i` for loops, `userService` for package-level | `u` for user service |
| No type suffixes | `users` | `usersMap`, `nameString` |
| Single letters for loops only | `for i := range` | `for index := range` |
| `var` for zero-value | `var count int` | `count := 0` |
| `:=` for explicit init | `name := "default"` | `var name = "default"` |
| MixedCaps, not underscores | `userCount` | `user_count` |
| Initialisms: all caps or lowercase | `URL`, `url` | `Url` |
| No Get prefix for getters | `Counts()` | `GetCounts()` |
| Receiver: short, type abbreviation | `func (t Tray)` | `func (tray Tray)` |

## Constant Naming

Constants use MixedCaps like all other names. **Never use ALL_CAPS or K prefix:**

```go
// Good
const MaxPacketSize = 512
const (
    ExecuteBit = 1 << iota
    WriteBit
    ReadBit
)

// Bad
const MAX_PACKET_SIZE = 512
const kMaxBufferSize = 1024
const KMaxUsersPerGroup = 500
```

Name constants based on their **role**, not their values:

```go
// Bad - name describes value, not role
const Twelve = 12

// Good - name describes purpose
const MaxRetries = 12
```

## Initialisms Table

**Standard initialisms** (URL, API, ID, etc.) - all caps or all lowercase:

| English | Scope | Correct | Incorrect |
|---------|-------|---------|-----------|
| XML API | Exported | `XMLAPI` | `XmlApi`, `XMLApi` |
| XML API | Unexported | `xmlAPI` | `xmlapi`, `xmlApi` |
| ID | Exported | `ID` | `Id` |
| ID | Unexported | `id` | `iD` |
| DB | Exported | `DB` | `Db` |
| DB | Unexported | `db` | `dB` |

**Brand/prose initialisms** (preserve standard prose format):

| English | Scope | Correct | Incorrect |
|---------|-------|---------|-----------|
| iOS | Exported | `IOS` | `Ios`, `IoS` |
| iOS | Unexported | `iOS` | `ios` |
| gRPC | Exported | `GRPC` | `Grpc` |
| gRPC | Unexported | `gRPC` | `grpc` |
| DDoS | Exported | `DDoS` | `DDOS`, `Ddos` |
| DDoS | Unexported | `ddos` | `dDoS` |

**Note**: Brand names like `iOS` and `gRPC` preserve their standard prose capitalization when unexported, but use all-caps when exported.

## Function Naming Conventions

| Pattern | Example | Rule |
|---------|---------|------|
| Returns something | `JobName()` | Noun-like name |
| Does something | `WriteDetail()` | Verb-like name |
| Type differs | `ParseInt()`, `ParseInt64()` | Type suffix |
| Primary version | `Marshal()` vs `MarshalText()` | Omit type for primary |
| Latency/blocking | `FetchUser()`, `ComputeStats()` | Use Fetch/Compute prefix |

**Getter naming:**
- Omit `Get` prefix for simple accessors: `Counts()` not `GetCounts()`
- Use `Fetch` for network/IO operations with latency
- Use `Compute` for CPU-intensive calculations

## Avoid Repetition

Don't repeat: package name, receiver type, param names, return types.

```go
// Bad
package yamlconfig
func ParseYAMLConfig(input string) (*Config, error)
func (c *Config) WriteConfigTo(w io.Writer) error
func TransformToJSON(input *Config) *jsonconfig.Config

// Good
func Parse(input string) (*Config, error)
func (c *Config) WriteTo(w io.Writer) error
func Transform(input *Config) *jsonconfig.Config
```

## Common Conventions

| Type | Name |
|------|------|
| `*sql.DB` | `db` |
| `context.Context` | `ctx` |
| `*http.Request` | `req` or `r` |
| `http.ResponseWriter` | `w` |
| `io.Reader` / `io.Writer` | `r` / `w` |
| `*testing.T` | `t` |

## Package Naming

- Name for **service provided**, not contents
- Avoid stutter: `http.Server` not `http.HTTPServer`
- **Anti-patterns**: `utils/`, `common/`, `base/`, `helpers/`, `lib/`, `shared/`
- **Lowercase only** - no underscores or mixed caps
- Multi-word packages stay unbroken: `tabwriter` not `tab_writer`
- **Numbers allowed** in established contexts: `k8s`, `oauth2`, `utf8`

Fix util packages:
- Move functions into caller's package
- Split into multiple focused packages
- Use plurals: `strings`, `bytes`, `errors`

**Underscores in package names** - only allowed in:
- `_test` suffix for black box tests: `linkedlist_test`
- Generated code packages
- Low-level OS interop code

## Import Renaming

Rename imports **only** when:
- Name collision with other imports
- Generated proto packages (must have `pb` suffix): `foosvcpb "path/to/foo_service_go_proto"`
- Uninformative name like `v1`: `core "github.com/kubernetes/api/core/v1"`

```go
// Good - proto with pb suffix, remove underscores
import (
    foosvcpb "path/to/foo_service_go_proto"
)

// Good - collision avoidance
import (
    urlpkg "net/url"  // When you need 'url' as a variable
)

// Bad - unnecessary rename
import (
    f "fmt"  // Don't shorten without reason
)
```

Keep renamed imports **consistent** across files in the same package.

## Import Grouping

Order imports in these groups, separated by blank lines:

```go
import (
    "fmt"                              // 1. Standard library
    "os"

    "github.com/org/repo"              // 2. Third-party packages
    "golang.org/x/text/encoding"

    foopb "myproj/foo/proto/proto"     // 3. Protocol buffers (pb suffix)

    _ "myproj/rpc/protocols/dial"      // 4. Side-effect imports (main/tests only)
)
```

## Test Double Packages

Append `test` to package name: `creditcard` → `creditcardtest`

```go
// Simple case - one type to stub
type Stub struct{}
func (Stub) Charge(*creditcard.Card, money.Money) error { return nil }

// Multiple behaviors
type AlwaysCharges struct{}
type AlwaysDeclines struct{}

// Multiple types
type StubService struct{}
type StubStoredValue struct{}
```

Prefix test double variables for clarity:
```go
// Good - clear it's a test double
var spyCC creditcardtest.Spy
proc := &Processor{CC: spyCC}

// Bad - unclear
var cc creditcardtest.Spy
```

## Shadowing vs Stomping

```go
// Stomping (OK) - reusing variable, original not needed
err := step1()
if err != nil { return err }
err = step2()  // = not :=

// Shadowing (Bug-prone) - new variable in nested scope
deadline := defaultDeadline
if urgent {
    deadline := time.Now().Add(time.Second)  // BUG: shadows outer
}
// outer deadline unchanged!
```

Use `=` not `:=` when updating existing variables in conditional blocks.

**Don't shadow standard packages:**
```go
// Bad - can't use net/url anymore
func LongFunction() {
    url := "https://example.com/"
}
```

## Signal Boosting

When code looks common but isn't, add a comment to boost the signal:

```go
// Hard to distinguish at a glance
if err != nil { ... }  // Common
if err == nil { ... }  // Unusual!

// Good - signal boost the unusual case
if err := doSomething(); err == nil { // if NO error
    // ...
}
```

Draw attention to inverted conditionals or other non-obvious patterns.

## Comments

### Three Purposes of Comments

1. **What** - Explain what the code does (for complex algorithms)
2. **How** - Describe the implementation approach (rarely needed if code is clear)
3. **Why** - Explain rationale, constraints, or design decisions (most valuable)

**Focus on WHY** - the code already shows what and how.

### Comment Guidelines

```go
// Good - explains why
// Use insertion sort for small slices as it has better cache locality
// and lower overhead than quicksort for n < 12.
if len(items) < 12 {
    insertionSort(items)
}

// Bad - just restates the code
// If length is less than 12, use insertion sort
if len(items) < 12 {
    insertionSort(items)
}
```

### Public Symbol Documentation

- All exported symbols should have doc comments
- Doc comments start with the symbol name
- Describe behavior, not implementation

```go
// Package http provides HTTP client and server implementations.
package http

// Server serves HTTP requests on the given address.
type Server struct { ... }

// ListenAndServe listens on the TCP network address addr and then
// handles requests on incoming connections.
func (srv *Server) ListenAndServe() error { ... }
```

### Don't Comment Bad Code

If you find yourself writing a comment to explain confusing code, **rewrite the code instead**. Comments become lies over time as code evolves.

### Documenting Cleanup Requirements

Document explicit cleanup requirements:

```go
// Good - tells caller what to do
// NewTicker returns a new Ticker.
// Call Stop to release the Ticker's associated resources when done.
func NewTicker(d Duration) *Ticker

// Good - explains how to clean up
// Get issues a GET to the specified URL.
// When err is nil, resp always contains a non-nil resp.Body.
// Caller should close resp.Body when done reading from it.
func (c *Client) Get(url string) (resp *Response, err error)
```

### Documenting Concurrency

Document concurrency behavior when non-obvious:

```go
// Good - states thread safety for mutating operation
// Grow grows the buffer's capacity.
// It is not safe to be called concurrently by multiple goroutines.
func (*Buffer) Grow(n int)

// Good - states sync is provided
// NewFortuneTellerClient returns an *rpc.Client for the FortuneTeller service.
// It is safe for simultaneous use by multiple goroutines.
func NewFortuneTellerClient(cc *rpc.ClientConn) *FortuneTellerClient
```

**Note**: Read-only operations are assumed safe for concurrent use. Mutating operations require documentation.

### Comment Line Length

Aim for ~80 characters but no hard limit. Break based on readability:

```go
// Good - readable on narrow screens
// This is a comment paragraph.
// The length of individual lines doesn't matter in Godoc;
// but the choice of wrapping makes it easy to read on narrow screens.
//
// Don't worry too much about long URLs:
// https://supercalifragilisticexpialidocious.example.com/path/to/resource
```

Avoid jagged line breaks that wrap poorly on narrow screens.
