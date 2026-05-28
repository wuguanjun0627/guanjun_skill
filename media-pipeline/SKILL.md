---
name: media-pipeline
description: >-
  OpenAI text-to-image sub-skill (gpt-image-2) via guanjun-skill-hub. Generates
  images with official Python SDK, proxy-friendly for China users. Use when hub
  routes here for 文生图, OpenAI 生图, generate image, gpt-image, or AI image
  generation from a text prompt.
---

# OpenAI 文生图（media-pipeline）

通过 OpenAI **gpt-image-2**（失败时回退 **gpt-image-1**）从文本生成图片。面向国内用户：依赖本地代理或 `OPENAI_BASE_URL` 中转。

## 前置条件

1. `pip install openai`（Python 3.10+）
2. API Key：写入 `~/.config/ai-media/.env`（见 [.env.example](.env.example)）
3. 国内直连：运行前设置代理（见 [reference.md](reference.md#国内访问指南)）

```bash
mkdir -p ~/Projects/ai-media/output ~/.config/ai-media
cp ~/guanjun_skill/media-pipeline/.env.example ~/.config/ai-media/.env
# 编辑 .env，填入 OPENAI_API_KEY
```

## 快速使用

```bash
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

~/guanjun_skill/media-pipeline/scripts/gen_image.sh \
  --prompt "一只在窗台晒太阳的橘猫，水彩风格" \
  --size 1024x1024 \
  --quality high
```

默认输出目录：`~/Projects/ai-media/output/`。成功时脚本打印保存路径。

## Agent 工作流

1. 确认 `~/.config/ai-media/.env` 存在且含 `OPENAI_API_KEY`；无则引导用户配置，**不要**提交真实密钥到 git
2. 若用户在国内，提醒设置代理或 `OPENAI_BASE_URL`
3. 执行 `scripts/gen_image.sh`（或 `python3 scripts/gen_image.py`），将 `--prompt` 设为用户描述
4. 将输出图片路径告知用户；失败时根据 stderr 对照 [reference.md](reference.md#常见错误)

## 脚本参数

| 参数 | 说明 | 默认 |
|------|------|------|
| `--prompt` | 英文或中文提示词（必填） | — |
| `--out` | 输出目录 | `~/Projects/ai-media/output/` |
| `--size` | 如 `1024x1024`、`1536x1024` | `1024x1024` |
| `--quality` | `low` / `medium` / `high` | `high` |

## 参考

- 国内访问、费用、中转模式：[reference.md](reference.md)
- 环境变量模板：[.env.example](.env.example)
