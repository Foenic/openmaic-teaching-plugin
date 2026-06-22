---
name: openmaic-teaching-agent
description: 终端教学团队设计 — 创建多角色 AI 教师/学生/评估者，编写 Persona，生成 team.json。无需 OpenMAIC 浏览器环境。
user-invocable: true
---

# 教学智能体管理（终端版）

设计并持久化**多角色教学团队**，输出到 `lessons/{slug}/team.json`。

## 核心规则

- 每步确认后再执行
- **恰好 1 个** `role: "teacher"`
- 团队 3-5 人
- Persona 遵循 `language-directive.md`
- 不依赖 Zustand/IndexedDB/API — 纯文件

## 必读

- `prompts/agent-profiles.md`
- `references/persona-guide.md`
- `references/role-guidelines.md`

## 角色体系

| Role | priority | 终端职责 |
|------|----------|---------|
| teacher | 10 | 主导讲解、节奏控制 |
| assistant | 7 | 补充、简化、举例 |
| evaluator | 7 | 诊断理解、反馈 |
| facilitator | 7 | 引导讨论、整合观点 |
| student | 4-6 | 短句提问、反应 |

## SOP

### 1. 读取上下文

```bash
# 需已有规划产物
lessons/{slug}/language-directive.md
lessons/{slug}/outlines.json   # 可选，帮助定制 persona
lessons/{slug}/lesson.yaml
```

### 2. 设计团队组合

**通用课**：teacher + assistant + 2 student（好奇型 + 笔记型）

**讨论型课**：teacher + facilitator + 2 student + evaluator

**STEM**：teacher + assistant（调试/公式）+ student（预测型）

向用户展示拟选角色组合，确认。

### 3. 编写 Persona

按 `references/persona-guide.md` 三要素：

1. 身份声明
2. 2-4 条具体行为
3. 语气 + 长度约束

**学科定制**：参考 persona-guide 中的数学/历史/编程示例。

### 4. 输出 team.json

```json
{
  "agents": [
    {
      "id": "agent-teacher",
      "name": "王老师",
      "role": "teacher",
      "persona": "...",
      "priority": 10
    }
  ]
}
```

### 5. 验证

- [ ] teacher 数量 === 1
- [ ] 所有 id 唯一
- [ ] persona 语言与 language-directive 一致
- [ ] student persona 明确要求短回应

## 预设团队模板

可直接 Adapt 写入 team.json：

**标准四人组**：
- teacher：耐心专业主讲
- assistant：通俗补充
- student- curious：不断追问
- student-thinker：深度思辨

**评估五人组**：上述 + evaluator

## 交接

→ `openmaic-classroom-orchestrator` 开始逐场景授课  
→ `openmaic-discussion-facilitator` 发起讨论
