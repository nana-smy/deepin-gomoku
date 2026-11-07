#!/usr/bin/env python3
"""构建前从仓库自带 SVG 生成 Android 启动图标（PNG 无法以文本提交，故在 CI 光栅化）。"""

import os
import shutil
import subprocess
import sys

NL = chr(10)
HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", ".."))
SRC = os.path.join(REPO, "gomoku/assets/resources/desktop/com.deepin.gomoku.svg")
RES = os.path.join(REPO, "android", "android", "res")

CANVAS, ART = 108, 64
SCALE = CANVAS * 0.86 / ART
OFFSET = (CANVAS - ART * SCALE) / 2

ADAPTIVE = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""

BACKGROUND = """<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <gradient android:angle="270" android:startColor="#FDD7A7"
        android:endColor="#C78051" android:type="linear" />
</shape>
"""


def foreground_svg(source):
    """去掉木质底板与投影，得到透明底的前景层。"""
    s = source.replace(' filter="url(#五子棋-a)"', "")
    keep = [
        l
        for l in s.split(NL)
        if not l.strip().startswith('<rect width="56"')
        and not l.strip().startswith('<path fill="url(#五子棋-c)"')
    ]
    s = NL.join(keep)
    defs = s[s.index("<defs>"): s.index("</defs>") + 7]
    body = s[s.index(">", s.index('transform="translate(4 4)"')) + 1: s.rindex("</g>")]
    group = '<g transform="translate(%.4f %.4f) scale(%.6f)">' % (OFFSET, OFFSET, SCALE)
    root = '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d">'
    return NL.join(
        [
            root % (CANVAS, CANVAS, CANVAS, CANVAS),
            "  " + defs,
            "  " + group,
            '    <g transform="translate(4 4)">',
            body,
            "    </g>",
            "  </g>",
            "</svg>",
            "",
        ]
    )


def draw(svg, out, size):
    os.makedirs(os.path.dirname(out), exist_ok=True)
    if shutil.which("rsvg-convert"):
        subprocess.run(
            ["rsvg-convert", "-w", str(size), "-h", str(size), "-o", out, svg],
            check=True,
        )
    else:
        try:
            import cairosvg
        except ImportError:
            sys.exit("缺少光栅化工具：请安装 librsvg2-bin 或 pip install cairosvg")
        cairosvg.svg2png(url=svg, write_to=out, output_width=size, output_height=size)
    print("generated", os.path.relpath(out, RES))


def put(rel, text):
    path = os.path.join(RES, rel)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w", encoding="utf-8", newline=NL) as f:
        f.write(text)
    print("generated", rel)


def main():
    source = open(SRC, encoding="utf-8").read()
    fg = os.path.join(HERE, "ic_launcher_foreground.svg")
    with open(fg, "w", encoding="utf-8", newline=NL) as f:
        f.write(foreground_svg(source))
    draw(SRC, os.path.join(RES, "mipmap-xxxhdpi/ic_launcher.png"), 192)
    shutil.copyfile(
        os.path.join(RES, "mipmap-xxxhdpi/ic_launcher.png"),
        os.path.join(RES, "mipmap-xxxhdpi/ic_launcher_round.png"),
    )
    draw(fg, os.path.join(RES, "mipmap-xxxhdpi/ic_launcher_foreground.png"), 432)
    put("mipmap-anydpi-v26/ic_launcher.xml", ADAPTIVE)
    put("mipmap-anydpi-v26/ic_launcher_round.xml", ADAPTIVE)
    put("drawable/ic_launcher_background.xml", BACKGROUND)


if __name__ == "__main__":
    main()
