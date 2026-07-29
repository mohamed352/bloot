#!/usr/bin/env python3
"""Normalize App Store screenshots to Apple's required 6.5" display size.

Reads images from  store_assets/screenshots_raw/
Writes images to  store_assets/screenshots_ios_6_5/  at exactly 1284 x 2778 px.

Behavior:
  - Portrait images are scaled to FIT inside 1284x2778 (no stretching) and
    centered on a dark brand canvas (#0A0A0F).
  - Landscape images (e.g. the game table) are rotated? NO - they are placed
    as-is, fit to width, on the dark canvas (still valid portrait screenshot).
  - If an image is already exactly 1284x2778 or 1242x2688 it is still
    re-exported to 1284x2778 for consistency.

Usage:
  python store_assets/prepare_screenshots.py
"""
import sys
from pathlib import Path

from PIL import Image

RAW_DIR = Path(__file__).parent / "screenshots_raw"
OUT_DIR = Path(__file__).parent / "screenshots_ios_6_5"
TARGET_W, TARGET_H = 1284, 2778
CANVAS_COLOR = (10, 10, 15)  # #0A0A0F brand dark canvas
ACCEPTED = {(1242, 2688), (1284, 2778)}
EXTS = {".png", ".jpg", ".jpeg"}


def process(path: Path) -> tuple[str, str]:
    img = Image.open(path).convert("RGB")
    w, h = img.size
    if (w, h) == (TARGET_W, TARGET_H):
        out = img
        note = "already compliant"
    else:
        scale = min(TARGET_W / w, TARGET_H / h)
        new_w, new_h = round(w * scale), round(h * scale)
        resized = img.resize((new_w, new_h), Image.LANCZOS)
        out = Image.new("RGB", (TARGET_W, TARGET_H), CANVAS_COLOR)
        out.paste(resized, ((TARGET_W - new_w) // 2, (TARGET_H - new_h) // 2))
        note = f"fit {w}x{h} -> {new_w}x{new_h} on canvas"
    out_path = OUT_DIR / (path.stem + ".png")
    out.save(out_path, "PNG")
    return out_path.name, note


def main() -> int:
    files = sorted(p for p in RAW_DIR.iterdir() if p.suffix.lower() in EXTS) if RAW_DIR.exists() else []
    if not files:
        print(f"No screenshots found in {RAW_DIR}")
        print("Drop your raw screenshots (.png/.jpg) there and re-run this script.")
        return 1
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Processing {len(files)} screenshot(s) -> {OUT_DIR}\n")
    ok = True
    for f in files:
        try:
            name, note = process(f)
            print(f"  OK  {f.name}  ->  {name}  ({note})")
        except Exception as exc:  # noqa: BLE001
            ok = False
            print(f"  FAIL {f.name}: {exc}")
    # Verify outputs
    print("\nVerification:")
    for f in sorted(OUT_DIR.glob("*.png")):
        with Image.open(f) as im:
            status = "PASS" if im.size == (TARGET_W, TARGET_H) else f"FAIL {im.size}"
            print(f"  {f.name}: {im.size[0]}x{im.size[1]}  {status}")
    return 0 if ok else 2


if __name__ == "__main__":
    sys.exit(main())
