#!/bin/bash
# init-lesson.sh — 初始化终端课程目录
set -euo pipefail

if [ $# -lt 2 ]; then
  echo "用法: $0 <slug> <requirement>"
  echo "示例: $0 photosynthesis-basics '给初中生讲光合作用，中文'"
  exit 1
fi

SLUG="$1"
REQUIREMENT="$2"
LESSON_DIR="lessons/${SLUG}"
DATE=$(date +%Y-%m-%d)

mkdir -p "${LESSON_DIR}/scenes"

cat > "${LESSON_DIR}/lesson.yaml" <<EOF
title: "${SLUG}"
slug: "${SLUG}"
language: zh-CN
createdAt: "${DATE}"
requirement: "${REQUIREMENT}"
status: planning
currentScene: 0
totalScenes: 0
quizResults: {}
EOF

cat > "${LESSON_DIR}/state.json" <<'EOF'
{
  "turnCount": 0,
  "agentResponses": [],
  "discussionTopic": null,
  "sessionType": "qa"
}
EOF

echo "✅ 已创建 ${LESSON_DIR}/"
echo "   lesson.yaml, state.json, scenes/"
echo ""
echo "下一步: invoke openmaic-terminal-classroom 或 lesson-planner agent"
