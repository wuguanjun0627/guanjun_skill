# guanjun_skill

个人 Cursor **技能集合（Skill Hub）**。一次安装，复制下面一段话发给 Agent 即可加载并路由到具体技能。

## 一次性安装

```bash
git clone https://github.com/wuguanjun0627/guanjun_skill.git ~/guanjun_skill
ln -sf ~/guanjun_skill ~/.cursor/skills/guanjun-skill-hub
```

安装后新开 Agent 会话（或重新打开对话），技能才会被识别。

## 一键加载 Hub

复制下面这段话发给 Agent，由 Hub 读取 [hub/INDEX.md](./hub/INDEX.md) 并路由到对应子技能：

```
请加载 guanjun_skill 技能集合：https://github.com/wuguanjun0627/guanjun_skill。先读 hub/INDEX.md，再根据我的需求路由到对应子技能。
```

也可粘贴仓库链接、说「用 guanjun_skill」；执行细节见仓库内 `hub/AGENT.md` 与各子技能 `SKILL.md`。

## 技能一览

完整注册表见 [hub/INDEX.md](./hub/INDEX.md)。新增子技能时在此表追加一行即可。

| 名称 | 一句话介绍 | 复制即用 prompt |
|------|------------|-----------------|
| [organize-files](./organize-files/) | macOS 三阶段文件整理：扫描常见文件夹 → 中文整理计划 → 确认后安全移动 | 见下方 |
| [media-pipeline](./media-pipeline/) | 火山 Seedream 文生图 + Seedance 视频 + OpenAI 文生图 | 见下方 |

### organize-files

**介绍：** 交互式整理 `Downloads`、`Documents` 等路径：先扫描统计，再给出中文移动计划，你确认后才执行 `mv`（不删文件）。

**复制即用：**

```
用 guanjun_skill 的 organize-files：扫描 Downloads 和 Documents，列出整理计划，等我确认再执行。
```

### media-pipeline

**介绍：** 火山 **Seedream** 文生图 + **Seedance** 图生/文生视频 + OpenAI gpt-image-2。密钥在 `~/.config/ai-media/.env`（`ARK_API_KEY` / `OPENAI_API_KEY`）。国内优先用火山脚本，无需代理。

**复制即用（火山文生图）：**

```
用 guanjun_skill 的 media-pipeline：执行 gen_ark_image.sh，prompt 是「星际穿越，黑洞里冲出支离破碎的复古列车，电影大片」，size 2K。
```

**复制即用（图生视频）：**

```
用 guanjun_skill 的 media-pipeline：执行 gen_video.sh，prompt 是「无人机穿越障碍的沉浸式飞行」，首帧图用 https://ark-project.tos-cn-beijing.volces.com/doc_image/seepro_i2v.png，时长 5 秒。
```

---

<!-- 新增技能模板（复制一段即可）：
### <skill-name>

**介绍：** …

**复制即用：**

```
用 guanjun_skill 的 <skill-name>：…
```
-->
