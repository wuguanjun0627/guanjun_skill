# Agent Bootstrap Protocol

Hub 被加载（用户粘贴 GitHub URL、提及 guanjun_skill 等）后，Agent 按此顺序读取与行动。

## 1. 确认仓库可用

| 情况 | 做法 |
|------|------|
| 本地已 clone / symlink | 根路径：`~/guanjun_skill` 或 `~/.cursor/skills/guanjun-skill-hub` |
| 仅 URL、无本地副本 | WebFetch `https://raw.githubusercontent.com/wuguanjun0627/guanjun_skill/main/hub/INDEX.md`，路由后再 fetch 对应子路径 raw 文件 |

## 2. 必读（按顺序）

1. **本文件**（可选；需要完整协议时）
2. **[INDEX.md](INDEX.md)** — 注册表；确定目标子目录
3. **`<sub-skill>/SKILL.md`** — 仅在被路由后读取

## 3. 按需读取

- 子技能 `reference.md`、`examples.md`
- 子技能 `scripts/` 下的脚本（执行前可读脚本确认行为）

## 4. 执行原则

- Hub 只做路由与全局约束，**不**替代子技能步骤
- organize-files：**SCAN → PLAN → EXECUTE**；EXECUTE 前必须用户明确批准
- 全程与用户语言一致（子技能默认中文）
- 操作记录、数据目录等以子技能 SKILL.md 为准

## 5. 失败与降级

- INDEX 无匹配 → 列出表中技能，请用户选择
- 本地路径不存在 → WebFetch raw GitHub；仍失败则告知用户 clone + symlink（见仓库 README）
- 脚本执行失败 → 报告 stderr，不静默跳过

## Raw URL 模板

```
https://raw.githubusercontent.com/wuguanjun0627/guanjun_skill/main/<path>
```

示例：`.../main/organize-files/SKILL.md`、`.../main/organize-files/scripts/file-organizer-scan.sh`
