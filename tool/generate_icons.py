"""Generate the simple Torque Chase browser and PWA icons."""

from pathlib import Path
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1] / "web"
INK = "#08151D"
LINE = "#31515C"
MINT = "#63E6C4"
CORAL = "#FF8D70"


def icon(size: int, destination: Path) -> None:
    scale = 4
    pixels = size * scale
    image = Image.new("RGB", (pixels, pixels), INK)
    draw = ImageDraw.Draw(image)
    center = pixels / 2
    radius = pixels * 0.30
    ring = pixels * 0.065
    draw.ellipse(
        (center - radius, center - radius, center + radius, center + radius),
        outline=LINE,
        width=round(ring),
    )
    draw.line(
        (center, center, center + radius * 0.72, center - radius * 0.72),
        fill=MINT,
        width=round(pixels * 0.065),
        joint="curve",
    )
    tip_x = center + radius * 0.72
    tip_y = center - radius * 0.72
    draw.polygon(
        (
            (tip_x + pixels * 0.08, tip_y - pixels * 0.04),
            (tip_x + pixels * 0.04, tip_y + pixels * 0.08),
            (tip_x - pixels * 0.04, tip_y - pixels * 0.02),
        ),
        fill=MINT,
    )
    hub = pixels * 0.08
    draw.ellipse(
        (center - hub, center - hub, center + hub, center + hub),
        fill=CORAL,
    )
    image.resize((size, size), Image.Resampling.LANCZOS).save(destination)


if __name__ == "__main__":
    for size in (192, 512):
        icon(size, ROOT / "icons" / f"Icon-{size}.png")
        icon(size, ROOT / "icons" / f"Icon-maskable-{size}.png")
    icon(180, ROOT / "icons" / "apple-touch-icon.png")
    icon(64, ROOT / "favicon.png")
