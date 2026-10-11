"""Generate the Torque Chase logo and browser icons from a three-coil motor mark."""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
WEB = ROOT / "web"
INK = "#08151D"
PANEL = "#112630"
LINE = "#31515C"
MINT = "#63E6C4"
CORAL = "#FF8D70"
GOLD = "#FFD36D"
CREAM = "#F8F1DF"


def _font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    try:
        return ImageFont.truetype("arialbd.ttf", size)
    except OSError:
        return ImageFont.load_default()


def icon(size: int, destination: Path) -> None:
    scale = 4
    pixels = size * scale
    unit = pixels / 128
    image = Image.new("RGB", (pixels, pixels), INK)
    draw = ImageDraw.Draw(image)

    def box(x0: float, y0: float, x1: float, y1: float) -> tuple[int, ...]:
        return tuple(round(value * unit) for value in (x0, y0, x1, y1))

    draw.rounded_rectangle(box(2, 2, 126, 126), radius=round(27 * unit), fill=INK)
    draw.ellipse(box(12, 12, 116, 116), outline=MINT, width=round(3.5 * unit))
    draw.ellipse(box(18, 18, 110, 110), outline=LINE, width=round(2.5 * unit))

    # The three winding groups echo the user's stator sketch.
    coil = Image.new("RGBA", (pixels, pixels), (0, 0, 0, 0))
    coil_draw = ImageDraw.Draw(coil)
    coil_draw.rounded_rectangle(
        box(50, 12, 78, 41),
        radius=round(5 * unit),
        fill=PANEL,
        outline=GOLD,
        width=round(2.5 * unit),
    )
    for y in (17, 24, 31, 38):
        coil_draw.line(
            (round(47 * unit), round(y * unit), round(81 * unit), round(y * unit)),
            fill=CREAM,
            width=round(2.5 * unit),
        )
        for x in (47, 81):
            coil_draw.ellipse(box(x - 1.2, y - 1.2, x + 1.2, y + 1.2), fill=CREAM)
    for angle in (0, 120, 240):
        winding = coil.rotate(angle, resample=Image.Resampling.BICUBIC)
        image.paste(
            winding,
            (0, 0),
            winding,
        )

    draw = ImageDraw.Draw(image)
    draw.ellipse(box(43, 43, 85, 85), fill=PANEL, outline=MINT, width=round(3 * unit))
    draw.arc(box(48, 48, 80, 80), 90, 270, fill=CORAL, width=round(3 * unit))
    draw.arc(box(48, 48, 80, 80), 270, 450, fill=GOLD, width=round(3 * unit))
    draw.line(
        (round(64 * unit), round(46 * unit), round(64 * unit), round(82 * unit)),
        fill=CREAM,
        width=round(2 * unit),
    )
    font = _font(round(13 * unit))
    draw.text((round(50 * unit), round(55 * unit)), "N", font=font, fill=CORAL)
    draw.text((round(68 * unit), round(55 * unit)), "S", font=font, fill=GOLD)

    image.resize((size, size), Image.Resampling.LANCZOS).save(destination)


if __name__ == "__main__":
    for size in (192, 512):
        icon(size, WEB / "icons" / f"Icon-{size}.png")
        icon(size, WEB / "icons" / f"Icon-maskable-{size}.png")
    icon(180, WEB / "icons" / "apple-touch-icon.png")
    icon(64, WEB / "favicon.png")
    icon(192, WEB / "icons" / "app-logo.png")
