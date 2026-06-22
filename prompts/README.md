# 核心提示词资产

从 OpenMAIC `lib/prompts/` 提取并适配为**终端教学**可用的提示词。原项目用 JSON 动作驱动 UI；本插件将其转为 Markdown 角色输出，保留教学设计与编排逻辑。

## 提示词映射

| 终端阶段 | 原 PROMPT_ID | 本目录文件 |
|---------|-------------|-----------|
| 课程规划 | `requirements-to-outlines` | `outline-generator.md` |
| 智能体生成 | `generateAgentProfiles` (TS) | `agent-profiles.md` |
| 场景讲解 | `slide-content` + `slide-actions` | `scene-teaching.md` |
| 测验 | `quiz-content` | `quiz-generator.md` |
| 实时讨论 | `agent-system` + `director` | `agent-system.md` + `director.md` |
| 角色准则 | `prompt-builder.ts` ROLE_GUIDELINES | `references/role-guidelines.md` |

## 使用方式

技能在对应阶段**读取并遵循**这些文件，无需 OpenMAIC 服务器：

```
openmaic-terminal-classroom → 读 outline-generator.md → 生成 outlines.json
openmaic-teaching-agent     → 读 agent-profiles.md   → 生成 team.json
openmaic-classroom-orchestrator → 读 scene-teaching.md → 生成 scenes/*.md
openmaic-discussion-facilitator → 读 director.md + agent-system.md → 终端多轮讨论
```

## 与 OpenMAIC 的差异

| 维度 | OpenMAIC Web | 本插件终端 |
|------|-------------|-----------|
| 输出 | JSON action 数组 | Markdown 角色块 + 可选 ASCII 白板 |
| 存储 | IndexedDB / 服务器 | 本地 `lessons/{slug}/` |
| 编排 | LangGraph SSE | 智能体按 Director 规则轮替发言 |
| 媒体 | gen_img / TTS | 文字描述或 Mermaid/ASCII 替代 |
