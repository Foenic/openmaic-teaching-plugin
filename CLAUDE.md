# OpenMAIC Teaching — 终端教学业务指南

本插件将 OpenMAIC 核心提示词与多智能体编排逻辑**脱离 Web 应用**，在终端通过智能体 + 技能完成授课。

> 不依赖 `lib/orchestration/`、`app/api/` 或浏览器环境。产物持久化到 `lessons/{slug}/`。

## 架构

```
用户需求
   ↓
prompts/outline-generator.md  →  outlines.json + language-directive.md
   ↓
prompts/agent-profiles.md     →  team.json
   ↓
prompts/scene-teaching.md     →  scenes/*.md（终端朗读）
prompts/quiz-generator.md
   ↓
prompts/director.md           →  讨论轮替
prompts/agent-system.md       →  实时发言
```

## 核心业务概念

- **课程包** — `lessons/{slug}/` 下全部文件，可 git 管理、可恢复
- **Role** — teacher | assistant | evaluator | facilitator | student
- **Director** — 等价于 `lib/orchestration/director-graph.ts`，规则在 `prompts/director.md`
- **Persona** — 等价于 `buildStructuredPrompt()` 中的 persona + roleGuideline

## 提示词来源映射

| 本插件 | OpenMAIC 源码 |
|--------|--------------|
| `prompts/outline-generator.md` | `templates/requirements-to-outlines/` |
| `prompts/scene-teaching.md` | `slide-content` + `slide-actions` |
| `prompts/agent-system.md` | `templates/agent-system/` + `prompt-builder.ts` |
| `prompts/director.md` | `templates/director/` |
| `references/role-guidelines.md` | `prompt-builder.ts` ROLE_GUIDELINES |

终端版将 JSON action 输出改为 Markdown 角色块 + ASCII/Mermaid 白板。

## 角色权限（终端适配）

| Role | Web 幻灯片 | 终端替代 |
|------|-----------|---------|
| teacher | spotlight, laser | 「👉 注意要点 X」 |
| 其他 | 白板 only | `> 白板:` 代码块 |

## 不变量

- 每课恰好 1 个 teacher
- languageDirective 贯穿 outline → persona → scene → discussion
- 首场景唯一问候；中间场景自然过渡
- student 回应明显短于 teacher
- Director：未解用户问题禁止 END

## 技能入口

| Skill | 职责 |
|-------|------|
| `openmaic-terminal-classroom` | 全流程 SOP |
| `openmaic-teaching-agent` | team.json |
| `openmaic-classroom-orchestrator` | scenes/*.md |
| `openmaic-discussion-facilitator` | discussion-log.md |

## 智能体

| Agent | 职责 |
|-------|------|
| `lesson-planner` | 大纲规划 |
| `scene-teacher` | 单场景脚本 |
| `teaching-director` | 讨论轮替 JSON |

## 验证

```bash
./scripts/validate-plugin.sh
```

## 可选集成

课程包可手动导入 OpenMAIC Web 做可视化（非本插件范围）。Web 端开发见 `openmaic-dev-plugin`。
