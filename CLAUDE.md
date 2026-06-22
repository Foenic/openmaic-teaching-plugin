# OpenMAIC Teaching — 教学智能体业务指南

将主题或 PDF 生成互动课堂后，本插件提供**教学智能体管理、课堂编排、讨论引导**三大能力。

> 通用工程流程（测试、Comet、本地环境）见仓库 `.agents/skills/`，本插件只覆盖**教学场景**。

## 核心业务概念

- **Agent（智能体）** — AI 教师/同学，有 persona、role、priority、allowedActions
- **Role 体系** — teacher | assistant | evaluator | facilitator | student
- **Director（导演）** — LangGraph StateGraph 多智能体编排（`lib/orchestration/director-graph.ts`）
- **Discussion** — QA（单轮单智能体）或 Discussion（多轮多智能体）
- **Classroom Generation** — 8 阶段流水线（需求 → 搜索 → 大纲 → 场景 → 媒体 → TTS → 持久化）
- **Agent Registry** — Zustand + IndexedDB，内置 6 个 + 可生成自定义

## 角色操作权限

| Role | 幻灯片操作 | 白板操作 |
|------|-----------|---------|
| teacher | spotlight, laser, play_video | 全部 12 项 |
| assistant | ❌ | 全部 12 项 |
| evaluator | ❌ | 全部 12 项 |
| facilitator | ❌ | 全部 12 项 |
| student | ❌ | 全部 12 项 |

## 智能体 Persona 三要素

1. **身份声明** — 第一句说清"你是谁"
2. **行为准则** — 2-4 条具体行为描述（不要抽象品质）
3. **语气 + 约束** — 2-3 形容词 + 输出长度限制

## 讨论编排流程

```
START → director ──(end)──→ END
           │
           └─(next)→ agent_generate ──→ director (loop)
```

- **单智能体**：纯代码逻辑，零 LLM 调用
- **多智能体 turn 0**：triggerAgent 快路径（跳过 LLM）
- **多智能体后续**：LLM 决策下一个发言者

## 关键入口文件

- 智能体注册：`lib/orchestration/registry/store.ts`
- 角色类型：`lib/orchestration/registry/types.ts`
- 编排引擎：`lib/orchestration/director-graph.ts`
- Prompt 构建：`lib/orchestration/prompt-builder.ts`
- 课堂生成：`lib/server/classroom-generation.ts`
- Chat API：`app/api/chat/route.ts`
- 技能文档：`skills/teaching-agent/`, `skills/classroom-orchestrator/`, `skills/discussion-facilitator/`

## 业务高风险点

- 每个课堂必须有且仅有一个 teacher 角色
- evaluator/facilitator 不能使用 spotlight/laser（无幻灯片权限）
- 白板 overload（>5 元素）时 Director 会提示整理
- auto 模式下的 generated agents 绑定到 stageId，切换课堂需重新加载
- 讨论模式下 directorState 由客户端维护，中断后需传入恢复

## 最小验证命令

```bash
pnpm test tests/chat/
# 手动：AgentBar 验证角色选择 → 发起讨论 → 观察 Director 决策
```
