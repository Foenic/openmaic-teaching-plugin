---
name: openmaic-terminal-classroom
description: 终端完整授课 — 无需 OpenMAIC 服务器，从需求到多智能体讨论的全流程。用户说「教我一堂…」「终端上课」时使用。
user-invocable: true
---

# 终端完整授课

**独立运行**：不依赖 OpenMAIC Web 服务器或源码。智能体在终端完成规划 → 组班 → 讲解 → 讨论。

## 何时使用

- 用户要在终端/CLI 直接完成教学
- 无 OpenMAIC Web 环境
- 需要可持久化的本地课程包（`lessons/`）

## 核心资产

| 路径 | 用途 |
|------|------|
| `prompts/outline-generator.md` | 课程大纲 |
| `prompts/agent-profiles.md` | 教学团队 |
| `prompts/scene-teaching.md` | 场景脚本 |
| `prompts/quiz-generator.md` | 测验 |
| `prompts/agent-system.md` | 实时发言 |
| `prompts/director.md` | 讨论编排 |
| `references/lesson-layout.md` | 目录规范 |

## 全流程 SOP

### Phase 0 — 初始化

```bash
# 在工作目录创建课程（slug 从主题推导）
mkdir -p lessons/{slug}/scenes
```

收集需求：
```
- 主题:
- 受众:
- 语言: zh-CN | en-US | ...
- 场景数: 默认 8-10
- 模式: lecture | discussion-heavy
```

写入 `lessons/{slug}/lesson.yaml`（见 `references/lesson-layout.md`）。

### Phase 1 — 规划（lesson-planner）

1. 读 `prompts/outline-generator.md`
2. 生成 `language-directive.md` + `outlines.json`
3. **向用户展示大纲摘要，确认后继续**

### Phase 2 — 组班（openmaic-teaching-agent）

1. 读 `prompts/agent-profiles.md` + `references/persona-guide.md`
2. 生成 `team.json`（1 teacher + 2-4 其他角色）
3. 展示团队 roster，确认

### Phase 3 — 授课（openmaic-classroom-orchestrator）

按 `outlines.json` 顺序：

1. 读 `prompts/scene-teaching.md` 或 `quiz-generator.md`
2. 生成并**当场朗读** `scenes/scene_XX.md`
3. slide：Teacher 讲解 → 可选 Assistant 补充 → 讨论钩子
4. quiz：逐题交互，记录 `quizResults`
5. 更新 `lesson.yaml` → `currentScene`

** pacing **：每场景讲解后 pause，问用户「继续 / 提问 / 讨论」。

### Phase 4 — 讨论（openmaic-discussion-facilitator）

用户提问或触发讨论钩子时：

1. teaching-director 读 `prompts/director.md` → 输出 `next_agent`
2. 对应 agent 读 `prompts/agent-system.md` + persona → 发言
3. 追加 `discussion-log.md`，更新 `state.json`
4. `USER` → 等待输入；`END` → 回到 Phase 3 或收束

### Phase 5 — 收束

- 最后场景总结
- evaluator 可选诊断反馈
- `lesson.yaml` → `status: completed`

## 子技能路由

| 阶段 | Skill / Agent |
|------|---------------|
| 全流程入口 | **本 skill** |
| 仅规划 | `lesson-planner` agent |
| 仅组班 | `openmaic-teaching-agent` |
| 仅逐场景讲 | `openmaic-classroom-orchestrator` |
| 仅讨论 | `openmaic-discussion-facilitator` |

## 与 OpenMAIC Web 的关系

| 能力 | Web | 终端 |
|------|-----|------|
| 大纲/内容 prompt | `lib/prompts/` | `prompts/`（已提取） |
| 输出 | JSON actions + UI | Markdown + 终端朗读 |
| 存储 | IndexedDB | `lessons/{slug}/` |
| TTS/配图 | 有 | 文字/Mermaid 替代 |

可选：课程包完成后导入 OpenMAIC Web 做可视化回放（非本插件范围）。

## 恢复中断

读 `lesson.yaml` 的 `currentScene` + `state.json`，从断点场景继续 Phase 3/4。
