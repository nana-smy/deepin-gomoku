#!/usr/bin/env python3
"""构建前把桌面版 gomoku/assets/resources 下的 SVG 界面素材光栅化为 PNG。

桌面版界面全部由 SVG 绘制，Qt Quick 的 Image 在 Android 上没有 svg 图片插件，
因此在构建时按 2 倍尺寸光栅化，运行期按逻辑尺寸显示，保证高分屏清晰。
输出的 PNG 不提交到仓库（二进制），由 CI 在 configure 之前生成。
"""

import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", ".."))
SRC = os.path.join(REPO, "gomoku", "assets", "resources")
OUT = os.path.join(REPO, "android", "assets", "ui")

# (输出名, 源 SVG 相对路径, 宽, 高)  宽高为桌面版的逻辑尺寸，输出按 2 倍光栅化
ASSETS = [
    ("board.png", "checkerboard_noline.svg", 694, 694),
    ("stone_black.png", "black_chess.svg", 44, 44),
    ("stone_white.png", "white_chess.svg", 44, 44),
    ("stone_black_now.png", "chess_balck_now.svg", 44, 44),
    ("stone_white_now.png", "chess_white_now.svg", 44, 44),
    ("player_plate_current.png", "playingscreen/currentplayer.svg", 131, 90),
    ("player_plate_other.png", "playingscreen/anotherplayer.svg", 78, 78),
    ("avatar_ai_active.png", "playingscreen/ai_playing.svg", 60, 60),
    ("avatar_user_active.png", "playingscreen/user_playing.svg", 60, 60),
    ("avatar_ai_idle.png", "playingscreen/ai_notplay.svg", 50, 50),
    ("avatar_user_idle.png", "playingscreen/user_notplay.svg", 48, 48),
    ("badge_black.png", "playingscreen/chess_black.svg", 40, 40),
    ("badge_white.png", "playingscreen/chess_white.svg", 40, 40),
    ("btn_normal.png", "function_button/normal.svg", 204, 64),
    ("btn_hover.png", "function_button/hover.svg", 204, 64),
    ("btn_press.png", "function_button/press.svg", 204, 64),
    ("ico_start.png", "icon/begin.svg", 24, 24),
    ("ico_pause.png", "icon/stop.svg", 24, 24),
    ("ico_replay.png", "icon/replay.svg", 24, 24),
    ("ico_sound_on.png", "icon/voice.svg", 24, 24),
    ("ico_sound_off.png", "icon/voiceoff.svg", 24, 24),
    ("sel_base.png", "chessselected/selectbase.svg", 386, 234),
    ("sel_close.png", "chessselected/closebutton.svg", 34, 34),
    ("sel_radio_on.png", "chessselected/radio_checked.svg", 24, 24),
    ("sel_radio_off.png", "chessselected/radio_unchecked.svg", 24, 24),
    ("sel_radio_hover.png", "chessselected/radio_hover.svg", 24, 24),
    ("sel_ok_normal.png", "chessselected/button_normal.svg", 334, 46),
    ("sel_ok_hover.png", "chessselected/button_hover.svg", 334, 46),
    ("sel_ok_press.png", "chessselected/button_press.svg", 334, 46),
    ("res_win.png", "resultpopup/background_win.svg", 388, 345),
    ("res_fail.png", "resultpopup/background_fail.svg", 388, 345),
    ("res_close_normal.png", "resultpopup/normal.svg", 32, 32),
    ("res_close_hover.png", "resultpopup/hover.svg", 32, 32),
    ("res_close_press.png", "resultpopup/press.svg", 32, 32),
    ("res_again_normal.png", "resultpopup/again_normal.svg", 160, 42),
    ("res_again_hover.png", "resultpopup/anain_hover.svg", 160, 42),
    ("res_again_press.png", "resultpopup/again_press.svg", 160, 42),
    ("res_rest_win_normal.png", "resultpopup/win_rest_normal.svg", 160, 42),
    ("res_rest_win_hover.png", "resultpopup/win_rest_hover.svg", 160, 42),
    ("res_rest_win_press.png", "resultpopup/win_rest_press.svg", 160, 42),
    ("res_rest_fail_normal.png", "resultpopup/fail_rest_normal.svg", 160, 42),
    ("res_rest_fail_hover.png", "resultpopup/fail_rest_hover.svg", 160, 42),
    ("res_rest_fail_press.png", "resultpopup/fail_rest_press.svg", 160, 42),
    ("exit_base.png", "exitdialog/close-dialog.svg", 386, 234),
    ("exit_close.png", "resultpopup/close.svg", 34, 34),
    ("exit_ok_normal.png", "exitdialog/exit-normal.svg", 160, 42),
    ("exit_ok_hover.png", "exitdialog/exit-hover.svg", 160, 42),
    ("exit_ok_press.png", "exitdialog/exit-press.svg", 160, 42),
    ("exit_cancel_normal.png", "exitdialog/cancel-normal.svg", 160, 42),
    ("exit_cancel_hover.png", "exitdialog/cancel-hover.svg", 160, 42),
    ("exit_cancel_press.png", "exitdialog/cancel-press.svg", 160, 42),
]

SCALE = 2

_qt_app = None


def draw_with_qt(svg, out, w, h):
    """用 Qt 自己的 QSvgRenderer 渲染，和桌面版 QPixmap 加载 SVG 的结果完全一致。"""
    global _qt_app
    try:
        from PySide6.QtGui import QGuiApplication, QImage, QPainter, QColor
        from PySide6.QtSvg import QSvgRenderer
    except ImportError:
        return False
    os.environ.setdefault("QT_QPA_PLATFORM", "offscreen")
    if _qt_app is None:
        _qt_app = QGuiApplication([])
    renderer = QSvgRenderer(svg)
    if not renderer.isValid():
        return False
    image = QImage(w * SCALE, h * SCALE, QImage.Format_ARGB32)
    image.fill(QColor(0, 0, 0, 0))
    painter = QPainter(image)
    renderer.render(painter)
    painter.end()
    return image.save(out)


def draw(svg, out, w, h):
    # 首选 Qt 自己的 QSvgRenderer（与桌面版渲染路径一致），其次 resvg、cairosvg。
    # 注意 cairosvg 不支持 feComposite(arithmetic)，会把白棋渲染成纯黑，仅作兜底。
    if draw_with_qt(svg, out, w, h):
        return
    try:
        import resvg_py
    except ImportError:
        resvg_py = None
    if resvg_py is not None:
        data = resvg_py.svg_to_bytes(svg_path=svg, width=w * SCALE, height=h * SCALE)
        with open(out, "wb") as f:
            f.write(bytes(data))
        return
    if shutil.which("rsvg-convert"):
        subprocess.run(
            ["rsvg-convert", "-w", str(w * SCALE), "-h", str(h * SCALE), "-o", out, svg],
            check=True,
        )
        return
    try:
        import cairosvg
    except ImportError:
        sys.exit("缺少光栅化工具：请安装 librsvg2-bin、pip install resvg-py 或 pip install cairosvg")
    cairosvg.svg2png(url=svg, write_to=out, output_width=w * SCALE, output_height=h * SCALE)


def main():
    os.makedirs(OUT, exist_ok=True)
    missing = []
    for name, rel, w, h in ASSETS:
        src = os.path.join(SRC, rel)
        if not os.path.exists(src):
            missing.append(rel)
            continue
        draw(src, os.path.join(OUT, name), w, h)
    if missing:
        sys.exit("缺少素材：" + ", ".join(missing))
    print("generated %d UI assets in %s" % (len(ASSETS), os.path.relpath(OUT, REPO)))


if __name__ == "__main__":
    main()
