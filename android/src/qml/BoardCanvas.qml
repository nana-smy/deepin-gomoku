import QtQuick

// 15x15 棋盘：Canvas 绘制木纹、网格、星位与棋子，鼠标/触摸点击落子
Canvas {
    id: board

    // 与核心逻辑中的常量保持一致
    readonly property int lineNum: 15
    property var controller: null
    signal tapped(int row, int col)

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // 棋盘状态变化时重绘
    Connections {
        target: board.controller
        function onBoardChanged() { board.requestPaint() }
    }

    function geometry() {
        var side = Math.floor(Math.min(width, height) * 0.96)
        var margin = (Math.min(width, height) - side) / 2
        var cell = side / (lineNum - 1)
        return { side: side, margin: margin, cell: cell }
    }

    onPaint: {
        var ctx = getContext("2d")
        var g = geometry()
        var side = g.side, margin = g.margin, cell = g.cell

        ctx.clearRect(0, 0, width, height)

        // 棋盘木质底板（圆角）
        ctx.save()
        ctx.beginPath()
        ctx.roundRect(margin - 6, margin - 6, side + 12, side + 12, 12)
        var grd = ctx.createLinearGradient(margin, margin, margin + side, margin + side)
        grd.addColorStop(0, "#e2b27a")
        grd.addColorStop(1, "#c58f54")
        ctx.fillStyle = grd
        ctx.fill()
        ctx.restore()

        // 网格线
        ctx.strokeStyle = "#5b4228"
        ctx.lineWidth = 1
        ctx.beginPath()
        for (var i = 0; i < lineNum; i++) {
            ctx.moveTo(margin + i * cell, margin)
            ctx.lineTo(margin + i * cell, margin + (lineNum - 1) * cell)
            ctx.moveTo(margin, margin + i * cell)
            ctx.lineTo(margin + (lineNum - 1) * cell, margin + i * cell)
        }
        ctx.stroke()

        // 外框加粗
        ctx.lineWidth = 2.5
        ctx.strokeRect(margin, margin, (lineNum - 1) * cell, (lineNum - 1) * cell)

        // 星位（天元 + 四角星）
        var stars = [[7, 7], [3, 3], [3, 11], [11, 3], [11, 11]]
        ctx.fillStyle = "#5b4228"
        for (var s = 0; s < stars.length; s++) {
            ctx.beginPath()
            ctx.arc(margin + stars[s][1] * cell, margin + stars[s][0] * cell, 3.5, 0, Math.PI * 2)
            ctx.fill()
        }

        // 棋子
        if (!controller) return
        for (var r = 0; r < lineNum; r++) {
            for (var c = 0; c < lineNum; c++) {
                var color = controller.cell(r, c)
                if (color !== 0) {
                    drawPiece(ctx, margin + c * cell, margin + r * cell, color, cell)
                }
            }
        }
    }

    function drawPiece(ctx, x, y, color, cell) {
        var radius = cell * 0.44
        // 阴影
        ctx.beginPath()
        ctx.arc(x, y + 2, radius, 0, Math.PI * 2)
        ctx.fillStyle = "rgba(0,0,0,0.25)"
        ctx.fill()

        ctx.beginPath()
        ctx.arc(x, y, radius, 0, Math.PI * 2)
        if (color === 1) { // 黑
            ctx.fillStyle = "#262626"
            ctx.fill()
            ctx.strokeStyle = "#000000"
            ctx.lineWidth = 1
            ctx.stroke()
        } else { // 白
            ctx.fillStyle = "#f7f6f0"
            ctx.fill()
            ctx.strokeStyle = "#c4c2b6"
            ctx.lineWidth = 1
            ctx.stroke()
        }
        // 高光
        ctx.beginPath()
        ctx.arc(x - radius * 0.32, y - radius * 0.32, radius * 0.24, 0, Math.PI * 2)
        ctx.fillStyle = color === 1 ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.10)"
        ctx.fill()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: function (mouse) {
            var g = board.geometry()
            var cell = g.cell, margin = g.margin
            var col = Math.round((mouse.x - margin) / cell)
            var row = Math.round((mouse.y - margin) / cell)
            if (col < 0 || col >= board.lineNum || row < 0 || row >= board.lineNum)
                return
            // 容差：点击需落在交叉点附近
            var dx = Math.abs(mouse.x - (margin + col * cell))
            var dy = Math.abs(mouse.y - (margin + row * cell))
            if (dx <= cell * 0.55 && dy <= cell * 0.55)
                board.tapped(row, col)
        }
    }
}
