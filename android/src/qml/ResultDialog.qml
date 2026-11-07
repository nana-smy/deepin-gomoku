import QtQuick

// 对局结果弹窗，复刻桌面版 Resultpopup：
// 388x345 的胜利/失败底图，文案 + “休息一下 / 再来一局”两个按钮。
Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 110

    property bool win: true

    signal again()
    signal rest()

    // 整窗遮罩由 main.qml 的 modalDim 统一绘制（弹窗本身只做缩放，避免遮罩被一起缩小）
    property real uiScale: 1

    Item {
        id: panel
        width: 388
        height: 345
        anchors.centerIn: parent
        scale: dialog.uiScale
        transformOrigin: Item.Center

        Image {
            anchors.fill: parent
            source: dialog.win ? "qrc:/ui/res_win.png" : "qrc:/ui/res_fail.png"
            smooth: true
        }

        Image {
            x: 348
            y: 8
            width: 32; height: 32
            source: closeArea.pressed ? "qrc:/ui/res_close_press.png"
                                      : (closeArea.containsMouse ? "qrc:/ui/res_close_hover.png" : "qrc:/ui/res_close_normal.png")
            MouseArea {
                id: closeArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: dialog.rest()
            }
        }

        // 桌面版：弹窗图片顶在 y=160，文字块 y=340（高度 65），即图片内 180..245
        Text {
            width: parent.width
            y: 180
            height: 65
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: dialog.win ? qsTr("恭喜您！") : qsTr("再接再厉哦～")
            color: "#353535"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 25
        }

        // 休息一下
        Image {
            x: 20
            y: 269
            width: 160
            height: 42
            source: restArea.pressed
                    ? (dialog.win ? "qrc:/ui/res_rest_win_press.png" : "qrc:/ui/res_rest_fail_press.png")
                    : (restArea.containsMouse
                       ? (dialog.win ? "qrc:/ui/res_rest_win_hover.png" : "qrc:/ui/res_rest_fail_hover.png")
                       : (dialog.win ? "qrc:/ui/res_rest_win_normal.png" : "qrc:/ui/res_rest_fail_normal.png"))
            smooth: true
            MouseArea {
                id: restArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: dialog.rest()
            }
        }
        Text {
            x: 20
            y: 269
            width: 160
            height: 42
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("休息一下")
            color: restArea.pressed ? "#FFDB9E" : "#492C04"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 20
        }

        // 再来一局
        Image {
            x: 184
            y: 269
            width: 160
            height: 42
            source: againArea.pressed ? "qrc:/ui/res_again_press.png"
                                      : (againArea.containsMouse ? "qrc:/ui/res_again_hover.png" : "qrc:/ui/res_again_normal.png")
            smooth: true
            MouseArea {
                id: againArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: dialog.again()
            }
        }
        Text {
            x: 184
            y: 269
            width: 160
            height: 42
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("再来一局")
            color: againArea.pressed ? "#FFDB9E" : "#492C04"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 20
        }
    }
}
