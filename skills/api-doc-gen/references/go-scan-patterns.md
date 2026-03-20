# Go Framework Scan Patterns

How to discover routes and extract endpoint details from Go web frameworks. Start by detecting which framework is used — check `go.mod` for the import path.

## Framework Detection

| Import in go.mod | Framework |
|------------------|-----------|
| `github.com/gofiber/fiber` | Fiber |
| `github.com/labstack/echo` | Echo |
| `github.com/go-chi/chi` | Chi |
| `github.com/gin-gonic/gin` | Gin |

## Route Registration Patterns

### Fiber

```go
// Direct registration
app.Get("/api/v1/users", handler.ListUsers)
app.Post("/api/v1/users", handler.CreateUser)
app.Get("/api/v1/users/:id", handler.GetUser)

// Group registration
api := app.Group("/api/v1")
users := api.Group("/users")
users.Get("/", handler.ListUsers)
users.Post("/", handler.CreateUser)
users.Get("/:id", handler.GetUser)
```

**Search patterns:**
```
app.Get(    app.Post(    app.Put(    app.Patch(    app.Delete(
.Group(
```

**Handler signature:** `func(c *fiber.Ctx) error`

**Parameter extraction:**
- Path params: `c.Params("id")`
- Query params: `c.Query("page")`, `c.QueryInt("limit")`
- Body parsing: `c.BodyParser(&req)`

### Echo

```go
// Direct registration
e.GET("/api/v1/users", handler.ListUsers)
e.POST("/api/v1/users", handler.CreateUser)
e.GET("/api/v1/users/:id", handler.GetUser)

// Group registration
api := e.Group("/api/v1")
users := api.Group("/users")
users.GET("/", handler.ListUsers)
```

**Search patterns:**
```
e.GET(    e.POST(    e.PUT(    e.PATCH(    e.DELETE(
.Group(
```

**Handler signature:** `func(c echo.Context) error`

**Parameter extraction:**
- Path params: `c.Param("id")`
- Query params: `c.QueryParam("page")`
- Body parsing: `c.Bind(&req)`

### Chi

```go
// Direct registration
r.Get("/api/v1/users", handler.ListUsers)
r.Post("/api/v1/users", handler.CreateUser)
r.Get("/api/v1/users/{id}", handler.GetUser)

// Group registration
r.Route("/api/v1", func(r chi.Router) {
    r.Route("/users", func(r chi.Router) {
        r.Get("/", handler.ListUsers)
        r.Post("/", handler.CreateUser)
        r.Get("/{id}", handler.GetUser)
    })
})
```

**Search patterns:**
```
r.Get(    r.Post(    r.Put(    r.Patch(    r.Delete(
r.Route(
```

**Handler signature:** `func(w http.ResponseWriter, r *http.Request)`

**Parameter extraction:**
- Path params: `chi.URLParam(r, "id")`
- Query params: `r.URL.Query().Get("page")`
- Body parsing: `json.NewDecoder(r.Body).Decode(&req)`

### Gin

```go
// Direct registration
r.GET("/api/v1/users", handler.ListUsers)
r.POST("/api/v1/users", handler.CreateUser)
r.GET("/api/v1/users/:id", handler.GetUser)

// Group registration
api := r.Group("/api/v1")
users := api.Group("/users")
users.GET("/", handler.ListUsers)
```

**Search patterns:**
```
r.GET(    r.POST(    r.PUT(    r.PATCH(    r.DELETE(
.Group(
```

**Handler signature:** `func(c *gin.Context)`

**Parameter extraction:**
- Path params: `c.Param("id")`
- Query params: `c.Query("page")`, `c.DefaultQuery("page", "1")`
- Body parsing: `c.ShouldBindJSON(&req)`

## Extracting Request/Response Structs

After finding a handler, trace the request and response types:

### Request Structs

Look for structs with JSON tags used in body parsing:

```go
type CreateUserRequest struct {
    Name     string `json:"name" validate:"required"`
    Email    string `json:"email" validate:"required,email"`
    Age      int    `json:"age,omitempty" validate:"min=0,max=150"`
}
```

**Tag interpretation:**
- `json:"name"` → field name in JSON
- `json:",omitempty"` → optional field
- `validate:"required"` → mandatory (M)
- `validate:"min=X,max=Y"` → range constraint (note in Remark)
- `validate:"oneof=a b c"` → enum values (note in Remark)

**Where to find:** Same package as handler, typically `request.go` or `dto.go`

### Response Structs

```go
type UserResponse struct {
    ID        string    `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email"`
    CreatedAt time.Time `json:"created_at"`
}
```

**Where to find:** Same package as handler, typically `response.go` or inline in handler

### Error Mapping

Look for error-to-status-code mapping in handlers:

```go
// Typed error checks (preferred pattern)
switch {
case errors.Is(err, domain.ErrNotFound):
    return c.Status(fiber.StatusNotFound).JSON(...)
case errors.Is(err, domain.ErrDuplicate):
    return c.Status(fiber.StatusConflict).JSON(...)
default:
    return c.Status(fiber.StatusInternalServerError).JSON(...)
}
```

Extract each case as an error response entry in the doc.

## Scan Strategy

1. **Find go.mod** → detect framework
2. **Find router file** → `Grep` for route registration patterns
3. **Resolve handler functions** → follow the function reference to its definition
4. **Find request/response structs** → `Grep` for struct types used in handlers
5. **Find error mapping** → look for status code assignments in handler error paths
6. **Find domain entities** → if response wraps an entity, trace to `entity.go`
7. **Scan handler directory** → determine endpoint grouping (see below)

## Handler Directory Scanning

After detecting routes, scan the handler directory to determine endpoint grouping for multi-file output.

### Finding the Handler Base Directory

Common locations (search in order):
1. `internal/delivery/http/handler/`
2. `internal/handler/`
3. `internal/<domain>/handler/`
4. `handler/`

Use `Glob` with `**/handler/` to find it. Pick the one that contains subdirectories with `.go` files.

### Mapping Directory to Groups

Each subdirectory under the handler base = one group:

```
handler/
├── consent/           → group "consent"
│   ├── handler.go     → skip (constructor/setup)
│   ├── request.go     → skip (shared structs)
│   ├── response.go    → skip (shared structs)
│   ├── accept.go      → endpoint file
│   └── get.go         → endpoint file
├── channel/           → group "channel"
│   ├── handler.go     → skip
│   └── create.go      → endpoint file
└── health/            → group "health"
    ├── handler.go     → skip
    └── health.go      → endpoint file
```

### Excluded Files

Skip these — they are not endpoint handlers:
- `handler.go` — constructor, `NewHandler()`, route registration
- `request.go`, `response.go`, `dto.go` — shared struct definitions
- `*_test.go` — test files
- `middleware.go` — middleware definitions

### Function Name to Filename

Convert the handler's exported receiver method name from PascalCase to kebab-case:

| Function Name | File Name |
|---------------|-----------|
| `AcceptConsent` | `accept-consent.md` |
| `GetConsentHistory` | `get-consent-history.md` |
| `CreateChannel` | `create-channel.md` |
| `GetAllChannels` | `get-all-channels.md` |

To find the function name, look for the exported receiver method in each Go file:
```go
func (h *ConsentHandler) AcceptConsent(c *gin.Context) { ... }
//                        ^^^^^^^^^^^^^^ this is the function name
```

### Single-File Handler Edge Case

If a group directory contains only `handler.go` (no separate action files), extract all exported receiver methods from `handler.go` itself — each method becomes a separate endpoint doc file.

### Flat Structure Fallback

If the handler directory has no subdirectories (all `.go` files at the top level), group by the first path segment after the API version prefix:
- `/api/v1/consent/*` routes → group "consent"
- `/api/v1/channel/*` routes → group "channel"
