# Agent Bootstrap Protocol

Hub 被加载后，Agent **必须自动完成初始化**，再执行子技能。用户只需一句 prompt，**不要**反复询问 API Key、安装路径或 clone 步骤。

## 0. 自动初始化（每个子技能执行前，静默运行）

```bash
# 路由到子技能后、跑业务脚本前：
zsh ~/guanjun_skill/hub/scripts/bootstrap.sh <skill-name>
```

| 路由目标 | bootstrap 参数 | 自动完成 |
|----------|----------------|----------|
| media-pipeline | `media-pipeline` | 创建输出目录、从 private 仓库拉 `ARK_API_KEY`、`pip install openai`（若缺） |
| organize-files | `organize-files` | 创建 `~/.cursor/file-organizer/`、默认 `config.json` |

若本地无 `~/guanjun_skill`，`bootstrap.sh` 会尝试 `gh repo clone` + symlink。

各 `gen_*.sh` 与 organize 三阶段脚本内置 `setup.sh` / `ensure_env.sh`，单独调用时也会自动配置。

## 1. 确认仓库可用

| 情况 | 做法 |
|------|------|
| 本地已 clone / symlink | 根路径：`~/guanjun_skill` 或 `~/.cursor/skills/guanjun-skill-hub` |
| 仅 URL、无本地副本 | 先 `hub/scripts/install.sh`；或 WebFetch raw 文档（无法跑脚本时） |

## 2. 必读（按顺序）

1. **[INDEX.md](INDEX.md)** — 注册表 + 一句 prompt 模板
2. **`<sub-skill>/SKILL.md`** — 被路由后读取
3. 本文件 — 需要完整协议时

## 3. 按需读取

- 子技能 `reference.md`、`examples.md`
- 脚本源码（执行前可选）

## 4. 执行原则

- Hub 路由 → **bootstrap** → 子技能流程
- organize-files：**SCAN → PLAN → EXECUTE**；EXECUTE 前必须用户明确批准
- media-pipeline：**禁止**向用户索要 API Key（应已 `pull_env.sh`）；失败才提示检查 `gh auth login`
- 全程中文

## 5. 一句 prompt 约定

用户说法示例 → Agent 行为：

| 用户一句 prompt | Agent 自动做 |
|-----------------|-------------|
| `用 guanjun_skill 生成图：日落城市 2K` | bootstrap media → `gen_ark_image.sh` |
| `用 guanjun_skill 生成视频：…` | bootstrap media → `gen_video.sh` |
| `用 guanjun_skill 整理 Downloads` | bootstrap organize → scan → plan → 等确认 |

## 6. 失败与降级

- INDEX 无匹配 → 列出技能 + 一句 prompt 示例
- `pull_env.sh` 失败 → 提示 `gh auth login`（仅所有者可用 private secrets）
- 脚本失败 → 报告 stderr

## Raw URL 模板

```
https://raw.githubusercontent.com/wuguanjun0627/guanjun_skill/main/<path>
```
