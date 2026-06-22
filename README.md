# OpenMAIC Teaching — 教学智能体插件

将 OpenMAIC 的多智能体能力封装为可复用的教学场景技能：**定制教学团队、编排课堂生成、引导多轮讨论**。

> 本插件是**用户向**技能包（SOP + 最佳实践），不包含源码级调试指南。开发调试请用 `openmaic-dev-plugin`。

## 用户旅程 → Skill 路由

```
设计教学团队 → 配置课堂生成 → 进入课堂 → 互动讨论 → 学习评估
     │              │            │           │            │
     ▼              ▼            ▼           ▼            ▼
 teaching-      classroom-    openmaic    discussion-  (evaluator
 agent          orchestrator  (主技能)    facilitator  角色)
```

| 用户想做什么 | 用哪个 Skill |
|-------------|-------------|
| 创建自定义教学智能体、编写 Persona | `openmaic-teaching-agent` |
| 控制课堂生成参数、场景类型、媒体 | `openmaic-classroom-orchestrator` |
| 发起和管理多智能体讨论、评估 | `openmaic-discussion-facilitator` |
| 安装 OpenMAIC、首次生成课堂 | `openmaic`（仓库内 skills/openmaic/） |

## 核心概念

- **Agent（智能体）** — 有 persona、role、优先级、操作权限的 AI 角色
- **Role（角色）** — teacher | assistant | evaluator | facilitator | student
- **Director（导演）** — LangGraph 编排，决定哪个智能体下一个发言
- **Scene（场景）** — slide | quiz | interactive | code | game 等 9 种类型
- **Discussion（讨论）** — QA（单轮）或 Discussion（多轮多智能体）

## 三条运行时路径

1. **课堂生成** — `POST /api/generate-classroom` → 8 阶段流水线
2. **讲座播放** — PlaybackEngine 按预设 Scene.actions 顺序执行
3. **实时讨论** — `POST /api/chat` → LangGraph Director → SSE 流

## 增强角色体系

| Role | 操作权限 | 用途 |
|------|---------|------|
| `teacher` | Slides + 白板 | 主讲教师 |
| `assistant` | 白板 | 补充讲解 |
| `evaluator` | 白板 | 学习评估、诊断反馈 |
| `facilitator` | 白板 | 讨论引导、观点整合 |
| `student` | 白板 | 参与互动 |

## 与其它插件/技能的分工

| | openmaic-teaching-plugin | openmaic-dev-plugin | skills/openmaic/ |
|--|--------------------------|---------------------|------------------|
| 受众 | **使用** OpenMAIC 教学的 AI | **开发** OpenMAIC 的 AI | OpenClaw **用户** |
| 内容 | 教学场景 SOP、最佳实践 | 代码路径、业务规则 | 安装 SOP、一键生成 |
| 发布 | Claude Code 插件 | Claude Code 插件 | ClawHub |

## 验证

```bash
./openmaic-teaching-plugin/scripts/validate-plugin.sh
```

## 安装

```bash
claude plugin install ./openmaic-teaching-plugin
```
