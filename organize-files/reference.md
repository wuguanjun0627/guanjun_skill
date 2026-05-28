# 文件整理参考

## inventory.json Schema

```json
{
  "scanned_at": "2026-05-29T12:00:00+08:00",
  "scan_paths": ["/Users/wumozhou/Downloads", "/Users/wumozhou/Documents", "/Users/wumozhou"],
  "config": {
    "phd_root": "/Users/wumozhou/Documents/博士相关资料",
    "downloads_staging": "/Users/wumozhou/Downloads/_整理"
  },
  "top_level_items": [
    {
      "path": "/Users/wumozhou/Downloads/example.pdf",
      "name": "example.pdf",
      "parent": "/Users/wumozhou/Downloads",
      "type": "file",
      "size_bytes": 1048576,
      "extension": ".pdf",
      "modified_at": "2026-05-28T10:00:00+08:00",
      "suggested_category": "01_论文文献",
      "suggested_target": "/Users/wumozhou/Downloads/_整理/01_论文文献",
      "skip": false,
      "skip_reason": null
    }
  ],
  "summary": {
    "total_items": 42,
    "total_size_bytes": 1073741824,
    "skipped_count": 5,
    "file_type_counts": { ".pdf": 12, ".dmg": 3, ".pptx": 5 },
    "suggested_categories": { "01_论文文献": 12, "06_软件安装包": 3 }
  }
}
```

## plan.json Schema

```json
{
  "created_at": "2026-05-29T12:05:00+08:00",
  "approved": false,
  "approved_at": null,
  "moves": [
    {
      "source": "/Users/wumozhou/Downloads/foo.pdf",
      "target": "/Users/wumozhou/Downloads/_整理/01_论文文献/foo.pdf",
      "category": "01_论文文献",
      "reason": "PDF 文件名含 paper 关键词",
      "size_bytes": 1048576,
      "status": "pending"
    }
  ],
  "skips": [
    {
      "path": "/Users/wumozhou/Downloads/同步空间",
      "reason": "云同步根目录"
    }
  ],
  "conflicts": [],
  "large_items": []
}
```

## manifest.json Schema

```json
{
  "executed_at": "2026-05-29T12:10:00+08:00",
  "plan_file": "/Users/wumozhou/.cursor/file-organizer/plan.json",
  "actions": [
    {
      "timestamp": "2026-05-29T12:10:01+08:00",
      "action": "move",
      "source": "/Users/wumozhou/Downloads/foo.pdf",
      "target": "/Users/wumozhou/Downloads/_整理/01_论文文献/foo.pdf",
      "status": "success"
    },
    {
      "timestamp": "2026-05-29T12:10:02+08:00",
      "action": "move",
      "source": "/Users/wumozhou/Downloads/bar.pdf",
      "target": "/Users/wumozhou/Downloads/_整理/01_论文文献/bar_1.pdf",
      "status": "success",
      "note": "name conflict resolved"
    }
  ],
  "summary": {
    "success": 10,
    "skipped": 2,
    "failed": 0
  }
}
```

## 跳过规则

| 类型 | 模式 | 原因 |
|------|------|------|
| 隐藏系统 | `~/Library`, `~/Applications`, `~/.Trash`, `~/.cache` | 系统目录 |
| 版本控制 | `.git`, `node_modules`, `.venv`, `__pycache__` | 项目内部结构 |
| 云同步 | `同步空间`, `iCloud`, `OneDrive`, `Dropbox`, `.icloud` | 同步根目录 |
| Office 临时 | `~$*`, `.~lock*`, `*.tmp`（Office） | 临时/锁文件 |
| 已整理 | `Downloads/_整理`, 已在目标树内 | 避免重复移动 |
| 点文件 | `~` 下以 `.` 开头的顶层项 | 配置/隐藏目录 |

home 扫描仅顶层；`Downloads`/`Documents` 也仅顶层条目。

## 分类规则

### Downloads/_整理 编号分类

| 编号 | 文件夹 | 扩展名/关键词 |
|------|--------|---------------|
| 01 | 论文文献 | `.pdf`, paper, arxiv, bib, thesis, 文献, 论文 |
| 02 | 代码与项目 | `.py`, `.js`, `.zip`（含 code/repo）, NeRF, splat, github |
| 03 | 汇报演示 | `.ppt`, `.pptx`, `.key`, poster, slide, 组会, 汇报 |
| 04 | 图片与视频 | `.jpg`, `.png`, `.mp4`, `.mov`, `.gif`, 截图 |
| 05 | 文档表格 | `.doc`, `.docx`, `.xls`, `.xlsx`, `.csv`, `.txt`, `.md` |
| 06 | 软件安装包 | `.dmg`, `.pkg`, `.exe`, `.msi`, `.app`（独立安装包） |
| 07 | 行政事务 | 报销, 入党, 行政, 实习, 签章, 合同 |
| 08 | 课程学习 | 课程, homework, lecture, 作业, 考试 |
| 09 | 未完成下载 | `.crdownload`, `.part`, `.download`, `.tmp`（下载中） |
| 10 | 个人与生活 | 简历, resume, 签证, 证件 |
| 11 | 临时杂项 | 无法分类 |

### Documents/博士相关资料 子文件夹

| 子文件夹 | 关键词/用途 |
|----------|-------------|
| 研究项目 | NeRF, CryoSplat, unilat3d, 项目代码/数据 |
| 组会报告 | 组会, meeting, weekly, slide |
| 文献笔记 | paper, survey, reading, bib |
| 投稿审稿 | TPAMI, TVCG, CVPR, rebuttal, proof, 投稿 |
| 开题 | 开题, proposal |
| 实验数据 | 实验, dataset, result |
| 行政出差 | 报销, 出差, China3DV |
| 刚哥的材料 等具名文件夹 | 保持原名，不自动合并 |

**路由逻辑**：Downloads 散落文件 → `_整理/`；已识别为博士/研究内容 → `Documents/博士相关资料/` 对应子目录。

## 计划输出模板

```markdown
# 文件整理计划

**扫描时间**：…
**涉及路径**：…

## 目标文件夹结构
- Downloads/_整理/01_论文文献（新建/已有）
- Documents/博士相关资料/研究项目（已有）

## 移动清单（共 N 项）

### 论文文献（12 项）
| 文件 | 大小 | 目标 |
|------|------|------|
| foo.pdf | 2.1 MB | _整理/01_论文文献/ |

## 大文件（>100 MB）
- …

## 跳过项
- 同步空间/ — 云同步根目录

## 冲突处理
- bar.pdf → bar_1.pdf（目标已存在）

---
请确认是否执行。回复「确认执行」或说明需调整的项目。
```

## 冲突处理

1. 目标不存在 → 直接 `mv`
2. 目标存在且为同名文件 → 追加 `_1`, `_2`, …
3. 目标存在且为目录、源也是目录 → 不自动合并；在计划中标注，需用户确认
