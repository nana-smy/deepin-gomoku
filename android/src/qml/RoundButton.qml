import QtQuick

// 通用圆角按钮组件
Rectangle {
    id: btn
    property string text: ""
    property color bgColor: "#c9a24b"
    property color textColor: "#2a2418"
    property int fontSize: 22
    signal clicked()

    width: 260
    height: 72
    radius: height / 2
    color: ma.pressed ? Qt.darker(bgColor, 1.25)
         : ma.containsMouse ? Qt.lighter(bgColor, 1.1)
         : bgColor
    border.color: Qt.lighter(bgColor, 1.35)
    border.width: 1.5

    Text {
        anchors.centerIn: parent
        text: btn.text
        font.pixelSize: btn.fontSize
        color: btn.textColor
        font.weight: Font.DemiBold
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        onClicked: btn.clicked()
    }
}
