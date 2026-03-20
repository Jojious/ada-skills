#!/usr/bin/env bash
# Symlink all skills from skills/ into .claude/skills/
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
SKILLS_DST="$REPO_ROOT/.claude/skills"

# clean existing skills before linking
rm -rf "$SKILLS_DST"
mkdir -p "$SKILLS_DST"

for skill_dir in "$SKILLS_SRC"/*/; do
  skill_name="$(basename "$skill_dir")"

  # skip platform-specific skills (copilot, kiro)
  case "$skill_name" in
    *-copilot|*-kiro) echo "skip  $skill_name (platform-specific)"; continue ;;
  esac

  target="$SKILLS_DST/$skill_name"
  # relative path from .claude/skills/ to skills/<name>
  rel_path="../../skills/$skill_name"

  if [ -L "$target" ]; then
    echo "skip  $skill_name (already linked)"
  elif [ -e "$target" ]; then
    echo "warn  $skill_name (exists as real file/dir, skipping)"
  else
    ln -s "$rel_path" "$target"
    echo "link  $skill_name"
  fi
done

echo ""
echo "done — $(ls "$SKILLS_DST" | wc -l | tr -d ' ') skills linked in .claude/skills/"
