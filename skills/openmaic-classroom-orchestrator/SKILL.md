---
name: openmaic-classroom-orchestrator
description: 课堂编排 — 管理课堂生成流水线、场景调度、内容分发、并行生成控制。涵盖 8 阶段生成、9 种场景类型、媒体/TTS 配置。
user-invocable: true
---

# 课堂编排

管理 OpenMAIC 课堂生成全流程：需求 → 大纲 → 场景内容/动作 → 媒体 → TTS → 课堂 URL。

## 核心规则

- 先查服务器能力：`GET /api/health` → `capabilities`
- 生成是异步流水线，保守轮询（~60s 间隔）
- 失败时诊断服务器配置，不要立即重试

## 生成流水线

```
需求 → 网络搜索 → 场景大纲 → 智能体生成 → 场景+动作并行 → 媒体 → TTS → 持久化
 5%      10%       15-30%       30%          31-90%        90%    94%     98-100%
```

## SOP 阶段

### 1. 准备需求

```
- 主题: [课程主题]
- 受众: [学生年级/水平]
- 语言: zh-CN | en-US | ja-JP | pt-BR | ru-RU | ar-SA
- 场景数: [默认 8-12]
```

### 2. 检测服务器能力

```bash
curl -s http://localhost:3000/api/health | jq '.capabilities'
# { "webSearch": true, "imageGeneration": false, "videoGeneration": false, "tts": true }
```

### 3. 触发生成

```bash
curl -X POST http://localhost:3000/api/generate-classroom \
  -H "Content-Type: application/json" \
  -d '{"requirement":"...","language":"zh-CN","agentMode":"generate"}'
```

`agentMode`：`"default"`（内置智能体）或 `"generate"`（LLM 生成定制角色）。

### 4. 轮询进度

```bash
curl -s http://localhost:3000/api/generate-classroom/{jobId} | jq '.status'
# queued → running → succeeded/failed
```

### 5. 加载课堂

```
http://localhost:3000/classroom/{classroomId}
```

页面自动从 IndexedDB 或服务器存储加载，并恢复智能体和媒体任务。

## 场景类型

| 类型 | 模板 | 说明 |
|------|------|------|
| slide | slide-content | 标准教学幻灯片 |
| interactive | interactive-outlines | 互动内容 |
| quiz | quiz-content + quiz-actions | 测验 |
| code | code-content | 编程教学 |
| diagram | diagram-content | 图表 |
| game | game-content | 游戏化学习 |
| simulation | simulation-content | 模拟场景 |
| visualization3d | visualization3d-content | 3D 可视化 |
| pbl | pbl-design + pbl-actions | 项目式学习 |

## 失败处理

- 大纲失败 → `applyOutlineFallbacks` 降级
- 场景失败 → `failedOutlines` + `retrySingleOutline`
- 媒体失败 → 优雅降级，不阻塞课堂
