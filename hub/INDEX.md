# Skill Registry

一行触发 → 子技能路径。Hub 加载后读此表做路由；**不要**在此文件写执行细节。

| 触发词 / 场景 | 路径 | 说明 |
|---------------|------|------|
| 整理文件、清理下载、organize files、clean up Downloads、sort documents、文件整理、扫描 Downloads/Documents | [organize-files/](../organize-files/) | macOS 三阶段文件整理：扫描 → 中文计划 → 用户批准后安全移动 |
| 文生图、OpenAI 生图、generate image、gpt-image、AI 画图、文本生成图片 | [media-pipeline/](../media-pipeline/) | OpenAI gpt-image-2 文生图脚本；国内需代理或 OPENAI_BASE_URL 中转 |

## 路由说明

1. 用户消息与上表「触发词」任一匹配 → 进入对应路径
2. 进入路径后读取该目录 `SKILL.md`，按子技能流程执行
3. 多技能同时匹配时，优先最具体的一项；仍 ambiguous 则向用户确认

## 维护

新增子技能：新建 `/<skill-name>/SKILL.md`，在本表追加一行，Hub 的 `SKILL.md` description 可酌情加入新触发词。
