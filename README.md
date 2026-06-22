# OpenMAIC Teaching — 终端教学插件

**独立运行**：不依赖 OpenMAIC 源码或 `localhost:3000`。智能体 + 技能在终端完成完整授课流程。

> 开发/调试 OpenMAIC Web 请用 `openmaic-dev-plugin`。本插件面向**终端用户**。

## 快速开始

```bash
# 安装插件
claude plugin install ./openmaic-teaching-plugin

# 初始化课程目录（可选）
./openmaic-teaching-plugin/scripts/init-lesson.sh photosynthesis-basics "给初中生讲光合作用"

# 在 Claude Code 中
/openmaic-terminal-classroom
# 或自然语言：「教我一堂关于量子纠缠的课，中文，高中生」
```

## 用户旅程 → Skill 路由

```
终端授课请求
     │
     ▼
openmaic-terminal-classroom（全流程入口）
     │
     ├─ Phase 1 规划 → prompts/outline-generator.md → outlines.json
     ├─ Phase 2 组班 → openmaic-teaching-agent → team.json
     ├─ Phase 3 授课 → openmaic-classroom-orchestrator → scenes/*.md
     └─ Phase 4 讨论 → openmaic-discussion-facilitator → discussion-log.md
```

| 用户想做什么 | Skill / Agent |
|-------------|---------------|
| 完整终端授课 | `openmaic-terminal-classroom` |
| 只设计教学团队 | `openmaic-teaching-agent` |
| 逐场景讲解/测验 | `openmaic-classroom-orchestrator` |
| QA / 多智能体讨论 | `openmaic-discussion-facilitator` |
| 只生成大纲 | `lesson-planner` agent |

## 核心概念

- **lessons/{slug}/** — 本地课程包（大纲、团队、场景脚本、讨论记录）
- **Agent** — teacher | assistant | evaluator | facilitator | student
- **Director** — `prompts/director.md` 规则，终端轮替决策
- **Prompt 资产** — 从 OpenMAIC `lib/prompts/` 提取，见 `prompts/README.md`

## 与 OpenMAIC Web 的分工

| | openmaic-teaching-plugin | openmaic-dev-plugin | OpenMAIC Web |
|--|--------------------------|---------------------|--------------|
| 运行环境 | **终端 / Claude Code** | 源码开发 | 浏览器 |
| 输出 | Markdown 课程包 | 代码变更 | JSON actions + UI |
| 依赖 | 无 | 仓库源码 | Node/pnpm |

## 目录结构

```
openmaic-teaching-plugin/
├── skills/           # 4 个 user-invocable 技能
├── agents/           # 3 个专项智能体
├── prompts/          # 6 个核心提示词（从 lib/prompts 提取）
├── references/       # 角色准则、Persona、目录规范
└── scripts/          # init-lesson.sh, validate-plugin.sh
```

## 验证

```bash
chmod +x openmaic-teaching-plugin/scripts/*.sh
./openmaic-teaching-plugin/scripts/validate-plugin.sh
```

## 安装

```bash
claude plugin install ./openmaic-teaching-plugin
```
