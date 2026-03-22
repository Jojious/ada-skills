---
name: explain-step
description: Read a function or code block and produce a deterministic, numbered step-by-step explanation of its business-level flow. Every generation for the same unchanged code must yield the same steps in the same order. Use this skill whenever the user asks to explain code steps, break down a function into steps, trace a function's logic, understand what a function does step by step, or says things like "explain this function", "อธิบาย step", "แตก step", "show me the steps", "walk me through this code", "break down this function", "what does this function do step by step". Also trigger when the user pastes code and asks for a logical breakdown or flow explanation.
metadata:
  version: "3.0"
---

# Explain Step

Read a function or code block and produce a **deterministic** numbered step-by-step explanation of its **business-level** flow, with sub-steps that explain **how** each step works internally.

The core guarantee: **given the same unchanged code, every run must produce the same steps, in the same order, covering the same content.**

## Two Levels of Explanation

Every output has two layers:
- **Top-level steps**: What the function does — one step per business concern/entity (grouped by domain concept)
- **Sub-steps (N.1, N.2, ...)**: How the step works internally — the distinct operations inside that step

This gives the reader both the big picture and the mechanics without being code-level verbose.

## Step Derivation Algorithm

Follow this algorithm exactly.

### 1. Identify the function boundary

Read the full function body. If the user provides a file path + function name, locate it first. If they paste code directly, use that.

### 2. Identify entities and domain concepts

Scan the code and list every distinct entity or domain concept the function works with. Entities are identified by:
- Repository/service calls (e.g., `userRepo.GetByID` → entity is "user")
- Type names in assignments (e.g., `entity.NewConsent(...)` → entity is "consent")
- Named variables that represent domain objects (e.g., `dataSubject`, `collectionPoint`)

### 3. Group statements into top-level steps

Walk the function body **top to bottom**. Group consecutive statements into one top-level step when they all serve the same business concern. Start a new step when the code shifts to a **different entity or concern**.

Grouping patterns:

| Pattern | How to group |
|---|---|
| **Input validation** | All guard clauses at the top that validate input before any external call |
| **Entity fetch + validation** | A fetch/query call + nil check + related validation on the same entity |
| **Error check after a call** | Fold into the parent step, not a separate step |
| **Create or update with branching** | An if/else that creates or updates the same entity |
| **Transaction / batch persist** | A transaction block that persists entities |
| **Result building + return** | Assembling the output + returning it |

### 4. Break each step into sub-steps

For every top-level step, list the distinct operations inside it as sub-steps. A "distinct operation" = a different business action (fetch, validate, create, update, check, transform, etc.).

**Rules:**
- Every step that contains **2 or more distinct operations** must have sub-steps
- Steps with only **1 operation** do not need sub-steps (e.g., "Return result")
- Sub-steps are written top-to-bottom following the code order inside the step
- Error handling is folded into the sub-step it belongs to, e.g., "Fetch purpose by code (error if not found)"

### 5. Write each step and sub-step

Write in **business language**:
- Describe what happens using entity/domain names from the code (e.g., "data subject", "collection point")
- Do not reference raw code identifiers like `uc.repo.Method` or `entity.NewX()`
- Keep each step/sub-step to one sentence
- Do not explain "why" — only "what" and "how"

### 6. Output format

```
Steps for `<function_name>`:

1. <what this step does>
1.1. <how — first operation>
1.2. <how — second operation>
2. <what this step does>
2.1. <how — first operation>
2.2. <how — second operation>
3. <single-operation step — no sub-steps needed>
...
N. <step>
```

If the user didn't provide a function name, use `Steps for the provided code:`.

## Example

Given this function:

```go
func (uc *esignatureUseCase) ValidateEsignatureInfo(ctx context.Context, input *ValidateEsignatureInfoInput) (*ValidateEsignatureInfoOutput, error) {
    // ... (validates input, calls KYC, manages data subject, handles esign)
}
```

Output:

```
Steps for `ValidateEsignatureInfo`:

1. Validate input
1.1. Check if esign_base64 is provided
1.2. Validate mime_type is required when esign_base64 is provided
1.3. Validate mime_type is an allowed type
2. Validate KYC status
2.1. Inquiry KYC status with citizen ID and IAL
2.2. Validate status code is eligible (error if not)
3. Fetch data subject by citizen ID
4. Create or update data subject
4.1. If not found, create new data subject with citizen ID, CIF, names, and mobile number
4.2. If found but revoked, error
4.3. If found and active, update with new CIF, names, and mobile number
5. Handle esign replacement if esign_base64 is provided
5.1. Fetch existing esign by data subject ID
5.2. Mark existing esign as inactive if one exists
5.3. Create new esign with data subject ID, mime type, and base64 data
6. Return success with created flag
```

## Example with loop sub-steps

```
Steps for `AcceptConsent`:

1. Validate purposes input
2. Fetch and validate collection point
2.1. Fetch collection point by code (error if not found)
2.2. Check if any purpose is accepted
2.3. Validate collection point is active when any purpose is accepted (error if inactive)
3. Fetch and validate data consumer
3.1. Fetch data consumer by code (error if not found)
3.2. Validate data consumer is active when any purpose is accepted (error if inactive)
4. Fetch and validate purposes and versions
4.1. Fetch purpose by code (error if not found)
4.2. Validate purpose is active when accepted
4.3. Fetch purpose version (error if not found)
4.4. Validate purpose version is active when accepted
4.5. Validate scope per purpose (accountNo scope requires scope_value)
5. Validate no duplicate purpose + version + scope_value combination
6. Get or create data subject
6.1. Fetch data subject by citizen ID
6.2. If not found, create new data subject (with retry on race condition)
7. Prepare each consent entity and audit log
7.1. Determine scope value per purpose
7.2. Look up existing consent by unique key
7.3. If existing, accept or decline the consent
7.4. If new, create consent entity with status and grant time
7.5. Build audit log for each consent operation
8. Persist all consents and audit logs in a single transaction
9. Return result
```

Every run on the same code must produce these same steps and sub-steps.

## Edge Cases

- **Empty function**: Output `Steps for '<name>': (no steps — function body is empty)`
- **Single-line function**: Output a single step, no sub-steps
- **Nested functions / closures**: Explain the outer function's flow only
- **Class methods**: Treat the same as functions

## Language

Default output language is **English**. If the user writes their prompt in Thai or requests Thai, output steps in Thai while still keeping entity names in their original form.
