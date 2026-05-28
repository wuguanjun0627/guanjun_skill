# 示例对话

## 示例 1：完整三阶段

**用户**：帮我整理一下电脑文件

**Agent**：
即将扫描以下常见文件夹：`~/Downloads`、`~/Documents`、`~`（仅顶层）。扫描结果将保存到 `~/.cursor/file-organizer/inventory.json`。是否开始？

**用户**：开始

**Agent**：（运行 scan）扫描完成：Downloads 8 项、Documents 23 项、Home 15 项；建议将 5 个 PDF 归入论文文献、2 个 dmg 归入软件安装包…

**Agent**：（输出中文计划）…请确认是否执行。

**用户**：确认执行

**Agent**：（运行 execute）已完成 7 项移动，跳过 3 项（云同步目录等）。操作日志：`~/.cursor/file-organizer/manifest.json`

## 示例 2：仅扫描

**用户**：只扫描 Downloads，不要移动

**Agent**：好的，仅执行扫描阶段…（不进入 PLAN/EXECUTE）

## 示例 3：自动执行

**用户**：直接整理 Downloads，自动执行

**Agent**：收到，扫描后将生成简要计划并立即执行（跳过确认步骤）…
