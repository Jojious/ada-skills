# Ada Skills

A collection of AI agent skills extending capabilities through specialized tools.

## Installation

```bash
npx skills add https://github.com/Jojious/ada-skills
```

## Development & Automation

| Skill | Description |
| --- | --- |
| [api-doc-gen](./skills/api-doc-gen/) | Generate & validate API documentation from source code |
| [brainstorm](./skills/brainstorm/) | Structured discovery & prompt improvement |
| [commit](./skills/commit/) | Smart git commit workflow with branch protection & conventional commits |
| [confluence-api-doc](./skills/confluence-api-doc/) | Sync API documentation from Markdown to Confluence pages via acli + REST API |
| [improve](./skills/improve/) | Iterative improvement until measurable criteria are met |

## Team Orchestration (multi-platform)

| Skill | Platform | Description |
| --- | --- | --- |
| [neo-team-claude](./skills/neo-team-claude/) | Claude Code | Orchestrate specialized dev agent team (model selection supported) |
| [neo-team-copilot](./skills/neo-team-copilot/) | Copilot CLI | Orchestrate specialized dev agent team (model selection supported) |
| [neo-team-kiro](./skills/neo-team-kiro/) | Kiro CLI | Orchestrate specialized dev agent team (default model only) |
| [neo-team-opencode](./skills/neo-team-opencode/) | OpenCode | Orchestrate specialized dev agent team (session-inherited model) |

## GitLab Integration (multi-platform)

| Skill | Platform | Description |
| --- | --- | --- |
| [gitlab-claude](./skills/gitlab-claude/) | Claude Code | GitLab MR Create/Read/Review/Fix workflows via glab CLI |
| [gitlab-copilot](./skills/gitlab-copilot/) | Copilot CLI | GitLab MR Create/Read/Review/Fix workflows via glab CLI |
| [gitlab-kiro](./skills/gitlab-kiro/) | Kiro CLI | GitLab MR Create/Read/Review/Fix workflows via glab CLI |
| [gitlab-opencode](./skills/gitlab-opencode/) | OpenCode | GitLab MR Create/Read/Review/Fix workflows via glab CLI |

## DevOps & Infrastructure

| Skill | Description |
| --- | --- |
| [atlassian](./skills/atlassian/) | Jira & Confluence management via acli CLI |

---

**Skills:** 14 total
**Usage:** See individual skill SKILL.md for details
**Create:** Run `/skill-creator` first, see [CLAUDE.md](./CLAUDE.md)
**Spec:** https://agentskills.io/specification
