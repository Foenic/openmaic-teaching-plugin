---
name: openmaic-teaching-agent
description: 教学智能体管理 — 创建、配置定制化多角色AI教学团队。涉及角色设计、Persona编写、优先级设定、操作权限管理、evaluator/facilitator新角色。
user-invocable: true
---

# 教学智能体管理

管理 OpenMAIC 多智能体教学系统中的 AI 角色：设计定制化教学团队、编写 Persona、配置角色权限。

## 核心规则

- 每步确认后再执行。
- 智能体配置存在浏览器 localStorage + IndexedDB。
- 不要直接修改 AgentConfig 类型 — 通过注册表 API 操作。
- 每个教学团队必须有且仅有一个 teacher 角色。

## 角色体系

| Role | 优先级 | 操作 | 职责 |
|------|--------|------|------|
| teacher | 10 | spotlight, laser, play_video + 全部白板 | 主导教学 |
| assistant | 7 | 全部白板 | 补充讲解 |
| evaluator | 7 | 全部白板 | 学习评估、诊断反馈 |
| facilitator | 7 | 全部白板 | 讨论引导、观点整合 |
| student | 4-6 | 白板（受限） | 参与互动 |

## SOP 阶段

### 1. 查看现有智能体

```typescript
const agents = useAgentRegistry.getState().listAgents();
// 过滤非生成: agents.filter(a => !a.isGenerated)
// 过滤生成: agents.filter(a => a.isGenerated)
```

内置智能体：`default-1`(AI teacher)、`default-2`(AI助教)、`default-3`(显眼包)、`default-4`(好奇宝宝)、`default-5`(笔记员)、`default-6`(思考者)。

### 2. 设计教学团队

**预设模式（preset）**：从内置智能体中选择 3-5 个。

**自动生成模式（auto）**：LLM 根据课程内容自动生成定制角色。由 `generateAgentProfiles()` 触发，需要 1 teacher + 2-4 assistant/student。

### 3. 编写 Persona

三要素：
1. **身份声明** — `You are the [角色] of this classroom.`
2. **行为准则** — 2-4 条具体行为描述（不要抽象品质）
3. **语气 + 约束** — 2-3 形容词 + 长度限制

角色模板参考 `skills/teaching-agent/references/persona-guide.md`。

### 4. 创建自定义智能体

```typescript
import { useAgentRegistry, createAgentFromTemplate } from '@/lib/orchestration/registry/store';
import { getActionsForRole } from '@/lib/orchestration/registry/types';

const registry = useAgentRegistry.getState();
registry.addAgent(createAgentFromTemplate({
  name: '数学思维引导者',
  role: 'facilitator',
  persona: '你是一位数学思维引导者...',
  avatar: '/avatars/custom.png',
  color: '#6366f1',
  allowedActions: getActionsForRole('facilitator'),
  priority: 7,
}, `custom-${Date.now()}`));
```

### 5. 保存与恢复

- 自定义智能体 → localStorage（Zustand persist）
- 生成智能体 → IndexedDB（按 stageId 绑定）
- 课堂加载时自动恢复：`loadGeneratedAgentsForStage(stageId)`
