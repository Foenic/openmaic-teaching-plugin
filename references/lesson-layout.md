# 终端课程目录结构

```
lessons/{slug}/
├── lesson.yaml           # 元数据、进度、测验得分
├── language-directive.md # 语言指令
├── team.json             # 智能体配置
├── outlines.json         # 场景大纲
├── scenes/
│   ├── scene_01.md
│   ├── scene_02_quiz.md
│   └── ...
├── discussion-log.md     # 讨论 transcript（追加）
└── state.json            # Director 状态（可恢复）
```

## lesson.yaml 模板

```yaml
title: "量子纠缠入门"
slug: quantum-entanglement-intro
language: zh-CN
createdAt: "2026-06-22"
requirement: "用户原始需求"
status: planning | teaching | discussion | completed
currentScene: 1
totalScenes: 10
quizResults: {}
```

## state.json 模板

```json
{
  "turnCount": 0,
  "agentResponses": [],
  "discussionTopic": null,
  "sessionType": "qa"
}
```

## slug 命名

小写英文连字符，从主题提取：`photosynthesis-basics`, `python-loops-intro`
