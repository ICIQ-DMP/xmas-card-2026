#!/usr/bin/env python3
"""Render the card to PNG with headless Chrome.

    python3 render.py            # every format below
    python3 render.py card 4k    # only the named formats

Formats:
    card   559x794 card at 4x (2236x3176), for screens and print
    1080p  1920x1080 wallpaper
    4k     3840x2160 wallpaper

Wallpapers scale the card to the full height and fill the sides with the
card background, letting the brand arc run on past the card's edges.
"""
import functools
import http.server
import os
import shutil
import subprocess
import sys
import threading

ROOT = os.path.dirname(os.path.abspath(__file__))
CARD = "Catalysed.dc.html"
OUT_DIR = os.path.join(ROOT, "renders")
CARD_W, CARD_H = 559, 794
BACKGROUND = "#024f67"
ROOT_STYLE = "position: relative; width: 559px; height: 794px; overflow: hidden;"

FORMATS = {
    "card": {"file": "xmas-card-2027.png", "card_scale": 4},
    "1080p": {"file": "xmas-card-2027-wallpaper-1920x1080.png", "size": (1920, 1080)},
    "4k": {"file": "xmas-card-2027-wallpaper-3840x2160.png", "size": (3840, 2160)},
}


def find_chrome():
    for name in ("google-chrome", "google-chrome-stable", "chromium", "chromium-browser"):
        path = shutil.which(name)
        if path:
            return path
    sys.exit("render.py: no Chrome or Chromium found on PATH")


def wallpaper_page(width, height):
    """A copy of the card centred on a width x height viewport, zoomed to fill its height."""
    with open(os.path.join(ROOT, CARD), encoding="utf-8") as f:
        html = f.read()
    if html.count(ROOT_STYLE) != 1:
        sys.exit("render.py: card root style changed; update ROOT_STYLE")
    zoom = height / CARD_H
    html = html.replace(
        ROOT_STYLE,
        f"position: relative; width: 559px; height: 794px; overflow: visible; zoom: {zoom:.6f};",
    )
    html = html.replace(
        "body{margin:0}",
        f"html,body{{margin:0;width:{width}px;height:{height}px;overflow:hidden;background:{BACKGROUND}}}"
        "body{display:flex;justify-content:center;align-items:flex-start}",
    )
    return html


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def serve(directory):
    handler = functools.partial(QuietHandler, directory=directory)
    server = http.server.ThreadingHTTPServer(("127.0.0.1", 0), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


def screenshot(chrome, url, out, width, height, scale):
    subprocess.run(
        [chrome, "--headless=new", "--disable-gpu", "--hide-scrollbars",
         f"--window-size={width},{height}", f"--force-device-scale-factor={scale}",
         "--virtual-time-budget=8000", f"--screenshot={out}", url],
        check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )


def main(names):
    unknown = [n for n in names if n not in FORMATS]
    if unknown:
        sys.exit(f"render.py: unknown format(s) {', '.join(unknown)}; choose from {', '.join(FORMATS)}")
    chrome = find_chrome()
    os.makedirs(OUT_DIR, exist_ok=True)
    server = serve(ROOT)
    base = f"http://127.0.0.1:{server.server_address[1]}/"
    try:
        for name in names or FORMATS:
            fmt = FORMATS[name]
            out = os.path.join(OUT_DIR, fmt["file"])
            if "card_scale" in fmt:
                s = fmt["card_scale"]
                screenshot(chrome, base + CARD, out, CARD_W, CARD_H, s)
                size = (CARD_W * s, CARD_H * s)
            else:
                w, h = size = fmt["size"]
                # written next to the card so its relative asset paths still resolve
                page = os.path.join(ROOT, f".render-{name}.html")
                with open(page, "w", encoding="utf-8") as f:
                    f.write(wallpaper_page(w, h))
                try:
                    screenshot(chrome, base + os.path.basename(page), out, w, h, 1)
                finally:
                    os.remove(page)
            print(f"{name:6} {size[0]}x{size[1]}  {os.path.relpath(out, ROOT)}")
    finally:
        server.shutdown()


if __name__ == "__main__":
    main(sys.argv[1:])
