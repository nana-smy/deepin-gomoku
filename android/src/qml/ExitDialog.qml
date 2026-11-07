import QtQuick

// 退出/重玩确认弹窗，复刻桌面版 ExitDialog（386x234）。
Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 120

    // 文案由调用方指定：对局中退出 vs 重玩确认
    property string message: qsTr("游戏正在进行中，确定退出吗？")
    property string confirmText: qsTr("退 出")

    signal confirmed()
    signal canceled()

    // 整窗遮罩由 main.qml 的 modalDim 统一绘制（弹窗本身只做缩放，避免遮罩被一起缩小）
    property real uiScale: 1

    Item {
        id: panel
        width: 386
        height: 234
        anchors.centerIn: parent
        scale: dialog.uiScale
        transformOrigin: Item.Center

        Image {
            anchors.fill: parent
            source: "qrc:/ui/exit_base.png"
            smooth: true
        }

        Image {
            x: 346
            y: 6
            width: 34; height: 34
            source: "qrc:/ui/exit_close.png"
            smooth: true
            MouseArea {
                anchors.fill: parent
                onClicked: dialog.canceled()
            }
        }

        Text {
            x: 20
            y: 55
            width: parent.width - 40
            height: 100
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            text: dialog.message
            color: "#024526"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 25
        }

        // 继续游戏
        Image {
            x: 26
            y: 172
            width: 160
            height: 42
            source: cancelArea.pressed ? "qrc:/ui/exit_cancel_press.png"
                                       : (cancelArea.containsMouse ? "qrc:/ui/exit_cancel_hover.png" : "qrc:/ui/exit_cancel_normal.png")
            smooth: true
            MouseArea {
                id: cancelArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: dialog.canceled()
            }
        }
        Text {
            x: 26
            y: 172
            width: 160
            height: 42
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("继续游戏")
            color: cancelArea.pressed ? "#FFDB9E" : "#492C04"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 20
        }

        // 退出
        Image {
            x: 200
            y: 172
            width: 160
            height: 42
            source: okArea.pressed ? "qrc:/ui/exit_ok_press.png"
                                   : (okArea.containsMouse ? "qrc:/ui/exit_ok_hover.png" : "qrc:/ui/exit_ok_normal.png")
            smooth: true
            MouseArea {
                id: okArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: dialog.confirmed()
            }
        }
        Text {
            x: 200
            y: 172
            width: 160
            height: 42
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: dialog.confirmText
            color: okArea.pressed ? "#FFDB9E" : "#492C04"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 20
        }
    }
}
