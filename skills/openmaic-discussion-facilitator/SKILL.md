---
name: openmaic-discussion-facilitator
description: 讨论引导 — 多智能体教学讨论编排、QA 引导、LangGraph Director 控制、白板协调。SSE 流式协议、DirectorState 维护、学习评估集成。
user-invocable: true
---

# 讨论引导

管理 OpenMAIC 多智能体教学讨论：QA/Discussion 模式、Director 编排、SSE 流式通信、白板协调。

## 核心规则

- 讨论是实时流式生成 — 状态由客户端维护（DirectorState）
- 后端完全无状态 — 所有上下文在请求中传递
- 使用 LangGraph StateGraph 编排多智能体

## 编排架构

```
START → director ──(end)──→ END
           │
           └─(next)→ agent_generate ──→ director (loop)
```

### Director 决策策略

| 场景 | 智能体数 | 方式 |
|------|---------|------|
| QA | 1 | 纯代码（0 LLM） |
| Discussion turn 0 | N | 代码快路径 |
| Discussion 后续 | N | LLM 决策 |

## SOP 阶段

### 1. 配置讨论参数

```typescript
const config = {
  agentIds: ['default-1', 'default-3', 'default-4', 'default-6'],
  sessionType: 'discussion',
  discussionTopic: 'AI的伦理边界',
  triggerAgentId: 'default-6',   // 思考者先发言
};

const qaConfig = {
  agentIds: ['default-1'],
  sessionType: 'qa',
};
```

### 2. 发起讨论

```bash
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"messages":[],"storeState":{...},"config":{...}}'
# 响应: SSE text/event-stream
```

### 3. 监控讨论

DirectorState 在每次 `done` 事件中返回，客户端累积后下次请求传入：

```typescript
interface DirectorState {
  turnCount: number;
  agentResponses: AgentTurnSummary[];
  whiteboardLedger: WhiteboardActionRecord[];
}
```

### 4. 白板协调

- WhiteboardLedger 记录所有智能体的白板操作
- Director 感知白板状态（元素数、贡献者）
- 过载警告（>5 元素）时提示整理
- 智能体通过虚拟白板上下文避免内容重复

### 5. 中断恢复

客户端保存 `directorState` → 下次请求传入 → `maxTurns = turnCount + 1` 继续编排。

## 学习评估

- **evaluator 角色**：在讨论中插入评估环节
- **quiz 场景**：自动批改 + `/api/quiz-grade`
- **PBL 模式**：`/api/pbl/chat` 项目阶段追踪

## 流式事件

| 事件 | 含义 |
|------|------|
| agent_start | 智能体开始 |
| text_delta | 文本增量 |
| action | 操作执行 |
| agent_end | 智能体结束 |
| thinking | Director 决策中 |
| cue_user | 等待输入 |
| done | 本轮完成（含 directorState） |
