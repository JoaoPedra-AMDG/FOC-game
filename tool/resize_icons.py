"""Create install icons from the edited web/favicon.png artwork."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "web" / "favicon.png"
DESTINATION = ROOT / "web" / "icons"


def main() -> None:
    with Image.open(SOURCE) as file:
        if file.width != file.height:
            raise ValueError("web/favicon.png must be square")
        artwork = file.convert("RGBA")

    DESTINATION.mkdir(parents=True, exist_ok=True)
    for size in (192, 512):
        artwork.resize((size, size), Image.Resampling.LANCZOS).save(
            DESTINATION / f"Icon-{size}.png",
            optimize=True,
        )


if __name__ == "__main__":
    main()
