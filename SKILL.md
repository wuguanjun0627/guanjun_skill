---
name: guanjun-skill-hub
description: >-
  Cursor skill hub for guanjun_skill — routes user intent to sub-skills in this
  repo. Use when the user pastes https://github.com/wuguanjun0627/guanjun_skill,
  mentions guanjun_skill, guanjun-skill-hub, 技能集合, skill hub, 整理文件,
  organize-files, or asks to use skills from this collection.
---

# guanjun Skill Hub

个人 Cursor 技能集合的**路由入口**。加载本 skill 后，按用户意图分发到子技能，不在此文件内展开执行细节。

## 加载后第一步

1. 读取 [hub/INDEX.md](hub/INDEX.md) — 技能注册表与触发词 → 路径映射
2. 根据用户消息匹配一行 registry，确定子技能目录（如 `organize-files/`）
3. **仅在被路由后**读取该目录下的 `SKILL.md`，并严格按子技能流程执行

详细引导顺序见 [hub/AGENT.md](hub/AGENT.md)（可选深读）。

## 路由规则

| 步骤 | 动作 |
|------|------|
| 匹配 | 用 INDEX 中的触发词/场景对照用户原话 |
| 定位 | 得到子目录相对路径，如 `organize-files/` |
| 读取 | 只读该目录的 `SKILL.md`；需要时再读其 `reference.md`、`examples.md`、脚本 |
| 执行 | 遵循子技能阶段与安全规则 |

无明确匹配时：列出 INDEX 中可用技能，请用户选择或补充意图。

## 全局约束

- **禁止**在未获用户明确批准时移动、删除或覆盖用户文件（子技能 organize-files 的三阶段流程尤其适用）
- 子技能脚本路径以本仓库根为基准；本地常见路径：`~/guanjun_skill/` 或 `~/.cursor/skills/guanjun-skill-hub/`
- 本仓库未 clone 到本地时，可用 WebFetch 拉取 GitHub raw 内容，例如：
  `https://raw.githubusercontent.com/wuguanjun0627/guanjun_skill/main/hub/INDEX.md`
  `https://raw.githubusercontent.com/wuguanjun0627/guanjun_skill/main/organize-files/SKILL.md`

## 新增子技能

维护者在子目录新增 `SKILL.md` 后，**必须**同步更新 [hub/INDEX.md](hub/INDEX.md) 一行映射。
