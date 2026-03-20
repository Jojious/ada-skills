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

<One paragraph describing what this service does and its primary purpose.>

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

1. Validate that the referenced Purpose exists and is active
2. Check if a consent already exists for this Citizen + Purpose combination
3. Create a new Consent record with status `active`
4. Create an audit log entry for the consent creation
5. Send notification to the data subject via notification service
6. Return the created consent

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
| Nested obj  | Use `Array` or `Object` type + `See <Name> Object below` in Remark column, then add a separate sub-table |
| Enum values | List allowed values in Remark (e.g., `"active"`, `"inactive"`, `"revoked"`)                              |
| Null fields | Show `null` in Example when the field can be null                                                        |

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
- [ ] Nested objects (`[]Struct`, `Struct`) each have their own sub-table
- [ ] Response wrapper documented correctly if handler wraps response in envelope (e.g., `{success, data, message}`)
- [ ] Query params from inline `c.Query()` handler calls included (not just struct-based)
- [ ] JSON examples include all mandatory fields and at least one optional field
- [ ] JSON examples reflect actual response shape (including wrapper if present)

### Business Logic Completeness (critical — open ALL usecase methods to verify)
- [ ] **Source check:** determine whether steps came from header comments (Priority 1) or code-derived counting rules (Priority 2)
- [ ] If Priority 1 (header comments): steps in doc match the comment list verbatim — no steps added, removed, or reworded
- [ ] If Priority 2 (code-derived): each repo/service/external call = 1 step, each business-rule `if`/`switch` = 1 step, each side effect = 1 step, final `return` is NOT a step
- [ ] Step count matches the source (comment list count OR code-derived action count)
- [ ] Conditional branches are documented (e.g., "If X, do Y")
- [ ] Side effects included (notifications, events, cache, audit logs)

### Response Metadata (critical)
- [ ] Success status code matches handler's actual return (200/201/204 etc.), not guessed
- [ ] Auth type matches middleware applied to the route

### Error Response Completeness (critical — open ALL usecase methods to verify)
- [ ] ALL usecase methods the handler calls have been read — not just one
- [ ] Every error return across all usecase methods has a matching row in the Error Responses table
- [ ] Each sentinel error has a matching row with the correct HTTP status
- [ ] Bind/parse errors included (400)
- [ ] Validation errors included (400/422)
- [ ] Default/catch-all error case included (500)
- [ ] Error messages match the actual strings in the code, not generic placeholders
