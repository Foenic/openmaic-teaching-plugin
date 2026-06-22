#!/bin/bash
# validate-plugin.sh — 验证 openmaic-teaching-plugin 结构完整性
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

echo "==> 验证 openmaic-teaching-plugin (${PLUGIN_DIR})"

# 1. plugin.json
if [ ! -f "${PLUGIN_DIR}/.claude-plugin/plugin.json" ]; then
  echo "  ✗ 缺少 .claude-plugin/plugin.json"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ plugin.json"
  # 验证 JSON 格式
  if ! python3 -m json.tool "${PLUGIN_DIR}/.claude-plugin/plugin.json" > /dev/null 2>&1; then
    echo "  ✗ plugin.json 格式无效"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 2. CLAUDE.md
if [ ! -f "${PLUGIN_DIR}/CLAUDE.md" ]; then
  echo "  ✗ 缺少 CLAUDE.md"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ CLAUDE.md"
fi

# 3. README.md
if [ ! -f "${PLUGIN_DIR}/README.md" ]; then
  echo "  ✗ 缺少 README.md"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ README.md"
fi

# 4. Skills
SKILLS=(
  "openmaic-teaching-agent"
  "openmaic-classroom-orchestrator"
  "openmaic-discussion-facilitator"
)

for skill in "${SKILLS[@]}"; do
  SKILL_FILE="${PLUGIN_DIR}/skills/${skill}/SKILL.md"
  if [ ! -f "${SKILL_FILE}" ]; then
    echo "  ✗ 缺少 skills/${skill}/SKILL.md"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # 验证 frontmatter
  if ! head -1 "${SKILL_FILE}" | grep -q "^---$"; then
    echo "  ✗ skills/${skill}/SKILL.md 缺少 frontmatter"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # 验证 name 字段
  if ! grep -q "^name: ${skill}$" "${SKILL_FILE}"; then
    echo "  ✗ skills/${skill}/SKILL.md name 字段不匹配"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  # 验证 user-invocable
  if ! grep -q "^user-invocable: true$" "${SKILL_FILE}"; then
    echo "  ✗ skills/${skill}/SKILL.md 缺少 user-invocable: true"
    ERRORS=$((ERRORS + 1))
    continue
  fi

  echo "  ✓ skills/${skill}/SKILL.md"
done

# 结果
echo ""
if [ $ERRORS -eq 0 ]; then
  echo "==> ✅ 全部验证通过"
else
  echo "==> ❌ ${ERRORS} 项验证失败"
  exit 1
fi
