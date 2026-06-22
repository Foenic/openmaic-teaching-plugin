---
name: openmaic-classroom-orchestrator
description: 终端课堂编排 — 按 outlines 逐场景生成讲解、测验、互动，管理 lessons/ 进度。无需 OpenMAIC API。
user-invocable: true
---

# 课堂编排（终端版）

管理**本地课程包**的逐场景授课，替代 Web 端 8 阶段异步流水线。

## 核心规则

- 产物写入 `lessons/{slug}/`，不调用 HTTP API
- 按 `outlines.json` 的 `order` 串行推进
- 每场景完成后更新 `lesson.yaml`
- 失败场景可单独重生成，不阻塞后续

## 终端流水线

```
outlines.json → 逐场景生成 scenes/*.md → 终端朗读/交互 → discussion 钩子 → 下一场景
```

对比 Web 流水线（本插件**不需要**）：

```
~~POST /api/generate-classroom~~ → ~~TTS~~ → ~~媒体~~ → ~~IndexedDB~~
```

## SOP

### 1. 加载课程包

必需文件：
- `lesson.yaml`
- `language-directive.md`
- `outlines.json`
- `team.json`

### 2. 确定起点

```yaml
# lesson.yaml
currentScene: 3   # 从 scene 3 继续
status: teaching
```

### 3. 逐场景执行

对每个 outline：

| type | 读 prompt | 输出 |
|------|-----------|------|
| slide | `scene-teaching.md` | `scenes/scene_NN.md` |
| interactive | `scene-teaching.md` | 含 Mermaid/引导式实验 |
| pbl | `scene-teaching.md` | 分阶段任务清单 |
| quiz | `quiz-generator.md` | `scenes/scene_NN_quiz.md` |

**讲解流程**：
1. 展示「要点（Slide View）」
2. Teacher 块朗读讲解
3. 可选 Assistant/Student 短补充
4. 若有讨论钩子 → 提示用户可 invoke discussion skill
5. 问用户：继续 / 提问 / 深入讨论

### 4. Quiz 交互

1. 逐题展示选项
2. 等待用户输入 A/B/C/D 或文字
3. 揭示 analysis；evaluator 可选追加反馈
4. 写入 `lesson.yaml` → `quizResults`

### 5. 进度与恢复

```yaml
currentScene: 5
status: teaching
```

中断后从 `currentScene` 继续，已生成 `scenes/` 文件跳过（除非用户要求重写）。

## 场景类型速查

| type | 终端呈现 |
|------|---------|
| slide | 要点 + 角色讲解 + 可选 ASCII 白板 |
| quiz | 交互问答 |
| interactive | 分步引导 + Mermaid 模拟 |
| pbl | 里程碑 + 检查点 |

## 连贯性检查（每场景）

- [ ] 非首场景：无问候/重新自我介绍
- [ ] 引用前文用「刚才讲到…」
- [ ] teacher 段 ~100 字，student ~50 字
- [ ] 语言符合 language-directive

## 失败处理

| 问题 | 处理 |
|------|------|
| 单场景质量差 | 重写该 `scenes/scene_NN.md` |
| outline 整体偏差 | 回到 Phase 1 重规划 |
| 用户中途改需求 | 更新 outlines 中后续场景 only |

## 完成

全部场景 → `status: completed` → 可选 summary by evaluator
