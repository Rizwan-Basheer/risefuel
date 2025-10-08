from __future__ import annotations

from math import sqrt
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


def ensure_font(name: str, size: int) -> ImageFont.FreeTypeFont:
    try:
        return ImageFont.truetype(name, size)
    except OSError:
        fallback = "DejaVuSans-Bold.ttf" if "bd" in name.lower() else "DejaVuSans.ttf"
        return ImageFont.truetype(fallback, size)


def build_icon(path: Path) -> None:
    size = 512
    img = Image.new("RGB", (size, size), "#4CAF50")
    pixels = img.load()
    center = size / 2

    for y in range(size):
        for x in range(size):
            dx = x - center
            dy = y - center
            dist = sqrt(dx * dx + dy * dy)
            t = min(dist / (size * 0.85), 1.0)
            r = int((0x4C * (1 - t)) + (0x21 * t))
            g = int((0xAF * (1 - t)) + (0x96 * t))
            b = int((0x50 * (1 - t)) + (0xF3 * t))
            pixels[x, y] = (r, g, b)

    quote_img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(quote_img)

    margin = size * 0.12
    rect = [margin, margin, size - margin, size - margin]
    draw.rounded_rectangle(rect, radius=60, fill=(255, 255, 255, 32))

    font = ensure_font("arialbd.ttf", int(size * 0.45))
    text = "\u201c\u201d"
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    text_x = (size - text_width) / 2
    text_y = (size - text_height) / 2 - size * 0.05
    draw.text((text_x, text_y), text, font=font, fill=(255, 255, 255, 240))

    line_width = int(size * 0.02)
    start = (size * 0.26, size * 0.70)
    mid = (size * 0.46, size * 0.76)
    end = (size * 0.76, size * 0.64)
    for offset in range(-line_width // 2, line_width // 2 + 1):
        draw.line(
            [(start[0], start[1] + offset), (mid[0], mid[1] + offset)],
            fill=(255, 255, 255, 210),
            width=1,
        )
        draw.line(
            [(mid[0], mid[1] + offset), (end[0], end[1] + offset)],
            fill=(255, 255, 255, 210),
            width=1,
        )

    Image.alpha_composite(img.convert("RGBA"), quote_img).convert("RGB").save(path)


def build_feature_graphic(path: Path, icon_path: Path) -> None:
    f_w, f_h = 1024, 500
    featured = Image.new("RGB", (f_w, f_h), "#101317")
    feat_pixels = featured.load()
    for y in range(f_h):
        t = y / f_h
        r = int((0x10 * (1 - t)) + (0x21 * t))
        g = int((0x13 * (1 - t)) + (0x96 * t))
        b = int((0x17 * (1 - t)) + (0xF3 * t))
        for x in range(f_w):
            feat_pixels[x, y] = (r, g, b)

    feat_draw = ImageDraw.Draw(featured, "RGBA")

    card_margin = 60
    card_bbox = [card_margin, card_margin, f_w - card_margin, f_h - card_margin]
    feat_draw.rounded_rectangle(
        card_bbox,
        radius=48,
        fill=(16, 19, 23, 210),
        outline=(255, 255, 255, 40),
        width=2,
    )

    icon_small = Image.open(icon_path).resize((220, 220))
    featured.paste(icon_small, (card_margin + 30, (f_h - 220) // 2))

    title_font = ensure_font("arialbd.ttf", 72)
    subtitle_font = ensure_font("arial.ttf", 36)

    text_x = card_margin + 300
    text_y = card_margin + 90
    feat_draw.text((text_x, text_y), "RiseFuel Quotes", font=title_font, fill="white")
    feat_draw.text(
        (text_x, text_y + 110),
        "Daily motivation, ready offline and online",
        font=subtitle_font,
        fill=(200, 220, 255),
    )
    feat_draw.text(
        (text_x, text_y + 180),
        "Save . Share . Rise",
        font=subtitle_font,
        fill=(255, 255, 255),
    )

    featured.save(path)


def main() -> None:
    out_dir = Path("assets/branding")
    out_dir.mkdir(parents=True, exist_ok=True)

    icon_path = out_dir / "app_icon_512.png"
    featured_path = out_dir / "featured_graphic_1024x500.png"

    build_icon(icon_path)
    build_feature_graphic(featured_path, icon_path)

    print(f"Created branding assets:\\n - {icon_path}\\n - {featured_path}")


if __name__ == "__main__":
    main()

