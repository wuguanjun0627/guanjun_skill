# guanjun_skill

个人 Cursor **技能集合（Skill Hub）**。一次安装，复制下面一段话发给 Agent 即可加载并路由到具体技能。

## 一次性安装

```bash
git clone https://github.com/wuguanjun0627/guanjun_skill.git ~/guanjun_skill
ln -sf ~/guanjun_skill ~/.cursor/skills/guanjun-skill-hub
```

安装后新开 Agent 会话（或重新打开对话），技能才会被识别。

## 一键加载（复制下面这段话发给 Agent）

```
请加载 guanjun_skill 技能集合：https://github.com/wuguanjun0627/guanjun_skill。先读 hub/INDEX.md，再根据我的需求路由到对应子技能。
```

也可粘贴仓库链接、说「用 guanjun_skill」或直接描述子技能意图（如「整理文件」）；执行细节见仓库内 `hub/AGENT.md` 与各子技能目录。

## 仓库里有什么

当前包含 [organize-files](./organize-files/)（macOS 文件整理）等子技能；完整列表见 [hub/INDEX.md](./hub/INDEX.md)。
