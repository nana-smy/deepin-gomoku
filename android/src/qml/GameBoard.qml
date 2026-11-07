import QtQuick
import "Metrics.js" as M

// 棋盘 + 网格 + 棋子。坐标与桌面版 CheckerboardItem / ChessItem 一致：
// 棋盘 694x694，网格 15 条线、线距 41、边距 60，棋子 44x44。
Item {
    id: board
    width: M.BOARD
    height: M.BOARD

    // 由 main.qml 调用：清空 / 落子
    property var pieces: pieceModel
    property bool interactive: true

    function clear() {
        pieceModel.clear()
    }
    function place(row, col, color) {
        pieceModel.append({"row": row, "col": col, "color": color})
    }

    ListModel { id: pieceModel }

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
            var start = M.MARGIN
            var end = M.MARGIN + M.GAP * (M.LINES - 1)
            for (var i = 0; i < M.LINES; i++) {
                var p = M.MARGIN + M.GAP * i
                ctx.beginPath(); ctx.moveTo(start, p); ctx.lineTo(end, p); ctx.stroke()
                ctx.beginPath(); ctx.moveTo(p, start); ctx.lineTo(p, end); ctx.stroke()
            }
            // 天元
            var c = M.MARGIN + M.GAP * 7
            ctx.beginPath()
            ctx.arc(c, c, 7, 0, Math.PI * 2)
            ctx.fillStyle = "#86582E"
            ctx.fill()
        }
    }

    // 已落下的棋子；最后一手用 “now” 贴图（带高亮环，与桌面版一致）
    Repeater {
        model: pieceModel
        delegate: Image {
            width: 44
            height: 44
            // 棋格坐标以交叉点为中心
            x: M.MARGIN + M.GAP * model.col - 22
            y: M.MARGIN + M.GAP * model.row - 22
            smooth: true
            source: {
                var isLast = (index === pieceModel.count - 1)
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
        width: 24
        height: 24
        Rectangle {
            anchors.fill: parent
            radius: 12
            color: "#33000000"
        }
        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 5
            color: root.userColor === 1 ? "#B3000000" : "white"
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: board.interactive
        hoverEnabled: true

        function cellAt(x, y) {
            var col = Math.round((x - M.MARGIN) / M.GAP)
            var row = Math.round((y - M.MARGIN) / M.GAP)
            if (row < 0 || row >= M.LINES || col < 0 || col >= M.LINES)
                return null
            // 与桌面版 ChessItem 的 44x44 命中范围一致
            if (Math.abs(x - (M.MARGIN + M.GAP * col)) > 22 ||
                Math.abs(y - (M.MARGIN + M.GAP * row)) > 22)
                return null
            return {"row": row, "col": col}
        }

        onPressed: (mouse) => {
            var c = cellAt(mouse.x, mouse.y)
            if (c && controller && controller.cell(c.row, c.col) === 0
                    && controller.started && !controller.paused
                    && controller.gameStatus === 0 && !controller.aiThinking) {
                hoverPreview.x = M.MARGIN + M.GAP * c.col - 12
                hoverPreview.y = M.MARGIN + M.GAP * c.row - 12
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
