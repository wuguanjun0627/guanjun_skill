# guanjun_skill

个人 Cursor **技能集合（Skill Hub）**。安装一次后，**日常只需一句 prompt**，Agent 会自动 bootstrap（拉密钥、建目录、装依赖）。

## 一次性安装

```bash
zsh ~/guanjun_skill/hub/scripts/install.sh
# 或手动：
# git clone https://github.com/wuguanjun0627/guanjun_skill.git ~/guanjun_skill
# ln -sf ~/guanjun_skill ~/.cursor/skills/guanjun-skill-hub
```

需已 `gh auth login`（用于从 private 仓库自动拉 API Key）。

## 一句 prompt 即可

| 想做什么 | 复制发给 Agent |
|----------|----------------|
| 文生图 | `用 guanjun_skill 生成图：日落城市天际线，2K` |
| 图生视频 | `用 guanjun_skill 生成视频：无人机穿越障碍，首帧 https://ark-project.tos-cn-beijing.volces.com/doc_image/seepro_i2v.png，5秒` |
| 整理文件 | `用 guanjun_skill 整理 Downloads 和 Documents，出计划等我确认` |

Agent 会自动：`bootstrap.sh` → 拉 `ARK_API_KEY` → 执行对应脚本。**无需**再手动 `pull_env` 或配置路径。

## 技能一览

见 [hub/INDEX.md](./hub/INDEX.md)。协议见 [hub/AGENT.md](./hub/AGENT.md)。

| 名称 | 自动配置 |
|------|----------|
| [media-pipeline](./media-pipeline/) | 输出目录、`~/.config/ai-media/.env`（private secrets）、openai 包 |
| [organize-files](./organize-files/) | `~/.cursor/file-organizer/`、默认 config.json |

## 密钥（仅所有者）

- Private 仓库：[guanjun-skill-secrets](https://github.com/wuguanjun0627/guanjun-skill-secrets)
- 更新 Key 后：`~/guanjun_skill/media-pipeline/scripts/push_env.sh`
