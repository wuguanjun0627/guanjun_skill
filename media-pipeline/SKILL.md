---
name: media-pipeline
description: >-
  OpenAI text-to-image, Volcano Seedream image, and Seedance video generation sub-skill
  via guanjun-skill-hub. Use when hub routes here for 文生图, 图生视频, 文生视频,
  seedream, seedance, 火山生图, OpenAI 生图, generate image/video, gpt-image, i2v,
  t2v, or AI media generation from text and optional image.
---



# 媒体生成（media-pipeline）


| 脚本                 | 能力          | API                |
| ------------------ | ----------- | ------------------ |
| `gen_ark_image.sh` | 文生图（国内推荐）   | 火山方舟 Seedream      |
| `gen_image.sh`     | 文生图         | OpenAI gpt-image-2 |
| `gen_video.sh`     | 文生视频 / 图生视频 | 火山方舟 Seedance      |


## 前置条件

1. Python 3.10+（火山脚本仅用标准库；OpenAI 生图需 `pip install openai`）
2. **`gh` CLI 已登录** `wuguanjun0627`（用于从 private 仓库拉取密钥）
3. 配置 `~/.config/ai-media/.env`（见下方「Private 密钥同步」或 [.env.example](.env.example) 手动填写）
4. OpenAI 生图：国内需代理或 `OPENAI_BASE_URL`（见 [reference.md](reference.md#openai-文生图--国内访问与排错)）
5. 火山生图/视频：需方舟 **按量付费 API Key**（`ARK_API_KEY`），**不是** Coding Plan 的 Key

```bash
mkdir -p ~/Projects/ai-media/output ~/.config/ai-media
chmod +x ~/guanjun_skill/media-pipeline/scripts/*.sh

# 推荐：从 private 仓库拉取（仅仓库所有者可成功）
~/guanjun_skill/media-pipeline/scripts/pull_env.sh
```

## Private 密钥同步（仅所有者）

API Key 存放在 **private 仓库** [`wuguanjun0627/guanjun-skill-secrets`](https://github.com/wuguanjun0627/guanjun-skill-secrets)（其他人 clone `guanjun_skill` 也**无法**读取该仓库）。

| 脚本 | 作用 |
|------|------|
| `pull_env.sh` | 拉取 `ai-media.env` → `~/.config/ai-media/.env` |
| `push_env.sh` | 本地 `.env` 更新后上传回 private 仓库 |
| `ensure_env.sh` | 被各 `gen_*.sh` 自动调用；本地无有效 Key 时尝试 `pull_env.sh` |

```bash
# 拉取（需 gh auth login 为 wuguanjun0627）
~/guanjun_skill/media-pipeline/scripts/pull_env.sh

# 本地改完 key 后上传
~/guanjun_skill/media-pipeline/scripts/push_env.sh "update ARK key"
```

**Agent 工作流**：执行任何 `gen_*.sh` 前，若 `~/.config/ai-media/.env` 不存在或仍为占位符，**先运行** `pull_env.sh`；失败则提示用户手动配置，**禁止**把真实 Key 写入 `guanjun_skill` 仓库。

## 火山文生图（Seedream，国内推荐）

**Agent 应直接调用：**

```bash
~/guanjun_skill/media-pipeline/scripts/gen_ark_image.sh \
  --prompt "星际穿越，黑洞里冲出支离破碎的复古列车，电影大片，超现实主义" \
  --size 2K
```

默认输出：`~/Projects/ai-media/output/ark_YYYYMMDD_HHMMSS.jpeg`。成功时 stdout 打印本地路径。

### gen_ark_image.sh 参数


| 参数                              | 说明                  | 默认                            |
| ------------------------------- | ------------------- | ----------------------------- |
| `--prompt`                      | 提示词（必填）             | —                             |
| `--model`                       | 方舟模型 ID             | `doubao-seedream-5-0-260128`  |
| `--size`                        | 如 `2K`、`1024x1024`  | `2K`                          |
| `--sequential-image-generation` | `disabled` / `auto` | `disabled`                    |
| `--no-watermark`                | 关闭水印                | 默认有水印                         |
| `--out`                         | 输出目录                | `~/Projects/ai-media/output/` |
| `--url-only`                    | 只输出在线 URL，不下载       | 否                             |


## 图生视频 / 文生视频

**Agent 应直接调用：**

```bash
~/guanjun_skill/media-pipeline/scripts/gen_video.sh \
  --prompt "无人机以极快速度穿越复杂障碍，沉浸式飞行体验" \
  --image "https://example.com/frame.png" \
  --duration 5
```

文生视频（不传 `--image`）：

```bash
~/guanjun_skill/media-pipeline/scripts/gen_video.sh \
  --prompt "日落时分的城市天际线，镜头缓慢推进" \
  --duration 5 \
  --ratio 16:9
```

默认输出：`~/Projects/ai-media/output/video_YYYYMMDD_HHMMSS.mp4`。成功时 stdout 打印本地路径。

### gen_video.sh 参数


| 参数                | 说明                           | 默认                               |
| ----------------- | ---------------------------- | -------------------------------- |
| `--prompt`        | 视频描述（必填）                     | —                                |
| `--image`         | 首帧图：本地路径或 https URL；省略则为文生视频 | —                                |
| `--model`         | 方舟模型 ID                      | `doubao-seedance-1-5-pro-251215` |
| `--duration`      | 时长（秒）                        | `5`                              |
| `--camerafixed`   | 固定镜头                         | 否                                |
| `--no-watermark`  | 关闭水印                         | 默认有水印                            |
| `--ratio`         | 宽高比，如 `16:9`、`9:16`          | 模型默认                             |
| `--out`           | 输出目录                         | `~/Projects/ai-media/output/`    |
| `--poll-interval` | 轮询间隔（秒）                      | `10`                             |
| `--timeout`       | 最长等待（秒）                      | `600`                            |
| `--url-only`      | 只输出在线 URL，不下载                | 否                                |


## OpenAI 文生图

```bash
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

~/guanjun_skill/media-pipeline/scripts/gen_image.sh \
  --prompt "一只在窗台晒太阳的橘猫，水彩风格" \
  --size 1024x1024 \
  --quality high
```


| 参数          | 说明                        | 默认                            |
| ----------- | ------------------------- | ----------------------------- |
| `--prompt`  | 提示词（必填）                   | —                             |
| `--out`     | 输出目录                      | `~/Projects/ai-media/output/` |
| `--size`    | 如 `1024x1024`             | `1024x1024`                   |
| `--quality` | `low` / `medium` / `high` | `high`                        |


## Agent 工作流

### 生成图片（火山，默认优先）

1. 若无有效 `ARK_API_KEY`，先执行 `scripts/pull_env.sh`
2. 执行 `scripts/gen_ark_image.sh`，传入 `--prompt`
3. 将本地路径告知用户；失败时对照 [reference.md](reference.md#火山方舟文生图-seedream)

### 生成图片（OpenAI）

1. 确认 `OPENAI_API_KEY`；国内提醒代理或中转
2. 执行 `scripts/gen_image.sh`
3. 将输出路径告知用户

### 生成视频

1. 若无有效 `ARK_API_KEY`，先执行 `scripts/pull_env.sh`
2. 执行 `scripts/gen_video.sh`，传入 `--prompt` 与用户提供的首帧图（`--image`）
3. 脚本自动：创建任务 → 轮询 → 下载 mp4；将本地路径告知用户
4. 失败时对照 [reference.md](reference.md#火山方舟图生视频--文生视频)

## 参考

- OpenAI 国内访问、中转、排错：[reference.md](reference.md)
- 环境变量模板：[.env.example](.env.example)

