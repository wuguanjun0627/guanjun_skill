#!/usr/bin/env python3
"""OpenAI text-to-image via gpt-image-2 (fallback gpt-image-1)."""

from __future__ import annotations

import argparse
import base64
import os
import sys
from datetime import datetime
from pathlib import Path

DEFAULT_OUT = Path.home() / "Projects" / "ai-media" / "output"
CONFIG_ENV = Path.home() / ".config" / "ai-media" / ".env"
MODEL_PRIMARY = "gpt-image-2"
MODEL_FALLBACK = "gpt-image-1"


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


def ensure_proxy_hint() -> None:
    if os.environ.get("https_proxy") or os.environ.get("HTTPS_PROXY"):
        return
    if os.environ.get("OPENAI_BASE_URL"):
        return


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Generate an image with OpenAI gpt-image models.")
    parser.add_argument("--prompt", required=True, help="Text description of the image")
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT})",
    )
    parser.add_argument("--size", default="1024x1024", help="Image size, e.g. 1024x1024")
    parser.add_argument(
        "--quality",
        default="high",
        choices=["low", "medium", "high"],
        help="Generation quality",
    )
    return parser.parse_args()


def build_client():
    try:
        from openai import OpenAI
    except ImportError:
        print("错误: 未安装 openai 包。请运行: pip install openai", file=sys.stderr)
        sys.exit(1)

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print(
            "错误: 未设置 OPENAI_API_KEY。\n"
            f"  请复制 media-pipeline/.env.example 到 {CONFIG_ENV} 并填入密钥，\n"
            "  或执行: export OPENAI_API_KEY=sk-...",
            file=sys.stderr,
        )
        sys.exit(1)

    kwargs: dict = {"api_key": api_key}
    base_url = os.environ.get("OPENAI_BASE_URL")
    if base_url:
        kwargs["base_url"] = base_url.rstrip("/")
    return OpenAI(**kwargs)


def generate_image(client, model: str, prompt: str, size: str, quality: str):
    return client.images.generate(
        model=model,
        prompt=prompt,
        size=size,
        quality=quality,
        n=1,
        response_format="b64_json",
    )


def save_image(b64_data: str, out_dir: Path) -> Path:
    out_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    path = out_dir / f"gen_{ts}.png"
    path.write_bytes(base64.b64decode(b64_data))
    return path


def classify_error(exc: Exception) -> str:
    msg = str(exc).lower()
    name = type(exc).__name__

    if "401" in msg or "invalid_api_key" in msg or "incorrect api key" in msg:
        return (
            "认证失败 (401): API Key 无效或未设置。\n"
            "  检查 ~/.config/ai-media/.env 中的 OPENAI_API_KEY。"
        )
    if "403" in msg or "permission" in msg or "forbidden" in msg:
        return (
            "权限被拒 (403): 账号无图像生成权限或模型不可用。\n"
            "  确认账户已开通 gpt-image 系列，且账单/额度正常。"
        )
    if any(
        x in msg
        for x in (
            "timeout",
            "timed out",
            "connection",
            "connect",
            "network",
            "unreachable",
            "name or service not known",
        )
    ) or name in ("APITimeoutError", "APIConnectionError", "ConnectError", "TimeoutError"):
        return (
            "网络错误: 连接 OpenAI 超时或失败。\n"
            "  国内用户请先设置代理，例如:\n"
            "    export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890\n"
            "  或使用 OPENAI_BASE_URL 配置兼容的中转网关。"
        )
    if any(
        x in msg
        for x in (
            "unsupported_country",
            "region",
            "not available in your country",
            "access denied",
            "geo",
        )
    ):
        return (
            "地区限制: 当前网络或账号所在地区无法访问 OpenAI API。\n"
            "  请使用可访问海外的代理，或配置 OPENAI_BASE_URL 中转。"
        )
    if "429" in msg or "rate" in msg:
        return "请求过于频繁 (429): 请稍后重试或检查额度。"
    return f"生成失败: {exc}"


def main() -> int:
    load_dotenv(CONFIG_ENV)
    ensure_proxy_hint()
    args = parse_args()

    client = build_client()
    models = [MODEL_PRIMARY, MODEL_FALLBACK]
    last_error: Exception | None = None

    for model in models:
        try:
            response = generate_image(
                client, model, args.prompt, args.size, args.quality
            )
            item = response.data[0]
            b64 = item.b64_json
            if not b64:
                raise RuntimeError("API 未返回 b64_json 图像数据")
            out_path = save_image(b64, args.out.expanduser().resolve())
            print(str(out_path))
            if model != MODEL_PRIMARY:
                print(f"提示: 已使用回退模型 {model}", file=sys.stderr)
            return 0
        except Exception as exc:
            last_error = exc
            err_text = str(exc).lower()
            if model == MODEL_PRIMARY and (
                "model" in err_text
                or "does not exist" in err_text
                or "not found" in err_text
                or "invalid_model" in err_text
            ):
                print(f"提示: {MODEL_PRIMARY} 不可用，尝试 {MODEL_FALLBACK}...", file=sys.stderr)
                continue
            print(classify_error(exc), file=sys.stderr)
            return 1

    if last_error:
        print(classify_error(last_error), file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
