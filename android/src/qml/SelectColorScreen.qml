import QtQuick

// 选择棋子颜色页：黑棋先手 / 白棋后手
Item {
    id: screen
    signal back()
    signal colorChosen(int color)   // 1 黑 2 白

    Text {
        anchors.top: parent.top
        anchors.topMargin: 72
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("选择你的棋子")
        font.pixelSize: 32
        color: "#ecd9a0"
        font.weight: Font.DemiBold
    }

    Row {
        anchors.centerIn: parent
        spacing: 40

        ColorOption {
            colorLabel: qsTr("执黑 · 先手")
            pieceColor: "#2a2a2a"
            onClicked: screen.colorChosen(1)
        }
        ColorOption {
            colorLabel: qsTr("执白 · 后手")
            pieceColor: "#f4f4ee"
            onClicked: screen.colorChosen(2)
        }
    }

    RoundButton {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 56
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("返回")
        bgColor: "#6a6355"
        onClicked: screen.back()
    }

    component ColorOption: Item {
        property string colorLabel: ""
        property color pieceColor: "#fff"
        signal clicked()
        width: 150
        height: 220

        Rectangle {
            anchors.fill: parent
            radius: 18
            color: "#ffffff14"
            border.color: "#ffffff22"
            border.width: 1
        }
        Rectangle {
            anchors.centerIn: parent
            width: 96
            height: 96
            radius: 48
            color: pieceColor
            border.color: "#00000055"
            border.width: 2
        }
        Text {
            anchors.top: parent.top
            anchors.topMargin: 148
            anchors.horizontalCenter: parent.horizontalCenter
            text: colorLabel
            color: "#d9cfa8"
            font.pixelSize: 18
        }
        MouseArea {
            anchors.fill: parent
            onClicked: parent.clicked()
        }
    }
}
