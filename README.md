# guanjun_skill

个人 **Cursor Agent Skills** 集合仓库，用于集中管理、版本化和分享可在 Cursor 中使用的 Agent 技能。

## 仓库结构

```
guanjun_skill/
├── README.md              # 本说明
├── organize-files/        # macOS 文件整理（三阶段：扫描 → 计划 → 执行）
│   ├── SKILL.md
│   ├── reference.md
│   ├── examples.md
│   └── scripts/
└── <更多技能>/            # 后续在此目录下新增
    └── SKILL.md
```

## 安装技能

Cursor 会从 `~/.cursor/skills/` 加载用户技能（与内置的 `~/.cursor/skills-cursor/` 分开）。

### 方式一：复制（推荐，简单稳定）

```bash
# 安装单个技能（以 organize-files 为例）
mkdir -p ~/.cursor/skills
cp -R /path/to/guanjun_skill/organize-files ~/.cursor/skills/
```

### 方式二：符号链接（便于与仓库同步开发）

```bash
mkdir -p ~/.cursor/skills
ln -sf /path/to/guanjun_skill/organize-files ~/.cursor/skills/organize-files
```

将 `/path/to/guanjun_skill` 替换为本仓库在本机的实际路径（例如 `~/guanjun_skill`）。

安装后**重新打开 Cursor 对话**或新开 Agent 会话，技能即可被识别。技能是否触发取决于 `SKILL.md` 中的 `description` 与用户请求是否匹配。

## 当前技能

| 目录 | 说明 |
|------|------|
| [organize-files](./organize-files/) | macOS 交互式文件整理：扫描常见目录、中文整理计划、用户批准后安全移动并记录 manifest |

## 添加新技能

1. 在本仓库根目录新建文件夹，例如 `my-new-skill/`。
2. 放入 `SKILL.md`（含 YAML frontmatter：`name`、`description`），以及脚本、参考文档等附属文件。
3. 在本 README 的「当前技能」表中补充一行说明。
4. 提交并推送到 GitHub。
5. 在本机用复制或 symlink 将新目录安装到 `~/.cursor/skills/<技能名>/`。

命名建议：文件夹名与 `SKILL.md` 中 `name` 字段一致，使用小写与连字符（如 `organize-files`）。

## 开发与贡献

- 修改技能后在本仓库提交；本地若使用 symlink，Cursor 会直接读到更新。
- 脚本默认数据目录：`~/.cursor/file-organizer/`（可在技能说明中配置）。
- 请勿将密钥、token、`.env` 等敏感文件提交进仓库。

## 许可证

各技能内容归作者所有；使用与二次分发请遵循技能内说明或自行约定。
