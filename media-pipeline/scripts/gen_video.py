#!/usr/bin/env python3
"""Volcano Engine Ark image/text-to-video via Seedance (async task + poll + download)."""

from __future__ import annotations

import argparse
import base64
import json
import mimetypes
import os
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path

DEFAULT_OUT = Path.home() / "Projects" / "ai-media" / "output"
CONFIG_ENV = Path.home() / ".config" / "ai-media" / ".env"
DEFAULT_BASE_URL = "https://ark.cn-beijing.volces.com/api/v3"
DEFAULT_MODEL = "doubao-seedance-1-5-pro-251215"
TASKS_PATH = "/contents/generations/tasks"


def load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        key = key.strip()
        value = value.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = value


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate video with Volcano Engine Ark Seedance API."
    )
    parser.add_argument("--prompt", required=True, help="Video description (Chinese or English)")
    parser.add_argument(
        "--image",
        help="First frame: local path or https URL (omit for text-to-video)",
    )
    parser.add_argument("--model", default=DEFAULT_MODEL, help=f"Model id (default: {DEFAULT_MODEL})")
    parser.add_argument("--duration", type=int, default=5, help="Duration in seconds (default: 5)")
    parser.add_argument(
        "--camerafixed",
        action="store_true",
        help="Keep camera fixed (default: false)",
    )
    parser.add_argument(
        "--no-watermark",
        action="store_true",
        help="Disable watermark (default: watermark on)",
    )
    parser.add_argument("--ratio", default="", help="Aspect ratio, e.g. 16:9, 9:16, adaptive")
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT})",
    )
    parser.add_argument("--poll-interval", type=int, default=10, help="Poll interval seconds")
    parser.add_argument("--timeout", type=int, default=600, help="Max wait seconds")
    parser.add_argument(
        "--url-only",
        action="store_true",
        help="Print video URL only, do not download",
    )
    return parser.parse_args()


def get_config() -> tuple[str, str]:
    api_key = os.environ.get("ARK_API_KEY", "").strip()
    if not api_key:
        print(
            "错误: 未设置 ARK_API_KEY。\n"
            f"  请复制 media-pipeline/.env.example 到 {CONFIG_ENV} 并填入密钥，\n"
            "  或执行: export ARK_API_KEY=ark-...",
            file=sys.stderr,
        )
        sys.exit(1)
    base_url = os.environ.get("ARK_BASE_URL", DEFAULT_BASE_URL).rstrip("/")
    return api_key, base_url


def build_prompt_text(args: argparse.Namespace) -> str:
    text = args.prompt.rstrip()
    suffix = f"  --duration {args.duration} --camerafixed {'true' if args.camerafixed else 'false'}"
    suffix += f" --watermark {'false' if args.no_watermark else 'true'}"
    if args.ratio:
        suffix += f" --ratio {args.ratio}"
    return text + suffix


def resolve_image_url(image: str) -> str:
    if image.startswith(("http://", "https://")):
        return image
    path = Path(image).expanduser().resolve()
    if not path.is_file():
        print(f"错误: 图片不存在: {path}", file=sys.stderr)
        sys.exit(1)
    mime, _ = mimetypes.guess_type(str(path))
    mime = mime or "image/png"
    encoded = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:{mime};base64,{encoded}"


def api_request(
    method: str,
    url: str,
    api_key: str,
    payload: dict | None = None,
) -> dict:
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    data = None
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            body = resp.read().decode("utf-8")
            return json.loads(body) if body else {}
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        print(classify_http_error(exc.code, detail), file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as exc:
        print(
            f"网络错误: 无法连接火山方舟 API ({exc.reason})。\n"
            "  请检查网络；国内一般无需代理。",
            file=sys.stderr,
        )
        sys.exit(1)


def classify_http_error(code: int, detail: str) -> str:
    if code == 401:
        return (
            "认证失败 (401): ARK_API_KEY 无效或未设置。\n"
            f"  检查 {CONFIG_ENV} 中的 ARK_API_KEY。"
        )
    if code == 403:
        return (
            "权限被拒 (403): 账号无该模型权限或未开通视频生成。\n"
            "  在火山方舟控制台确认已开通 Seedance 并按量计费。"
        )
    if code == 429:
        return "请求过于频繁 (429): 请稍后重试。"
    return f"API 错误 ({code}): {detail}"


def create_task(base_url: str, api_key: str, model: str, content: list[dict]) -> str:
    url = f"{base_url}{TASKS_PATH}"
    payload = {"model": model, "content": content}
    result = api_request("POST", url, api_key, payload)
    task_id = result.get("id")
    if not task_id:
        print(f"错误: 创建任务失败，响应: {result}", file=sys.stderr)
        sys.exit(1)
    print(f"任务已创建: {task_id}", file=sys.stderr)
    return task_id


def poll_task(base_url: str, api_key: str, task_id: str, interval: int, timeout: int) -> dict:
    url = f"{base_url}{TASKS_PATH}/{task_id}"
    deadline = time.time() + timeout
    while time.time() < deadline:
        result = api_request("GET", url, api_key)
        status = result.get("status", "")
        print(f"状态: {status}", file=sys.stderr)
        if status == "succeeded":
            return result
        if status in ("failed", "cancelled", "expired"):
            print(f"错误: 任务 {status}: {json.dumps(result, ensure_ascii=False)}", file=sys.stderr)
            sys.exit(1)
        time.sleep(interval)
    print(f"错误: 等待超时 ({timeout}s)，任务 ID: {task_id}", file=sys.stderr)
    sys.exit(1)


def download_video(video_url: str, out_dir: Path) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = out_dir / f"video_{ts}.mp4"
    req = urllib.request.Request(video_url, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            out_path.write_bytes(resp.read())
    except urllib.error.URLError as exc:
        print(f"错误: 下载视频失败 ({exc.reason})", file=sys.stderr)
        print(f"  视频 URL（24h 内有效）: {video_url}", file=sys.stderr)
        sys.exit(1)
    return out_path


def extract_video_url(result: dict) -> str:
    content = result.get("content") or {}
    video_url = content.get("video_url")
    if not video_url:
        print(f"错误: 任务成功但未返回 video_url: {result}", file=sys.stderr)
        sys.exit(1)
    return video_url


def main() -> int:
    load_dotenv(CONFIG_ENV)
    args = parse_args()
    api_key, base_url = get_config()

    content: list[dict] = [{"type": "text", "text": build_prompt_text(args)}]
    if args.image:
        content.append(
            {
                "type": "image_url",
                "image_url": {"url": resolve_image_url(args.image)},
            }
        )

    task_id = create_task(base_url, api_key, args.model, content)
    result = poll_task(base_url, api_key, task_id, args.poll_interval, args.timeout)
    video_url = extract_video_url(result)

    usage = result.get("usage")
    if usage:
        print(f"用量: {json.dumps(usage, ensure_ascii=False)}", file=sys.stderr)

    if args.url_only:
        print(video_url)
        return 0

    out_path = download_video(video_url, args.out.expanduser().resolve())
    print(str(out_path))
    print(f"在线预览（24h 内有效）: {video_url}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
