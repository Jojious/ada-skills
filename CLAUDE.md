# Skills Repository — Rules for Agents

---

## Guardrails

### MUST

- Run `/skill-creator` before creating or modifying any skill
- Follow the [Agent Skills Specification](https://agentskills.io/specification)
- Place skills in `./skills/<skill-name>/`; test plans in `./tests/<skill-name>/`
- Include valid YAML frontmatter (`name`, `description`) in SKILL.md
- Test all scripts before packaging; validate with `skills-ref validate`
- Use environment variables for secrets — never hardcode keys, tokens, or passwords

### MUST NOT

- Create README.md, CHANGELOG.md, or auxiliary docs (SKILL.md is the single source)
- Exceed 500 lines in SKILL.md (split to `references/`)
- Commit `node_modules` or `.sisyphus` directories

### PREFER

- Bun over Node.js; TypeScript strict mode; ES Modules (`"type": "module"`)
- Progressive disclosure: metadata (~100 tokens) → SKILL.md body (<5k tokens) → references (on-demand)
- Consistent JSON output: `{ success, data, timestamp }`
- Naming: skill names `kebab-case`, tool names `snake_case`, file names `kebab-case` or `snake_case`

---

## Skill Format

**SKILL.md** is the only required file. Description is critical — include what + when + trigger keywords.

```yaml
---
name: skill-name          # lowercase, hyphens only, 1-64 chars
description: ...           # what + when + trigger keywords, 1-1024 chars
compatibility: opencode    # optional
metadata:                  # optional
  author: your-name
  version: "1.0"
---
```

Optional directories: `scripts/` (executable code), `references/` (on-demand docs), `assets/` (static files).

---

## Multi-Platform Sync Rules

Some skills have platform-specific variants that must be kept in sync.

### Platform Tool Mapping

| Capability | Claude Code | Copilot CLI | Kiro CLI | OpenCode |
|------------|-------------|-------------|----------|----------|
| Shell exec | `Bash` | `bash` | `execute_bash` | `bash` |
| Read file | `Read` | `view` | `fs_read` | `read` |
| Write file | `Write` | `edit`/`create` | `fs_write` | `write`/`edit` |
| Ask user | `AskUserQuestion` | `ask_user` | plain text | `question` |
| Sub-agent | `Agent` | `task` | `use_subagent` | `task` |
| Invoke skill | user `/skill` | auto-load or user `/skill` | user `/skill` | `skill` tool |
| Model select | sonnet/opus/haiku | full model names | default only | per-agent config |

### Skills Requiring Sync

| Skill Family | Claude Code | Copilot CLI | Kiro CLI | OpenCode |
|--------------|-------------|-------------|----------|----------|
| **neo-team** | `neo-team-claude` | `neo-team-copilot` | `neo-team-kiro` | `neo-team-opencode` |
| **gitlab** | `gitlab-claude` | `gitlab-copilot` | `gitlab-kiro` | `gitlab-opencode` |

**Sync:** workflow logic, specialist references, review templates, task classification rules.

**Differs per platform (do NOT copy blindly):** tool names/syntax, agent spawning, model selection (Kiro has none).

---

## Defaults

- **Timezone:** UTC+7 (Asia/Bangkok)
- **Documentation language:** English — Thai acceptable for LLM/chat and Thai-targeted skills

---

## Resources

- [Agent Skills Specification](https://agentskills.io/specification)
- [Full Documentation](https://agentskills.io/llms.txt)
