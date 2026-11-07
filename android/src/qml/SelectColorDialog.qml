import QtQuick

// 选择棋子颜色弹窗，复刻桌面版 Selectchess：
// 底板 386x234，标题“请选择您的棋子颜色”，白/黑两个选择项 + 确定按钮。
Item {
    id: dialog
    anchors.fill: parent
    visible: false
    z: 100

    property int selectedColor: 1

    signal accepted(int color)
    signal canceled()

    // 桌面版弹窗打开时整窗 30% 黑遮罩
    Rectangle {
        anchors.fill: parent
        color: "#4D000000"
    }

    Item {
        id: panel
        width: 386
        height: 234
        anchors.centerIn: parent

        Image {
            anchors.fill: parent
            source: "qrc:/ui/sel_base.png"
            smooth: true
        }

        Image {
            x: 346
            y: 6
            width: 34; height: 34
            source: "qrc:/ui/sel_close.png"
            smooth: true
            MouseArea {
                anchors.fill: parent
                onClicked: dialog.canceled()
            }
        }

        Text {
            width: parent.width
            y: 44
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("请选择您的棋子颜色")
            color: "#02412C"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 25
        }

        // 白棋
        Image {
            x: 88
            y: 102
            width: 24; height: 24
            source: dialog.selectedColor === 2 ? "qrc:/ui/sel_radio_on.png" : "qrc:/ui/sel_radio_off.png"
        }
        Image {
            x: 116
            y: 92
            width: 44; height: 44
            source: "qrc:/ui/stone_white.png"
        }
        MouseArea {
            x: 80
            y: 84
            width: 88
            height: 60
            onClicked: dialog.selectedColor = 2
        }

        // 黑棋
        Image {
            x: 226
            y: 102
            width: 24; height: 24
            source: dialog.selectedColor === 1 ? "qrc:/ui/sel_radio_on.png" : "qrc:/ui/sel_radio_off.png"
        }
        Image {
            x: 254
            y: 92
            width: 44; height: 44
            source: "qrc:/ui/stone_black.png"
        }
        MouseArea {
            x: 218
            y: 84
            width: 88
            height: 60
            onClicked: dialog.selectedColor = 1
        }

        Image {
            x: 26
            y: 168
            width: 334; height: 46
            source: okArea.pressed ? "qrc:/ui/sel_ok_press.png"
                                   : (okArea.containsMouse ? "qrc:/ui/sel_ok_hover.png" : "qrc:/ui/sel_ok_normal.png")
            smooth: true
            MouseArea {
                id: okArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: dialog.accepted(dialog.selectedColor)
            }
        }

        Text {
            x: 26
            y: 168
            width: 334
            height: 46
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: qsTr("确 定")
            color: okArea.pressed ? "#FFDB9E" : "#492C04"
            font.family: "Resource Han Rounded CN"
            font.weight: Font.Black
            font.pixelSize: 20
        }
    }
}
