# OpenAI 文生图 — 国内访问与排错

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
OPENAI_BASE_URL=https://你的网关域名/v1
```

注意：

- 仅使用你信任的服务商；脚本**不会**内置任何第三方中转 URL。
- 中转需支持 `images/generations` 及 `gpt-image-2` 或 `gpt-image-1` 模型名。
- 费用与稳定性由服务商决定，与 OpenAI 官方定价可能不同。

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
