"""Re-encode StudioOps site assets for faster loads. Executor lane: assets only."""
from __future__ import annotations

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("PIL not installed; skip optimize", file=sys.stderr)
    sys.exit(0)

ASSETS = Path(r"C:\WPAI\Software\StudioOps\site\assets")
MAX_EDGE = int(sys.argv[1]) if len(sys.argv) > 1 else 1600
JPEG_Q = int(sys.argv[2]) if len(sys.argv) > 2 else 82


def fit(im: Image.Image) -> Image.Image:
    w, h = im.size
    edge = max(w, h)
    if edge <= MAX_EDGE:
        return im
    scale = MAX_EDGE / float(edge)
    nw, nh = max(1, int(w * scale)), max(1, int(h * scale))
    return im.resize((nw, nh), Image.Resampling.LANCZOS)


def main() -> int:
    if not ASSETS.is_dir():
        print(f"Missing {ASSETS}", file=sys.stderr)
        return 1
    for path in sorted(ASSETS.iterdir()):
        if path.suffix.lower() not in {".jpg", ".jpeg", ".png"}:
            continue
        before = path.stat().st_size
        with Image.open(path) as raw:
            im = fit(raw.copy())
        if path.suffix.lower() in {".jpg", ".jpeg"}:
            if im.mode not in ("RGB", "L"):
                im = im.convert("RGB")
            im.save(path, format="JPEG", quality=JPEG_Q, optimize=True, progressive=True)
        else:
            if im.mode == "P":
                im = im.convert("RGBA")
            im.save(path, format="PNG", optimize=True)
        after = path.stat().st_size
        pct = (after / before) * 100 if before else 0
        print(f"{path.name}: {before} -> {after} ({pct:.1f}%)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
