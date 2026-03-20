# API Documentation Templates

Templates for multi-file API documentation. The output is a directory structure with an index file and individual endpoint files grouped by domain.

```
docs/api/
├── index.md                      ← Index Template
├── <group>/
│   ├── <endpoint-name>.md        ← Per-Endpoint Template
│   └── ...
└── ...
```

---

## Index Template (`docs/api/index.md`)

Use this template for the index file that serves as the entry point for all API docs.

```markdown
# <Service Name> API Documentation

**Version:** <X.Y>
**Base URL:** `/api/v<N>`

## Overview

<Service name> provides APIs for <domain>. <One sentence about main capabilities>.

---

## Endpoints

### <Group Name> (e.g., Consent)

| Method | Path | Endpoint | File |
|--------|------|----------|------|
| `POST` | `/api/v1/consents` | Accept Consent | [accept-consent](consent/accept-consent.md) |
| `GET` | `/api/v1/consents/{citizen_id}` | Get Consents by Citizen | [get-consents-by-citizen](consent/get-consents-by-citizen.md) |
| `GET` | `/api/v1/consents/{id}` | Get Consent | [get-consent](consent/get-consent.md) |
| `DELETE` | `/api/v1/consents/{id}/revoke` | Revoke Consent | [revoke-consent](consent/revoke-consent.md) |

### <Group Name> (e.g., Channel)

| Method | Path | Endpoint | File |
|--------|------|----------|------|
| `POST` | `/api/v1/channels` | Create Channel | [create-channel](channel/create-channel.md) |
| `GET` | `/api/v1/channels` | Get All Channels | [get-all-channels](channel/get-all-channels.md) |

---

## Common Error Responses

All endpoints may return the following common errors:

| Status | Error Message         | Description                         |
| ------ | --------------------- | ----------------------------------- |
| 400    | invalid request       | Request body or query param invalid |
| 401    | unauthorized          | Missing or invalid authentication   |
| 403    | forbidden             | Insufficient permissions            |
| 404    | not found             | Resource does not exist             |
| 500    | internal server error | Unexpected server-side failure      |
```

---

## Per-Endpoint Template (individual file)

Each file contains exactly ONE endpoint. Do not include document headers or TOC — those live in `index.md`.

**Endpoint display name** (`# <Name>`): PascalCase → space-separated words. `AcceptConsent` → `Accept Consent`. No articles (a/an/the), no extra words — exact PascalCase split only.

**Endpoint description** (line below `# <Name>`): `<Verb> <resource>[ by/for <qualifier>]`. Verb from HTTP method: POST→Create, GET(single)→Retrieve, GET(list)→List, PUT→Update, PATCH→Partially update, DELETE→Delete. No articles. Max 10 words.

````markdown
> [API Documentation](../index.md) > [<Group Name>](./) > <Endpoint Name>

# <Endpoint Name>

<One sentence describing what this endpoint does.>

- **Method:** `GET` | `POST` | `PUT` | `PATCH` | `DELETE`
- **Path:** `/api/v1/<resource>/{path-param}`
- **Auth:** `Bearer token` | `API Key` | `None`

## Path Parameters (if any)

| Field Name | Description | Type   | Mandatory | Example    | Remark |
| ---------- | ----------- | ------ | --------- | ---------- | ------ |
| `id`       | Resource ID | String | M         | `"uuid-1"` |        |

## Query Parameters (if any)

| Field Name | Description           | Type   | Mandatory | Example | Remark        |
| ---------- | --------------------- | ------ | --------- | ------- | ------------- |
| `page`     | Page number (1-based) | Number | O         | `1`     | Default: `1`  |
| `limit`    | Items per page        | Number | O         | `20`    | Default: `20` |

## Request Body (if any)

| Field Name   | Description          | Type    | Mandatory | Example           | Remark                |
| ------------ | -------------------- | ------- | --------- | ----------------- | --------------------- |
| `field_name` | What this field does | String  | M         | `"example_value"` |                       |
| `items`      | List of item objects | Array   | M         |                   | See Item Object below |
| `flag`       | Boolean toggle       | Boolean | O         | `true`            |                       |

**Item Object:**

| Field Name | Description     | Type   | Mandatory | Example   | Remark |
| ---------- | --------------- | ------ | --------- | --------- | ------ |
| `code`     | Item code       | String | M         | `"CODE1"` |        |
| `value`    | Optional detail | String | O         | `"abc"`   |        |

## Request Example

```json
{
  "field_name": "example_value",
  "items": [{ "code": "CODE1" }, { "code": "CODE2", "value": "abc" }],
  "flag": true
}
```

## Response (<HTTP Status> <Status Text>)

| Field Name   | Description            | Type   | Mandatory | Example                  | Remark               |
| ------------ | ---------------------- | ------ | --------- | ------------------------ | -------------------- |
| `id`         | UUID of created record | String | M         | `"uuid-v4"`              |                      |
| `status`     | Current status         | String | M         | `"active"`               | "active", "inactive" |
| `created_at` | ISO 8601 timestamp     | String | M         | `"2024-01-01T10:00:00+07:00"` |                      |
| `updated_at` | ISO 8601 timestamp     | String | M         | `"2024-01-01T10:00:00+07:00"` |                      |

## Response Example

```json
{
  "id": "uuid-v4",
  "status": "active",
  "created_at": "2024-01-01T10:00:00+07:00",
  "updated_at": "2024-01-01T10:00:00+07:00"
}
```

## Business Logic

One step per distinct action in the usecase — read the usecase method and list every action it performs:

1. Validate that referenced Purpose exists and is active
2. Check for existing consent for this Citizen + Purpose combination
3. Create new Consent record with status `active`
4. Create audit log entry for consent creation
5. Send notification to data subject via notification service

## Error Responses

| Status | Error Message         | Description                    |
| ------ | --------------------- | ------------------------------ |
| 400    | invalid request       | Request body validation failed |
| 404    | record not found      | Resource does not exist        |
| 422    | <specific message>    | Business rule violation        |
| 500    | internal server error | Server-side failure            |
````

---

## Field Table Conventions

| Convention  | Meaning                                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------------------- |
| Mandatory   | Use `M` for required fields, `O` for optional                                                            |
| Type values | `String`, `Number`, `Boolean`, `Array`, `Object`                                                         |
| Timestamps  | Always ISO 8601 with Asia/Bangkok timezone (+07:00): `"2024-01-01T10:00:00+07:00"`                                                         |
| UUIDs       | Use `"uuid-v4"` or `"uuid-<noun>"` as example values (e.g., `"uuid-consent-1"`)                          |
| Nested obj  | Use `Array` or `Object` type + `See <GoTypeName> Object below` in Remark column, then add a separate sub-table |
| Enum values | List allowed values in Remark (e.g., `"active"`, `"inactive"`, `"revoked"`)                              |
| Null fields | Show `null` in Example when the field can be null                                                        |

### Row Ordering (mandatory)

Follow Go struct field order (top to bottom):
1. Embedded struct fields first — expanded in their declaration order
2. Then the struct's own fields in declaration order
3. Sub-tables appear immediately after the parent table that references them

### Example Value Conventions

| Type | Convention | Example Value |
|------|-----------|---------------|
| UUID | Fixed placeholder | `"uuid-v4"` |
| String (enum) | First enum value from const block | `"active"` |
| String (name/label) | Kebab-case from field context | `"consent-name"` |
| String (other) | Short realistic value from field name | `"example-value"` |
| Number (integer, no default) | Smallest typical positive value | `1` |
| Number (with known default) | Use the default value | `20` |
| Boolean | Always `true` | `true` |
| Timestamp | Fixed template timestamp | `"2024-01-01T10:00:00+07:00"` |
| Array (in example JSON) | Exactly 1 item | `[{...}]` |
| Null/optional | `null` when field is primarily "absent" | `null` |

### Remark Column Rules

| Condition | Remark content | Example |
|-----------|---------------|---------|
| Enum type | List all values in quotes | `"active"`, `"revoked"`, `"expired"` |
| Has default value | `Default: <value>` | `Default: 1` |
| `validate` tag with range | `Min: X, Max: Y` | `Min: 1, Max: 100` |
| `validate` tag with max length | `Max length: N` | `Max length: 255` |
| Nested object/array | `See <GoTypeName> Object below` | `See ConsentItem Object below` |
| No special condition | Leave empty | |

### Sub-table Naming

Use Go type name as-is + " Object:" suffix in bold:
- `[]ConsentItem` → `**ConsentItem Object:**`
- `ResponseData` → `**ResponseData Object:**`
- Never abbreviate or rename the Go type

### Field Description Patterns

| Field pattern | Description formula | Example |
|--------------|-------------------|---------|
| `id` (PK) | `Unique identifier of the <entity>` | `Unique identifier of the consent` |
| `*_id` (FK) | `Reference to <entity>` | `Reference to purpose` |
| `*_at` (timestamp) | `Timestamp when <past-tense-action>` | `Timestamp when created` |
| `status` | `Current status` | `Current status` |
| `name` | `Name of the <entity>` | `Name of the channel` |
| Boolean | `Whether <condition>` | `Whether consent is active` |
| Other | Noun phrase from field name, max 8 words | `Total number of records` |

---

## Verification Checklist

This is the **single source of truth** for all verification checks — used by Step 4 (verify after Generate/Update) and Validate Mode. Do not duplicate these checks elsewhere; reference this checklist instead.

### Coverage & Structure
- [ ] Every route in code has a corresponding `.md` file, and vice versa (no missing or orphan files)
- [ ] Every endpoint file is listed in `index.md` endpoints table, and every index entry points to an existing file
- [ ] Handler directory structure matches `docs/api/` directory structure (group consistency)
- [ ] Every endpoint file has Method, Path, and at least one example
- [ ] Breadcrumb navigation uses correct relative paths
- [ ] JSON examples are valid (no trailing commas, correct types)
- [ ] Version number in `index.md` header is up to date

### Field Completeness (critical — open struct source files to verify)
- [ ] All field tables use `M`/`O` for Mandatory column
- [ ] Request body field count matches serializable fields in struct (exclude `json:"-"` and unexported) — no field skipped
- [ ] Response field count matches serializable fields in struct (exclude `json:"-"` and unexported) — no field skipped
- [ ] Embedded/composed struct fields are expanded into the parent table (e.g., `BaseResponse` fields included)
- [ ] Custom types resolved to underlying type with enum values listed in Remark
- [ ] Pointer fields (`*Type`) and `omitempty` fields marked as `O` with `null` in Example where appropriate
- [ ] Nested objects (`[]Struct`, `Struct`) each have their own sub-table, named `**<GoTypeName> Object:**`
- [ ] Response wrapper documented correctly if handler wraps response in envelope (e.g., `{success, data, message}`)
- [ ] Query params from inline `c.Query()` handler calls included (not just struct-based)
- [ ] Inline query params: `O` by default, `M` only if handler explicitly returns error when param is empty
- [ ] Row ordering follows Go struct field order — embedded fields first, then own fields
- [ ] Field descriptions follow formula: ID→"Unique identifier of...", FK→"Reference to...", timestamp→"Timestamp when...", etc.
- [ ] Example values follow conventions: UUID→`"uuid-v4"`, enum→first value, timestamp→`"2024-01-01T10:00:00+07:00"`, boolean→`true`
- [ ] Remark column: enum values listed, defaults noted, constraints noted, empty when no special condition
- [ ] JSON examples include all mandatory fields and at least one optional field
- [ ] JSON examples reflect actual response shape (including wrapper if present)

### Business Logic Completeness (critical — open ALL usecase methods to verify)
- [ ] **Source check:** determine whether steps came from header comments (Priority 1) or code-derived counting rules (Priority 2)
- [ ] If Priority 1 (header comments): steps in doc match the comment list verbatim — no steps added, removed, or reworded
- [ ] If Priority 2 (code-derived): repo/service/external call = 1 step, sentinel-returning `if`/`switch` = 1 step, state-changing side effect = 1 step
- [ ] NOT counted: error propagation (`if err != nil`), stdlib calls, struct construction, logging, metrics, context enrichment, final `return`
- [ ] Step count matches the source (comment list count OR code-derived action count)
- [ ] Step wording: imperative verb + object, derived from method name or inline comment
- [ ] Conditional branches are documented (e.g., "If X, do Y")
- [ ] Side effects included (audit log, cache invalidate, event publish) — but NOT logging/metrics

### Response Metadata (critical)
- [ ] Success status code matches handler's actual return (200/201/204 etc.), not guessed
- [ ] Auth type matches middleware applied to the route

### Error Response Completeness (critical — open ALL usecase methods to verify)
- [ ] ALL usecase methods the handler calls have been read — not just one
- [ ] Every sentinel error return across all usecase methods has a matching row in the Error Responses table
- [ ] Each sentinel error (`ErrXxx`) = exactly 1 row, even if multiple sentinels share the same HTTP status code — never consolidate
- [ ] Wrapped `fmt.Errorf` errors from usecase → NOT traced into repo — covered by single catch-all 500 row
- [ ] Same sentinel from multiple usecase methods → deduplicated to 1 row (dedup by error variable name + status code)
- [ ] Handler-level errors exhaustively checked: bind/parse (400), validation (422), param parse (400) — all present if handler has the pattern
- [ ] Default/catch-all error case (500) included as the last row
- [ ] Error messages match the actual strings from `errors.New("...")` in the code, not generic placeholders
- [ ] Row ordering: handler errors (ascending status) → usecase sentinels (handler switch order) → catch-all 500

### Text Consistency
- [ ] Endpoint display name: exact PascalCase split, no articles (`AcceptConsent` → `Accept Consent`)
- [ ] Endpoint description: `<Verb> <resource>[ by/for <qualifier>]`, verb from HTTP method, no articles, max 10 words
- [ ] Index overview: max 2 sentences, follows `<Service> provides APIs for <domain>.` pattern
