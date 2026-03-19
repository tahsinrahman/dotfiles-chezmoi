---
name: go-concurrency
description: Go concurrency patterns - goroutines, channels, synchronization. Use for code reviews checking concurrent code.
---

# Go Concurrency Patterns

## Core Rules

1. Keep functions busy OR let callers manage concurrency
2. **Never start a goroutine without knowing how it will stop**
3. Leave concurrency decisions to callers
4. Only use `log.Fatal` in `main` or `init`
5. **Prefer synchronous functions** - caller adds concurrency
6. Make goroutine lifetimes **obvious** to maintainers

## Do the Work Yourself

```go
// Bad - goroutine + busy loop wastes CPU
func main() {
    go func() { http.ListenAndServe(":8080", nil) }()
    for {} // spinning
}

// Bad - select{} treats symptom, not cause
func main() {
    go func() { http.ListenAndServe(":8080", nil) }()
    select {} // blocks forever
}

// Good - just do the work yourself
func main() {
    if err := http.ListenAndServe(":8080", nil); err != nil {
        log.Fatal(err)
    }
}
```

If your goroutine can't progress until it gets a result from another, just do the work yourself.

## Leave Concurrency to the Caller

```go
// Option 1: Slice - blocks, clear errors, memory heavy
func ListDirectory(dir string) ([]string, error)

// Option 2: Channel - async, but problematic
func ListDirectory(dir string) chan string
// Problems: No error signaling, caller MUST read until close

// Option 3: Callback - let caller decide
func ListDirectory(dir string, fn func(string))
```

**Rule**: If your function starts a goroutine, provide a way to stop it.

## Goroutine Lifetimes

**Write code so goroutine lifetimes are obvious.** Goroutines can leak by:
- Blocking on channel sends/receives (GC won't collect them)
- Modifying in-use data after "result isn't needed"
- Running indefinitely, causing unpredictable memory usage

```go
// Good - goroutine lifetime is clear, uses context for cancellation
func (w *Worker) Run(ctx context.Context) error {
    var wg sync.WaitGroup

    for item := range w.q {
        wg.Add(1)
        go func() {
            defer wg.Done()
            process(ctx, item)  // Returns when context cancelled
        }()
    }

    wg.Wait()  // Ensures goroutines don't outlive function
    return nil
}

// Bad - goroutine lifetime unclear, may leak
func (w *Worker) Run() {
    for item := range w.q {
        go process(item)  // When does this stop? What if it blocks?
    }
}
```

## Goroutine Lifecycle Coordination

```go
// Bad - goroutine can die silently
go http.ListenAndServe(":8001", nil)

// Bad - log.Fatal calls os.Exit, skips defers
if err := http.ListenAndServe(...); err != nil {
    log.Fatal(err)
}

// Good - coordinate shutdown
done := make(chan error, 2)
stop := make(chan struct{})
go func() { done <- serve(stop) }()
// When one fails, close(stop) to signal others
```

## Prefer Synchronous Functions

```go
// Good - synchronous, caller adds concurrency if needed
func Fetch(ctx context.Context, url string) (*Response, error)

// Bad - forces async on caller
func Fetch(url string) <-chan *Response
```

- Synchronous functions are easier to test and reason about
- Caller can wrap in goroutine if needed
- Keeps goroutine lifetimes localized within caller

**Many Go programmers overuse goroutines.** Moderation is key.

## Channel Direction

Specify channel direction to prevent errors and convey ownership:

```go
// Good - direction specified
func sum(values <-chan int) int       // receive only
func produce(results chan<- int)      // send only

// Bad - allows accidental misuse
func sum(values chan int) (out int) {
    for v := range values {
        out += v
    }
    close(values)  // BUG: shouldn't close receive channel
}
```

## Errgroup for Concurrent Operations

Use `errgroup` for groups of operations that can all fail or be canceled together:

```go
g, ctx := errgroup.WithContext(ctx)
for _, url := range urls {
    url := url  // capture for goroutine
    g.Go(func() error {
        return fetch(ctx, url)
    })
}
if err := g.Wait(); err != nil {
    // First error stops all operations
}
```

Often only the first error is useful when orchestrating related operations.
