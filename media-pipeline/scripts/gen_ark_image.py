#!/usr/bin/env python3
"""Volcano Engine Ark text-to-image via Seedream."""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime
from pathlib import Path
from urllib.parse import urlparse

DEFAULT_OUT = Path.home() / "Projects" / "ai-media" / "output"
CONFIG_ENV = Path.home() / ".config" / "ai-media" / ".env"
DEFAULT_BASE_URL = "https://ark.cn-beijing.volces.com/api/v3"
DEFAULT_MODEL = "doubao-seedream-5-0-260128"
IMAGES_PATH = "/images/generations"


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
        description="Generate image with Volcano Engine Ark Seedream API."
    )
    parser.add_argument("--prompt", required=True, help="Image description")
    parser.add_argument(
        "--model",
        default=DEFAULT_MODEL,
        help=f"Model id (default: {DEFAULT_MODEL})",
    )
    parser.add_argument("--size", default="2K", help="Image size, e.g. 2K, 1024x1024")
    parser.add_argument(
        "--sequential-image-generation",
        default="disabled",
        choices=["disabled", "auto"],
        help="Sequential generation mode (default: disabled)",
    )
    parser.add_argument(
        "--no-watermark",
        action="store_true",
        help="Disable watermark (default: watermark on)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT})",
    )
    parser.add_argument(
        "--url-only",
        action="store_true",
        help="Print image URL only, do not download",
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


def api_request(url: str, api_key: str, payload: dict) -> dict:
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
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
            "权限被拒 (403): 账号无该模型权限或未开通图片生成。\n"
            "  在火山方舟控制台确认已开通 Seedream 并按量计费。"
        )
    if code == 429:
        return "请求过于频繁 (429): 请稍后重试。"
    return f"API 错误 ({code}): {detail}"


def guess_extension(url: str) -> str:
    path = urlparse(url).path.lower()
    for ext in (".jpeg", ".jpg", ".png", ".webp"):
        if path.endswith(ext):
            return ext
    return ".jpeg"


def download_image(image_url: str, out_dir: Path) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    out_path = out_dir / f"ark_{ts}{guess_extension(image_url)}"
    req = urllib.request.Request(image_url, method="GET")
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            out_path.write_bytes(resp.read())
    except urllib.error.URLError as exc:
        print(f"错误: 下载图片失败 ({exc.reason})", file=sys.stderr)
        print(f"  图片 URL（24h 内有效）: {image_url}", file=sys.stderr)
        sys.exit(1)
    return out_path


def main() -> int:
    load_dotenv(CONFIG_ENV)
    args = parse_args()
    api_key, base_url = get_config()

    payload = {
        "model": args.model,
        "prompt": args.prompt,
        "sequential_image_generation": args.sequential_image_generation,
        "response_format": "url",
        "size": args.size,
        "stream": False,
        "watermark": not args.no_watermark,
    }

    result = api_request(f"{base_url}{IMAGES_PATH}", api_key, payload)
    data = result.get("data") or []
    if not data or not data[0].get("url"):
        print(f"错误: API 未返回图片 URL: {result}", file=sys.stderr)
        sys.exit(1)

    image_url = data[0]["url"]
    usage = result.get("usage")
    if usage:
        print(f"用量: {json.dumps(usage, ensure_ascii=False)}", file=sys.stderr)
    if data[0].get("size"):
        print(f"尺寸: {data[0]['size']}", file=sys.stderr)

    if args.url_only:
        print(image_url)
        return 0

    out_path = download_image(image_url, args.out.expanduser().resolve())
    print(str(out_path))
    print(f"在线预览（24h 内有效）: {image_url}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
