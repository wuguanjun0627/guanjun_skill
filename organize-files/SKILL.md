---
name: organize-files
description: >-
  macOS file cleanup sub-skill (scan → plan → execute) invoked via
  guanjun-skill-hub. Runs three phases on Downloads/Documents/home: inventory
  scan, Chinese organization plan, then safe moves with manifest after explicit
  user approval. Use when hub routes here for 清理下载, Downloads cleanup, sort
  documents, or file organization workflows — not as a standalone hub entry.
---

# Mac 文件整理

三阶段交互流程：**扫描 → 计划 → 执行**。全程用中文与用户沟通。

## 触发与开场

用户未给出具体指令时，先说明即将扫描以下默认路径（可写入配置 JSON）：

- `~/Downloads`
- `~/Documents`
- `~`（仅顶层，排除系统/隐藏目录）

数据目录默认：`~/.cursor/file-organizer/`（`inventory.json`、`plan.json`、`manifest.json`）。

## 阶段 1：SCAN

1. 确认扫描路径；用户指定路径则覆盖默认。
2. 运行扫描脚本（或等效逻辑）：

```bash
zsh ~/.cursor/skills/guanjun-skill-hub/organize-files/scripts/file-organizer-scan.sh
# 或：zsh ~/guanjun_skill/organize-files/scripts/file-organizer-scan.sh
# 自定义路径：
zsh ~/.cursor/skills/guanjun-skill-hub/organize-files/scripts/file-organizer-scan.sh ~/Downloads ~/Desktop
```

3. 读取 `~/.cursor/file-organizer/inventory.json`，向用户摘要：
   - 扫描时间与路径
   - 顶层条目数量、总大小
   - 文件类型分布
   - 建议分类统计
   - 已标记跳过的项目（`.git`、云同步根目录、Office 临时文件等）

**不要**在本阶段移动或删除任何文件。

## 阶段 2：PLAN

1. 运行计划草案脚本（可选，基于 inventory 生成分类建议）：

```bash
zsh ~/.cursor/skills/guanjun-skill-hub/organize-files/scripts/file-organizer-plan.sh
```

2. 生成**中文可读**整理计划，包含：

| 区块 | 内容 |
|------|------|
| 目标结构 | 拟建/使用的文件夹树 |
| 移动清单 | 源路径 → 目标路径（按分类分组） |
| 大文件 | >100MB 的项目单独列出 |
| 跳过项 | 及原因 |
| 冲突 | 目标已存在同名文件时的处理（追加序号） |

3. **必须等待用户明确批准**后再进入阶段 3，除非用户事先说了「自动执行」「直接整理」「execute」等。

计划模板见 [reference.md](reference.md#计划输出模板)。

## 阶段 3：EXECUTE

仅在用户批准后执行。

安全规则：

- 只用 `mv`，**禁止** `rm` 删除用户文件
- 先 `mkdir -p` 目标目录
- 同名冲突：目标追加 `_1`、`_2`…，写入 manifest
- 每条操作记录到 `~/.cursor/file-organizer/manifest.json`
- 云同步根目录（如 `同步空间`）、`.git`、`node_modules`、Office 锁文件（`~$*`）不移动
- 执行后汇报：成功数、跳过数、冲突处理、manifest 路径

```bash
# 用户批准后将 plan.json 中 approved 设为 true，再执行：
zsh ~/.cursor/skills/guanjun-skill-hub/organize-files/scripts/file-organizer-execute.sh
```

## 分类启发式（摘要）

优先匹配用户已有结构；完整规则见 [reference.md](reference.md#分类规则)。

| 信号 | 目标 |
|------|------|
| NeRF/CryoSplat/项目名、代码仓库 | `Documents/博士相关资料/研究项目` 或 `Downloads/_整理/02_代码与项目` |
| 组会/slide/poster/汇报 | `组会报告` 或 `_整理/03_汇报演示` |
| 论文/PDF/文献/bib | `文献笔记` 或 `_整理/01_论文文献` |
| 报销/入党/行政/实习说明 | `行政出差` 或 `_整理/07_行政事务` |
| 课程/homework/lecture | `_整理/08_课程学习` |
| `.dmg/.pkg/.exe/.msi` | `_整理/06_软件安装包` |
| 图片/视频/截图 | `_整理/04_图片与视频` |
| `.crdownload/.part/.download` | `_整理/09_未完成下载` |

PDF/PPT 按**文件名关键词**二次分类；不确定的放入 `_整理/11_临时杂项` 并在计划中标注待确认。

## 配置

可选 `~/.cursor/file-organizer/config.json`：

```json
{
  "scan_paths": ["~/Downloads", "~/Documents", "~"],
  "data_dir": "~/.cursor/file-organizer",
  "phd_root": "~/Documents/博士相关资料",
  "downloads_staging": "~/Downloads/_整理",
  "size_alert_mb": 100
}
```

## 渐进式参考

- JSON schema、跳过规则、完整关键词表：[reference.md](reference.md)
- 示例对话：[examples.md](examples.md)

## 注意事项

- 首次使用或用户说「只扫描」时，仅完成阶段 1
-  home 目录只扫描顶层；不对 `Library/`、`Applications/` 等系统目录递归
- 用户已有 `_整理/` 或 `博士相关资料/` 结构时，优先沿用而非重建
