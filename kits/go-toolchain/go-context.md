## Go

`go`, `gofmt` and `gopls` are installed (`/usr/local/go`). Run `go build ./...`
and `go test ./...` before reporting a task complete. Prefer `gopls` for
navigation and refactoring (definitions, references, rename) over text search.
Module downloads go through `proxy.golang.org`; other hosts may be blocked.