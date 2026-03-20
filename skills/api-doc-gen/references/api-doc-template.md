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
| `GET` | `/api/v1/consents/:citizen_id` | Get Consents by Citizen | [get-consents-by-citizen](consent/get-consents-by-citizen.md) |
| `GET` | `/api/v1/consents/:id` | Get Consent | [get-consent](consent/get-consent.md) |
| `DELETE` | `/api/v1/consents/:id/revoke` | Revoke Consent | [revoke-consent](consent/revoke-consent.md) |

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
- **Path:** `/api/v1/<resource>/<path-param>`
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
| `created_at` | ISO 8601 timestamp     | String | M         | `"2024-01-01T10:00:00Z"` |                      |
| `updated_at` | ISO 8601 timestamp     | String | M         | `"2024-01-01T10:00:00Z"` |                      |

## Response Example

```json
{
  "id": "uuid-v4",
  "status": "active",
  "created_at": "2024-01-01T10:00:00Z",
  "updated_at": "2024-01-01T10:00:00Z"
}
```

## Business Logic

1. step 1
2. step 2
3. step 3

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
| Timestamps  | Always ISO 8601 format: `"2024-01-01T10:00:00Z"`                                                         |
| UUIDs       | Use `"uuid-v4"` or `"uuid-<noun>"` as example values (e.g., `"uuid-consent-1"`)                          |
| Nested obj  | Use `Array` or `Object` type + `See <Name> Object below` in Remark column, then add a separate sub-table |
| Enum values | List allowed values in Remark (e.g., `"active"`, `"inactive"`, `"revoked"`)                              |
| Null fields | Show `null` in Example when the field can be null                                                        |

---

## Checklist Before Finalizing

- [ ] Every endpoint file is linked from `index.md` endpoints table
- [ ] `index.md` TOC links resolve to existing files (correct relative paths)
- [ ] Every endpoint file has Method, Path, and at least one example
- [ ] All field tables use `M`/`O` for Mandatory column
- [ ] Nested objects each have their own sub-table
- [ ] Error Responses table covers all possible HTTP status codes
- [ ] Breadcrumb navigation uses correct relative paths
- [ ] JSON examples are valid (no trailing commas, correct types)
- [ ] Version number in `index.md` header is up to date
