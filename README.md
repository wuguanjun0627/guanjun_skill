# guanjun_skill

个人 Cursor **技能集合（Skill Hub）**。一次安装，对话里粘贴链接或说一句话即可让 Agent 加载并路由到具体技能。

## 一次性安装

```bash
git clone https://github.com/wuguanjun0627/guanjun_skill.git ~/guanjun_skill
ln -sf ~/guanjun_skill ~/.cursor/skills/guanjun-skill-hub
```

安装后新开 Agent 会话（或重新打开对话），技能才会被识别。

## 日常使用

在对话中任选一种方式即可加载 Hub：

- 粘贴：`https://github.com/wuguanjun0627/guanjun_skill`
- 说：「用 guanjun_skill」「打开技能集合」
- 直接说子技能意图，例如：「整理文件」「清理下载」

Agent 会自动路由到对应子技能；执行细节在仓库内各子目录，不在此 README 说明。

## 仓库里有什么

当前包含 [organize-files](./organize-files/)（macOS 文件整理）等子技能；完整列表见 [hub/INDEX.md](./hub/INDEX.md)。
