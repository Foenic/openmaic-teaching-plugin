#!/bin/bash
# validate-plugin.sh — 验证 openmaic-teaching-plugin 结构完整性
set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ERRORS=0

echo "==> 验证 openmaic-teaching-plugin (${PLUGIN_DIR})"

check_file() {
  local path="$1"
  local label="$2"
  if [ ! -f "${PLUGIN_DIR}/${path}" ]; then
    echo "  ✗ 缺少 ${path} (${label})"
    ERRORS=$((ERRORS + 1))
    return 1
  fi
  echo "  ✓ ${path}"
}

# 1. plugin.json
if [ ! -f "${PLUGIN_DIR}/.claude-plugin/plugin.json" ]; then
  echo "  ✗ 缺少 .claude-plugin/plugin.json"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ plugin.json"
  if ! python3 -m json.tool "${PLUGIN_DIR}/.claude-plugin/plugin.json" > /dev/null 2>&1; then
    echo "  ✗ plugin.json 格式无效"
    ERRORS=$((ERRORS + 1))
  fi
fi

check_file "CLAUDE.md" "业务指南"
check_file "README.md" "说明文档"

# 2. Skills
SKILLS=(
  "openmaic-terminal-classroom"
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
  if ! head -1 "${SKILL_FILE}" | grep -q "^---$"; then
    echo "  ✗ skills/${skill}/SKILL.md 缺少 frontmatter"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  if ! grep -q "^name: ${skill}$" "${SKILL_FILE}"; then
    echo "  ✗ skills/${skill}/SKILL.md name 字段不匹配"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  if ! grep -q "^user-invocable: true$" "${SKILL_FILE}"; then
    echo "  ✗ skills/${skill}/SKILL.md 缺少 user-invocable: true"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  echo "  ✓ skills/${skill}/SKILL.md"
done

# 3. Agents
AGENTS=(
  "lesson-planner"
  "teaching-director"
  "scene-teacher"
)

for agent in "${AGENTS[@]}"; do
  AGENT_FILE="${PLUGIN_DIR}/agents/${agent}.md"
  if [ ! -f "${AGENT_FILE}" ]; then
    echo "  ✗ 缺少 agents/${agent}.md"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  if ! grep -q "^name: ${agent}$" "${AGENT_FILE}"; then
    echo "  ✗ agents/${agent}.md name 字段不匹配"
    ERRORS=$((ERRORS + 1))
    continue
  fi
  echo "  ✓ agents/${agent}.md"
done

# 4. Core prompts
PROMPTS=(
  "outline-generator"
  "agent-profiles"
  "scene-teaching"
  "quiz-generator"
  "agent-system"
  "director"
)

for prompt in "${PROMPTS[@]}"; do
  check_file "prompts/${prompt}.md" "核心提示词"
done

check_file "prompts/README.md" "提示词索引"

# 5. References
REFS=(
  "role-guidelines"
  "persona-guide"
  "lesson-layout"
)

for ref in "${REFS[@]}"; do
  check_file "references/${ref}.md" "参考文档"
done

# 6. Scripts
if [ ! -x "${PLUGIN_DIR}/scripts/init-lesson.sh" ]; then
  echo "  ✗ scripts/init-lesson.sh 缺失或不可执行"
  ERRORS=$((ERRORS + 1))
else
  echo "  ✓ scripts/init-lesson.sh"
fi

# 7. 不应依赖 OpenMAIC API（静态检查）
API_DEPS=0
for f in "${PLUGIN_DIR}"/skills/*/SKILL.md; do
  if grep -q "localhost:3000" "$f" 2>/dev/null; then
    echo "  ✗ $(basename "$(dirname "$f")") 仍引用 localhost:3000"
    API_DEPS=$((API_DEPS + 1))
  fi
done
if [ "$API_DEPS" -eq 0 ]; then
  echo "  ✓ skills 无 localhost:3000 依赖"
else
  ERRORS=$((ERRORS + API_DEPS))
fi

echo ""
if [ $ERRORS -eq 0 ]; then
  echo "==> ✅ 全部验证通过"
else
  echo "==> ❌ ${ERRORS} 项验证失败"
  exit 1
fi
