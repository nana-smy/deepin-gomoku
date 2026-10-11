import QtQuick

// 首页
Item {
    id: screen
    signal start()

    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("五子棋")
            font.pixelSize: 64
            color: "#ecd9a0"
            font.weight: Font.Bold
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Gomoku")
            font.pixelSize: 20
            color: "#b9aa87"
            letterSpacing: 6
        }

        Item { width: 1; height: 48 }

        // 简易棋盘装饰
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 220
            height: 220
            radius: 12
            color: "#d9a96a"
            border.color: "#00000030"
            border.width: 1
            Canvas {
                anchors.fill: parent
                anchors.margins: 14
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#5b4228"
                    ctx.lineWidth = 1
                    for (var i = 0; i < 15; i++) {
                        ctx.beginPath()
                        ctx.moveTo(i * width / 14, 0)
                        ctx.lineTo(i * width / 14, height)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.moveTo(0, i * height / 14)
                        ctx.lineTo(width, i * height / 14)
                        ctx.stroke()
                    }
                    // 几个装饰子
                    drawPiece(ctx, 7, 7, 1)
                    drawPiece(ctx, 6, 6, 2)
                    drawPiece(ctx, 8, 6, 2)
                    drawPiece(ctx, 7, 8, 1)
                }
                function drawPiece(ctx, r, c, col) {
                    var x = c * width / 14
                    var y = r * height / 14
                    ctx.beginPath()
                    ctx.arc(x, y, width / 14 * 0.42, 0, Math.PI * 2)
                    ctx.fillStyle = col === 1 ? "#2a2a2a" : "#f4f4ee"
                    ctx.fill()
                    ctx.strokeStyle = "#00000040"
                    ctx.lineWidth = 1
                    ctx.stroke()
                }
            }
        }

        Item { width: 1; height: 40 }

        RoundButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("开始游戏")
            fontSize: 26
            onClicked: screen.start()
        }
    }
}
