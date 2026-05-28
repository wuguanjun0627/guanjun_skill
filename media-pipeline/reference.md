# 媒体生成 — 配置与排错

## Private 密钥仓库（仅所有者）

真实 API Key 不在 `guanjun_skill` 公开代码中，而存放在 **private 仓库**：

- 仓库：`wuguanjun0627/guanjun-skill-secrets`
- 文件：`ai-media.env`
- 本地路径：`~/.config/ai-media/.env`

```bash
# 前置：brew install gh && gh auth login  （账号 wuguanjun0627）
~/guanjun_skill/media-pipeline/scripts/pull_env.sh
```

其他人 clone `guanjun_skill` 后执行 `pull_env.sh` 会返回 **404 / 无权限**；只有仓库所有者（你）能拉取并正常使用生图/生视频脚本。

更新本地 Key 后同步回 GitHub：

```bash
~/guanjun_skill/media-pipeline/scripts/push_env.sh "update keys"
```

各 `gen_*.sh` 在检测到占位符 Key 时会自动尝试 `pull_env.sh`。

---

## 火山方舟文生图（Seedream）

### 使用示例

```bash
chmod +x ~/guanjun_skill/media-pipeline/scripts/gen_ark_image.sh

~/guanjun_skill/media-pipeline/scripts/gen_ark_image.sh \
  --prompt "星际穿越，黑洞，快支离破碎的复古列车冲出黑洞，电影大片，超现实主义" \
  --size 2K
```

API：`POST {ARK_BASE_URL}/images/generations`，模型默认 `doubao-seedream-5-0-260128`，`response_format=url`，脚本自动下载。

### 常见错误（文生图）

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| 401 | Key 无效 | 更新 `ARK_API_KEY` |
| 403 | 未开通 Seedream 或欠费 | 控制台开通模型、充值 |

---

## 火山方舟图生视频 / 文生视频

### 你需要准备什么

1. **方舟 API Key（按量付费）**
   - 登录 [火山方舟控制台](https://console.volcengine.com/ark) → **API Key 管理** 创建
   - 写入 `~/.config/ai-media/.env`：`ARK_API_KEY=ark-...`
   - **注意**：Coding Plan / Agent Plan 的 Key 与 Base URL **不能**用于 `gen_video.sh`；本脚本走标准 `/api/v3/contents/generations/tasks`

2. **开通模型**
   - 控制台开通 **Seedance**（如 `doubao-seedance-1-5-pro-251215`）
   - 按 Token 后付费；单次 5s 720p 约消耗 10 万+ completion tokens（以控制台为准）

3. **网络**
   - 国内直连 `ark.cn-beijing.volces.com` 通常可用，**一般不需要代理**

### 使用示例

```bash
chmod +x ~/guanjun_skill/media-pipeline/scripts/gen_video.sh

# 图生视频（首帧 URL）
~/guanjun_skill/media-pipeline/scripts/gen_video.sh \
  --prompt "无人机以极快速度穿越复杂障碍，沉浸式飞行体验" \
  --image "https://ark-project.tos-cn-beijing.volces.com/doc_image/seepro_i2v.png" \
  --duration 5

# 图生视频（本地首帧）
~/guanjun_skill/media-pipeline/scripts/gen_video.sh \
  --prompt "人物缓缓转头，电影感光影" \
  --image ~/Pictures/frame.png \
  --duration 5 \
  --ratio 9:16

# 文生视频
~/guanjun_skill/media-pipeline/scripts/gen_video.sh \
  --prompt "海浪拍打礁石，慢镜头" \
  --duration 5

# 只拿在线 URL，不下载
~/guanjun_skill/media-pipeline/scripts/gen_video.sh \
  --prompt "..." --image "..." --url-only
```

成功时 stdout 一行本地 mp4 路径；stderr 含任务 ID、轮询状态、24h 有效预览 URL。

### API 流程（脚本已实现）

1. `POST {ARK_BASE_URL}/contents/generations/tasks` — 创建任务，返回 `id`
2. `GET .../tasks/{id}` — 轮询至 `status=succeeded`
3. 从 `content.video_url` 下载 mp4

提示词参数通过 text 字段后缀传递，例如：`...  --duration 5 --camerafixed false --watermark true`

### 常见错误（视频）

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| 401 | Key 无效 | 更新 `ARK_API_KEY` |
| 403 | 未开通 Seedance 或欠费 | 控制台开通模型、充值 |
| 任务 failed | 图片 URL 不可达或 prompt 违规 | 换可公网访问的图片或改 prompt |
| 下载失败 | 签名 URL 过期（24h） | 用 `--url-only` 及时下载 |
| 用了 Coding Plan Key | Base URL 不对 | 必须用按量 API Key + 本脚本默认 URL |

---

## OpenAI 文生图 — 国内访问与排错

## 国内访问指南

### 你需要准备什么

1. **OpenAI API Key**
   - 在 [platform.openai.com](https://platform.openai.com) 注册并创建 API Key。
   - 通常需要**海外支付方式**（信用卡等）和可接收验证的联系方式；国内银行卡/手机号可能无法完成注册或充值。
   - 密钥只保存在本机 `~/.config/ai-media/.env`，**不要**写入 git 或发给他人。

2. **可访问 OpenAI 的网络**
   - 直连 `api.openai.com` 在国内多数情况下不可用或不稳定。
   - 推荐在本机运行 **Clash / V2Ray / Surge** 等，本地监听 `127.0.0.1:7890`（端口以你的客户端为准）。

3. **运行前设置代理环境变量**

```bash
export https_proxy=http://127.0.0.1:7890
export http_proxy=http://127.0.0.1:7890
export all_proxy=socks5://127.0.0.1:7890
```

也可把上述三行写入 `~/.config/ai-media/.env`（与 API Key 同文件），`gen_image.py` 启动时会加载。

### 可选：API 中转（OPENAI_BASE_URL）

若使用**兼容 OpenAI 协议**的网关/中转服务，在 `.env` 中设置：

```bash
OPENAI_API_KEY=你的密钥
OPENAI_BASE_URL=https://你的网关域名/v1

# 国内直连中转时可不设代理；走官方则保留：
# https_proxy=http://127.0.0.1:7890
# http_proxy=http://127.0.0.1:7890
# all_proxy=socks5://127.0.0.1:7890
```

注意：

- 仅使用你信任的服务商；脚本**不会**内置任何第三方中转 URL。
- 本脚本走 **`/v1/images/generations`**，模型名为 `gpt-image-2` / `gpt-image-1`；与 OpenRouter 的 chat+modalities 图像接口**不兼容**。
- 费用与稳定性由服务商决定，与 OpenAI 官方定价可能不同。

#### 推荐中转（2026，按与 gen_image.py 兼容性）

| 方案 | Base URL 示例 | gpt-image-2 | 支付 | 适合 |
|------|---------------|-------------|------|------|
| OpenAI 官方 + 代理 | `https://api.openai.com/v1`（默认） | ✅ 原生 | 海外卡 | 生产 / 有官方账号 |
| Vercel AI Gateway | `https://ai-gateway.vercel.sh/v1` | ✅ 模型名可能为 `openai/gpt-image-2` | 信用卡 | 生产备选 |
| OpenRouter | `https://openrouter.ai/api/v1` | ⚠️ 仅 chat 图像，**不适配本脚本** | 信用卡/AliPay | Cursor 对话 / 多模型 |
| 自托管 New-API | `http://localhost:3000/v1` | 取决于上游渠道 | 自备上游 | 团队内网 |
| 国内 One-API 类中转 | 服务商提供 | 需实测 `images/generations` | 支付宝/微信 | 个人开发备用 |

**风险提醒**：第三方中转可能违反上游 ToS；请求内容经第三方；国内小站质量参差，勿预存大额；视频模型（Sora 2 API）官方将于 2026-09-24 下线，勿长期绑定单一逆向渠道。

### 费用参考（gpt-image-2）

- 计费以 OpenAI 官方 [Pricing](https://openai.com/api/pricing/) 与用量面板为准；`quality` 越高、`size` 越大，单次成本越高。
- 建议先用 `--quality medium` 或较小尺寸试跑，确认效果后再用 `high` 批量生成。
- 在 [Usage](https://platform.openai.com/usage) 查看余额与消费。

### 安全

- **切勿**将真实 `OPENAI_API_KEY` 提交到 `guanjun_skill` 或任何公开仓库。
- `.env` 仅保留在 `~/.config/ai-media/`。

---

## 安装与配置

```bash
pip install openai

mkdir -p ~/Projects/ai-media/output
mkdir -p ~/.config/ai-media

cp ~/guanjun_skill/media-pipeline/.env.example ~/.config/ai-media/.env
# 编辑 ~/.config/ai-media/.env，填入 OPENAI_API_KEY
```

---

## 使用示例

```bash
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

chmod +x ~/guanjun_skill/media-pipeline/scripts/gen_image.sh

~/guanjun_skill/media-pipeline/scripts/gen_image.sh \
  --prompt "Futuristic city at dusk, cinematic lighting" \
  --out ~/Projects/ai-media/output \
  --size 1024x1024 \
  --quality high
```

成功时终端输出一行绝对路径，例如：

```
/Users/wumozhou/Projects/ai-media/output/gen_20260529_143022.png
```

---

## 常见错误

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| 401 / invalid API key | Key 错误或过期 | 在平台重新生成 Key，更新 `.env` |
| 403 / forbidden | 无模型权限或欠费 | 检查账单、项目权限 |
| 连接超时 / connection error | 未开代理或代理端口不对 | 确认 Clash 规则与 `7890` 端口 |
| 地区限制 / unsupported country | IP 被识别为受限地区 | 换节点或使用中继 `OPENAI_BASE_URL` |
| model not found | 账户暂无 gpt-image-2 | 脚本会自动回退 `gpt-image-1` |

---

## 自测

在已配置 Key 且代理可用时：

```bash
~/guanjun_skill/media-pipeline/scripts/gen_image.sh \
  --prompt "A simple red apple on white background" \
  --quality low
```

若无 `~/.config/ai-media/.env` 或未设置 `OPENAI_API_KEY`，脚本会退出并提示配置路径，不会发起 API 请求。
