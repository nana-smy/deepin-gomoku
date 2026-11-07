import QtQuick
import "Metrics.js" as M

// 棋盘 + 网格 + 棋子。横屏时按桌面版原始尺寸 694x694 绘制；
// 竖屏时通过 boardSize 等比放大（线距、边距、棋子尺寸按同一比例缩放），
// 保持两种方向下的观感与桌面版一致。
Item {
    id: board
    // 棋盘边长（桌面版为 694）
    property real boardSize: M.BOARD
    // 外部共享的棋子模型（横竖屏共用同一份，旋转屏幕不会丢子）
    property var sourceModel: null
    property bool interactive: true

    width: boardSize
    height: boardSize

    // 相对桌面版 694 的缩放系数
    readonly property real s0: boardSize / M.BOARD
    readonly property real margin: M.MARGIN * s0
    readonly property real gap: M.GAP * s0
    readonly property real stone: 44 * s0

    readonly property var activeModel: sourceModel ? sourceModel : localModel

    ListModel { id: localModel }

    function clear() {
        activeModel.clear()
    }
    function place(row, col, color) {
        activeModel.append({"row": row, "col": col, "color": color})
    }

    Image {
        anchors.fill: parent
        source: "qrc:/ui/board.png"
        smooth: true
    }

    // 桌面版棋盘线与天元点是代码绘制的：线 #000000 alpha 0.6，天元 #86582E 半径 7
    Canvas {
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "rgba(0,0,0,0.6)"
            ctx.lineWidth = 1
            var start = board.margin
            var end = board.margin + board.gap * (M.LINES - 1)
            for (var i = 0; i < M.LINES; i++) {
                var p = board.margin + board.gap * i
                ctx.beginPath(); ctx.moveTo(start, p); ctx.lineTo(end, p); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(p, start); ctx.lineTo(p, end); ctx.stroke()
            }
            // 天元
            var c = board.margin + board.gap * 7
            ctx.beginPath()
            ctx.arc(c, c, 7 * board.s0, 0, Math.PI * 2)
            ctx.fillStyle = "#86582E"
            ctx.fill()
        }
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }

    // 已落下的棋子；最后一手用 “now” 贴图（带高亮环，与桌面版一致）
    Repeater {
        model: board.activeModel
        delegate: Image {
            width: board.stone
            height: board.stone
            // 棋格坐标以交叉点为中心
            x: board.margin + board.gap * model.col - board.stone / 2
            y: board.margin + board.gap * model.row - board.stone / 2
            smooth: true
            source: {
                var isLast = (index === board.activeModel.count - 1)
                if (model.color === 1)
                    return isLast ? "qrc:/ui/stone_black_now.png" : "qrc:/ui/stone_black.png"
                return isLast ? "qrc:/ui/stone_white_now.png" : "qrc:/ui/stone_white.png"
            }
        }
    }

    // 落子预览（桌面版 hover：外层 24px、20% 黑阴影 + 中间 10px 半透明圆点）
    Item {
        id: hoverPreview
        visible: false
        width: 24 * board.s0
        height: 24 * board.s0
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "#33000000"
        }
        Rectangle {
            anchors.centerIn: parent
            width: 10 * board.s0
            height: 10 * board.s0
            radius: width / 2
            color: root.userColor === 1 ? "#B3000000" : "white"
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: board.interactive
        hoverEnabled: true

        function cellAt(x, y) {
            var col = Math.round((x - board.margin) / board.gap)
            var row = Math.round((y - board.margin) / board.gap)
            if (row < 0 || row >= M.LINES || col < 0 || col >= M.LINES)
                return null
            // 与桌面版 ChessItem 的 44x44 命中范围一致（按比例缩放）
            if (Math.abs(x - (board.margin + board.gap * col)) > board.stone / 2 ||
                Math.abs(y - (board.margin + board.gap * row)) > board.stone / 2)
                return null
            return {"row": row, "col": col}
        }

        onPressed: (mouse) => {
            var c = cellAt(mouse.x, mouse.y)
            if (c && controller && controller.cell(c.row, c.col) === 0
                    && controller.started && !controller.paused
                    && controller.gameStatus === 0 && !controller.aiThinking) {
                hoverPreview.x = board.margin + board.gap * c.col - hoverPreview.width / 2
                hoverPreview.y = board.margin + board.gap * c.row - hoverPreview.height / 2
                hoverPreview.visible = true
            }
        }
        onReleased: hoverPreview.visible = false
        onCanceled: hoverPreview.visible = false

        onClicked: (mouse) => {
            var c = cellAt(mouse.x, mouse.y)
            if (c && controller)
                controller.userMove(c.row, c.col)
        }
    }
}
