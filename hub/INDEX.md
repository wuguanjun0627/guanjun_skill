# Skill Registry

一行触发 → 子技能路径。**Agent 路由后先 `bootstrap.sh`，再执行**；用户只需一句 prompt。

| 触发词 / 场景 | 路径 | 一句 prompt 示例 |
|---------------|------|------------------|
| 整理文件、清理下载、organize files、文件整理 | [organize-files/](../organize-files/) | `用 guanjun_skill 整理 Downloads 和 Documents，出计划等我确认` |
| 文生图、seedream、火山生图、generate image | [media-pipeline/](../media-pipeline/) | `用 guanjun_skill 生成图：日落城市天际线，2K` |
| 图生视频、文生视频、i2v、seedance、生成视频 | [media-pipeline/](../media-pipeline/) | `用 guanjun_skill 生成视频：无人机穿越障碍，首帧 URL …，5秒` |
| OpenAI 生图、gpt-image | [media-pipeline/](../media-pipeline/) | `用 guanjun_skill OpenAI 生图：橘猫水彩风` |

## 自动初始化

```bash
zsh ~/guanjun_skill/hub/scripts/bootstrap.sh media-pipeline   # 或 organize-files
```

## 路由说明

1. 匹配上表 → 运行 bootstrap → 读子技能 `SKILL.md` → 执行
2. 多技能匹配 → 选最具体的一项
3. ambiguous → 列出上表请用户选

## 维护

新增子技能：新建 `/<name>/SKILL.md` + `scripts/setup.sh`，更新本表与 `hub/scripts/bootstrap.sh`。
