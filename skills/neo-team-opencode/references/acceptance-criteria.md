# Acceptance Criteria — [Feature/Module Name]

**Version:** [version]
**Created Date:** [date]
**Created By:** Business Analyst

---

## Feature 1: [Feature Name]

### User Story

As a [actor / role],
I want to [action],
So that [business value].

### Acceptance Criteria

#### AC-001: [Scenario name — happy path]

**GIVEN** [initial context / precondition]
**WHEN** [action is taken]
**THEN** [expected outcome]
**AND** [additional outcome if needed]

**Business Rule:** [underlying rule this validates — must be explicit and testable]
**Priority:** P0 (Critical) | P1 (High) | P2 (Medium)

---

#### AC-002: [Scenario name — error/edge case]

**GIVEN** [initial context / precondition]
**WHEN** [action is taken]
**THEN** [expected outcome — include specific error code/message if applicable]

**Business Rule:** [underlying rule this validates]
**Priority:** P0 (Critical) | P1 (High) | P2 (Medium)

---

### Business Rules

1. [rule 1 — explicit, testable, no ambiguity]
2. [rule 2 — if it involves validation, state exactly what values are valid/invalid]
3. [rule 3 — if it involves state transitions, list all valid transitions]

### Edge Cases

- [edge case 1 — include what the expected behavior should be]
- [edge case 2]

### Out of Scope

- [what is explicitly NOT included in this feature]

---

## Feature 2: [Feature Name]

_(repeat the same structure for each feature)_

---

## AC Summary

| ID | Feature | Scenario | Priority | Business Rule |
|----|---------|----------|----------|---------------|
| AC-001 | [feature] | [scenario name] | P0 | [short rule ref] |
| AC-002 | [feature] | [scenario name] | P1 | [short rule ref] |

**Total Acceptance Criteria:** N

---

## Notes

- [dependency notes, assumptions, or open questions]
- [if sourced from an existing design doc, reference it here: e.g., "Derived from docs/solution-design.md Section 3.2"]
