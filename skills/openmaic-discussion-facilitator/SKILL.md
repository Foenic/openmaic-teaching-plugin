---
name: openmaic-discussion-facilitator
description: 终端讨论引导 — QA/多智能体讨论、Director 轮替、discussion-log 持久化。无需 LangGraph SSE。
user-invocable: true
---

# 讨论引导（终端版）

在终端模拟 OpenMAIC 多智能体讨论：Director 决策 → Agent 发言 → 用户介入。

## 核心规则

- 状态在 `lessons/{slug}/state.json` + `discussion-log.md`
- 每次轮替读 `prompts/director.md` → JSON → 派 agent
- Agent 发言遵循 `prompts/agent-system.md` + `team.json` persona
- 无 SSE — 同步逐轮呈现

## 编排架构

```
用户输入 → teaching-director → next_agent
              ↓
         agent 发言（Markdown 角色块）
              ↓
         更新 state.json + discussion-log.md
              ↓
         END | USER | 下一 agent
```

## SOP

### 1. 初始化讨论

```json
// state.json
{
  "turnCount": 0,
  "agentResponses": [],
  "discussionTopic": "AI 的伦理边界",
  "sessionType": "discussion",
  "triggerAgentId": "agent-student-thinker",
  "maxTurns": 6
}
```

会话类型：

| sessionType | maxTurns | 策略 |
|-------------|----------|------|
| qa | 1-2 | 派 teacher → USER |
| discussion | 4-8 | Director 全规则 |

### 2. Director 决策

读：
- `prompts/director.md`
- `team.json`
- `state.json` + 最近对话摘要

输出**仅**：
```json
{"next_agent": "agent-teacher"}
```

快路径（无需 LLM 推理）：
- QA + 1 agent → teacher
- turn 0 + triggerAgentId → 派 trigger

### 3. Agent 发言

加载 agent 的 persona + `references/role-guidelines.md` 对应段 + `prompts/agent-system.md`。

输出格式：
```markdown
### [王老师 · teacher]
{口语讲解，无 markdown 格式符号}

> 白板:（可选）
```

追加到 `discussion-log.md`：
```markdown
## Turn 2 — 王老师 (teacher)
...
```

更新 `state.json.agentResponses`。

### 4. 用户介入

`next_agent: "USER"` → 暂停，显示提示，读用户输入后继续。

用户消息记入 discussion-log：
```markdown
## [Student (Human)]
{用户原话}
```

### 5. 结束

`next_agent: "END"` 或 `turnCount >= maxTurns`：
- 可选 facilitator 一句话总结
- 重置或保留 state 供恢复

## 白板（终端）

原 WhiteboardLedger → discussion-log 中的 `> 白板:` 块累积。Director 决策时数白板块数，>5 时优先派整理/总结型 agent。

## 学习评估

- **evaluator**：讨论中插入理解检查
- **quiz 场景**：配合 orchestrator 的 quiz 交互
- 评估结果可写入 `lesson.yaml`

## 中断恢复

下次读 `state.json.turnCount`，设 `maxTurns = turnCount + N`，从 Director 继续。

## 质量红线

- 未解用户问题 → 禁止 END
- 不连续同 role
- 不重复已解释内容
- student 必须短于 teacher
