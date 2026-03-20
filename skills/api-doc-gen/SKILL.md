---
name: api-doc-gen
description: >
  Generate and validate API documentation from source code. Scans handler/router
  files to produce structured Markdown API docs in docs/api/ — one file per endpoint,
  grouped by handler domain. Or validates existing docs against the current codebase.
  Use this skill whenever the user wants to generate API docs, update API documentation,
  check if API docs are out of date, create endpoint documentation from code, or says
  things like "gen api doc", "สร้าง api doc", "อัปเดต api doc",
  "เช็ค api doc ตรงกับ code ไหม", "document these endpoints", "api doc outdated".
  Also trigger when neo-team delegates API documentation tasks to this skill.
compatibility:
  environment: claude-code
  tools:
    - Read
    - Glob
    - Grep
    - Bash
    - Edit
    - Write
---

# API Doc Generator

Generate or validate API documentation by scanning source code. Currently optimized for Go (with Fiber, Echo, Chi, Gin support). The output is a multi-file directory structure — one Markdown file per endpoint, grouped by handler domain — so each API is easy to find, review, and maintain independently.

## Output Structure

```
docs/api/
├── index.md              ← service header, overview, endpoints table, common errors
├── <group>/
│   ├── <endpoint>.md     ← one endpoint per file
│   └── ...
└── ...
```

- **Grouping:** each subdirectory under the handler base directory = one group
- **File naming:** handler function name converted to kebab-case (e.g., `AcceptConsent` → `accept-consent.md`)
- **Index:** `docs/api/index.md` links to every endpoint file

## Modes

| Mode | When to use | What it does |
|------|-------------|--------------|
| **Generate** | No `docs/api/` directory exists, or user wants to regenerate from scratch | Scan code → create `docs/api/` with `index.md` + group folders + per-endpoint files |
| **Update** | `docs/api/index.md` exists, code has changed | Scan code → diff against existing files → add/update/remove individual endpoint files + regenerate `index.md` |
| **Validate** | User wants to check consistency | Compare all files in `docs/api/` vs code → report per-file discrepancies without modifying |

Detect the mode automatically:
1. If `docs/api/index.md` doesn't exist → **Generate**
2. If user says "validate", "check", "เช็ค" → **Validate**
3. Otherwise → **Update**

If a legacy `docs/api-doc.md` exists but no `docs/api/` directory, treat as **Generate** (migration from old single-file format).

The user can override by specifying the mode explicitly.

## Workflow

### Step 0: Read Project Context

Read `CLAUDE.md` (or `AGENTS.md`, `CONTRIBUTING.md`) to understand:
- Project name and purpose (for the doc header)
- Framework used (Fiber, Echo, Chi, Gin)
- Project structure conventions
- API versioning pattern (e.g., `/api/v1/`)

If no convention file exists, infer from the code structure.

### Step 1: Discover Routes

Scan the codebase for route registration patterns. Read [`references/go-scan-patterns.md`](references/go-scan-patterns.md) for framework-specific patterns.

**What to find:**
- All registered routes (method + path)
- The handler function each route maps to
- Route groups and prefixes
- Middleware applied (auth, validation)

**Where to look (in order):**
1. Router setup file — often `cmd/api/main.go`, `internal/router.go`, or `routes.go`
2. Route group files — `internal/<domain>/routes.go`
3. Handler files — `internal/<domain>/handler/*.go`

### Step 1b: Discover Handler Groups

After finding routes, scan the handler directory structure to determine grouping. Read [`references/go-scan-patterns.md`](references/go-scan-patterns.md) § Handler Directory Scanning for detailed patterns.

1. **Locate handler base directory** — typically `internal/delivery/http/handler/` or `internal/handler/`
2. **List subdirectories** — each subdirectory = one group (e.g., `handler/consent/` → group "consent")
3. **Map handler files to endpoints** — each Go file (excluding `handler.go`, `request.go`, `response.go`, `dto.go`, `*_test.go`) maps to one endpoint doc file
4. **Extract function name** — find the exported receiver method in each file, convert PascalCase to kebab-case for the filename
5. **Build group map** — `{ group: "consent", endpoints: [{ function: "AcceptConsent", file: "accept-consent.md", method: "POST", path: "/api/v1/consents" }, ...] }`

If the handler directory has no subdirectories (flat structure), fall back to grouping by route prefix.

### Step 2: Extract Endpoint Details

For each discovered route, trace from handler → usecase → repository to extract:

1. **Request shape** — handler's request struct (path params, query params, request body)
2. **Response shape** — handler's response struct (success and error cases)
3. **Business rules** — validation in usecase layer, error conditions
4. **Error responses** — mapped HTTP status codes from error handling

Track which group each endpoint belongs to — this determines its file placement in Step 3.

**Where to find these:**
- Request/Response structs: `handler/request.go`, `handler/response.go`, or inline in handler files
- Domain entities: `entity.go` in the domain package
- Error mapping: handler's error-to-status-code logic
- Validation rules: request struct tags (`validate:"required"`, `binding:"required"`), usecase validation

### Step 3: Generate, Update, or Validate

Read [`references/api-doc-template.md`](references/api-doc-template.md) for the exact output format (Index Template + Per-Endpoint Template).

#### Generate Mode

Create the `docs/api/` directory structure:

1. **Create `docs/api/index.md`** using the Index Template:
   - Service name, version, base URL
   - Overview paragraph
   - Endpoints table per group — each row links to the per-endpoint file
   - Common error responses section

2. **Create group directories** — `docs/api/<group>/` for each handler group

3. **Create per-endpoint files** — `docs/api/<group>/<endpoint-name>.md` using the Per-Endpoint Template:
   - Breadcrumb navigation back to index
   - One endpoint only: method, path, auth, params, request/response, business logic, errors
   - Use `H1` for the endpoint name (it's the top-level heading in its own file)
   - Use `H2` for sub-sections (Path Parameters, Request Body, etc.)

#### Update Mode

1. Read existing `docs/api/index.md` and all group directories
2. Build a map of existing documented endpoints (file path → endpoint)
3. Scan code to get current endpoints (same as Generate)
4. Diff and apply changes:
   - **New endpoints** → create new `.md` file in the appropriate group directory
   - **Removed endpoints** → delete the orphaned `.md` file; if group directory is empty, remove it
   - **Changed endpoints** → update only the changed file
   - **Group changes** → if a handler moved to a different group directory, move the doc file
5. Regenerate `docs/api/index.md` to reflect current state
6. Preserve any manually-added notes in endpoint files that aren't auto-generated

#### Validate Mode

Compare all files in `docs/api/` against discovered routes and produce a report:

```
## API Doc Validation Report

**Status:** [In Sync / Out of Sync]
**Checked:** [timestamp]
**Structure:** docs/api/ with [N] groups, [M] endpoint files

### Missing Files (endpoints in code but no doc file)
- POST /api/v1/consents → expected at docs/api/consent/accept-consent.md
  handler: AcceptConsent (internal/delivery/http/handler/consent/accept_consent.go:12)

### Orphan Files (doc files with no matching endpoint in code)
- docs/api/consent/delete-consent.md → no matching route found

### Field Mismatches (per file)
- docs/api/consent/get-consent.md
  - Response field `revoked_at` exists in code but not in doc
  - Doc shows `status` as String, code uses custom type `ConsentStatus`

### Index Integrity
- TOC link to `consent/revoke-consent.md` → file exists: ✅/❌
- Group "purpose" listed in index but directory is empty

### Summary
| Category | Count |
|----------|-------|
| Groups in code | X |
| Groups in docs | Y |
| Endpoints in code | X |
| Endpoint files in docs | Y |
| Missing files | Z |
| Orphan files | W |
| Field mismatches | N |
| Broken index links | P |
```

### Step 4: Verify (mandatory after every Generate/Update)

Every time you create or modify files in `docs/api/`, run a full verification pass before reporting completion. This catches drift between the docs you just wrote and the actual code. Skipping this step means silent errors ship.

**4a. Format checks** — run across ALL files in `docs/api/`:
1. `index.md` endpoint table links resolve to actual files
2. All field tables use `M`/`O` for Mandatory column
3. JSON examples are valid (no trailing commas, correct types)
4. Breadcrumb navigation in each endpoint file uses correct relative paths

**4b. Re-scan and cross-check (the critical part):**

Re-read all files in `docs/api/`, then re-scan the codebase routes (same as Step 1) and compare:

1. **File coverage** — every route in code has a corresponding `.md` file, and vice versa
2. **Index integrity** — every endpoint file is listed in `index.md`, and every index entry points to an existing file
3. **Field accuracy** — for each endpoint, compare request/response structs in code vs what the doc describes. Flag missing fields, wrong types, or wrong mandatory/optional markers
4. **Group consistency** — handler directory structure matches `docs/api/` directory structure
5. **Status code accuracy** — verify documented error codes match the handler's actual error-to-status mapping

**4c. Fix or report:**

- If mismatches are found → fix the doc immediately, then re-run 4b to confirm the fix
- If all checks pass → proceed to output
- Maximum 2 fix-and-recheck cycles. If issues persist after 2 rounds, report the remaining discrepancies in the output as warnings

## Expanding to Other Languages

This skill currently focuses on Go. The scanning logic is in `references/go-scan-patterns.md`. To add a new language:
1. Create `references/<language>-scan-patterns.md` with framework-specific route/handler patterns
2. Update Step 0 to detect the language from project files (`go.mod` → Go, `package.json` → Node.js, etc.)
3. The template and output format remain the same regardless of language

## Output

After completion, report:

```
## API Doc Generator

**Mode:** [Generate / Update / Validate]
**Output:** docs/api/ ([N] groups, [M] endpoint files)
**Structure:**
  - docs/api/index.md
  - docs/api/consent/ (5 files)
  - docs/api/channel/ (6 files)
  - docs/api/purpose/ (12 files)

**Changes:**
- Created: consent/accept-consent.md, consent/get-consent.md, ...
- Updated: channel/create-channel.md (added new query param)
- Removed: legacy/old-endpoint.md (route removed from code)

**Verification:** [✅ Passed — docs match code / ⚠️ Passed with warnings / ❌ Issues remain]
- File coverage: X endpoints in code, Y files in docs — Match: ✅/❌
- Index integrity: all links resolve — ✅/❌
- Field accuracy: [X/Y endpoint files fully match]
- Fix cycles used: [0/1/2]

**Warnings:** [any issues found — missing structs, unresolvable types, remaining discrepancies, etc.]
```
