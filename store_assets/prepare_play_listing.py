#!/usr/bin/env python3
"""Generate Google Play store-listing assets for Bloot.

Outputs to store_assets/play_listing/:
  - icon_512.png              Play app icon, 512x512 (from assets/images/logo.png)
  - feature_graphic.png       Feature graphic, 1024x500 (center band of the
                              brand render in stitch_bloot_social_onboarding_platform/bloot_brand_logo)
  - phone_XX_<name>.png       Phone screenshots, 1080x1920 (9:16), each design
                              render fit on the #0A0A0F brand canvas

Play requirements targeted:
  - Icon: PNG/JPEG <= 1 MB, 512x512
  - Feature graphic: PNG/JPEG <= 15 MB, 1024x500
  - Phone screenshots: 2-8, PNG/JPEG <= 8 MB, 9:16 or 16:9,
    sides 320-3840 px, >= 1080 px for promo eligibility

Usage:
  python store_assets/prepare_play_listing.py
"""
import sys
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).parent.parent
STITCH = ROOT / "stitch_bloot_social_onboarding_platform"
OUT_DIR = Path(__file__).parent / "play_listing"

CANVAS_COLOR = (10, 10, 15)  # #0A0A0F brand dark canvas
ICON_SIZE = (512, 512)
FEATURE_SIZE = (1024, 500)
SHOT_SIZE = (1080, 1920)  # 9:16 portrait

# Upload order for the Play Console phone screenshots.
SCREENS = [
    "home_screen",
    "game_play_landscape_1",
    "watch_live_stream",
    "private_room_lobby",
    "discover_streams",
    "create_room",
    "chat_list",
    "user_profile",
]


def fit_on_canvas(img: Image.Image, size: tuple[int, int]) -> Image.Image:
    """Scale img to FIT inside size (no stretch), centered on brand canvas."""
    img = img.convert("RGB")
    w, h = img.size
    scale = min(size[0] / w, size[1] / h)
    new_w, new_h = round(w * scale), round(h * scale)
    resized = img.resize((new_w, new_h), Image.LANCZOS)
    out = Image.new("RGB", size, CANVAS_COLOR)
    out.paste(resized, ((size[0] - new_w) // 2, (size[1] - new_h) // 2))
    return out


def make_icon() -> Path:
    src = Image.open(ROOT / "assets/images/logo.png").convert("RGB")
    out = src.resize(ICON_SIZE, Image.LANCZOS)
    path = OUT_DIR / "icon_512.png"
    out.save(path, "PNG")
    return path


def make_feature_graphic() -> Path:
    src = Image.open(STITCH / "bloot_brand_logo/screen.png").convert("RGB")
    w, h = src.size  # 1024x1024 brand render
    fw, fh = FEATURE_SIZE
    # Crop the central band (logo + wordmark are vertically centered).
    top = (h - fh) // 2
    out = src.crop((0, top, w, top + fh)).resize(FEATURE_SIZE, Image.LANCZOS)
    path = OUT_DIR / "feature_graphic.png"
    out.save(path, "PNG")
    return path


def make_screenshots() -> list[Path]:
    paths = []
    for i, name in enumerate(SCREENS, start=1):
        src_path = STITCH / name / "screen.png"
        out = fit_on_canvas(Image.open(src_path), SHOT_SIZE)
        path = OUT_DIR / f"phone_{i:02d}_{name}.png"
        out.save(path, "PNG")
        paths.append(path)
    return paths


def verify(paths: list[Path]) -> bool:
    ok = True
    print("\nVerification:")
    for p in sorted(paths):
        with Image.open(p) as im:
            size_kb = p.stat().st_size // 1024
            if p.name == "icon_512.png":
                good = im.size == ICON_SIZE and size_kb <= 1024
            elif p.name == "feature_graphic.png":
                good = im.size == FEATURE_SIZE
            else:
                w, h = im.size
                good = (w, h) == SHOT_SIZE and size_kb <= 8192
            status = "PASS" if good else "FAIL"
            ok = ok and good
            print(f"  {p.name}: {im.size[0]}x{im.size[1]}, {size_kb} KB  {status}")
    return ok


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    paths = [make_icon(), make_feature_graphic(), *make_screenshots()]
    print(f"Wrote {len(paths)} assets -> {OUT_DIR}")
    return 0 if verify(paths) else 2


if __name__ == "__main__":
    sys.exit(main())
