import QtQuick

// 对局结束弹窗
Item {
    id: popup
    property int winner: 0    // 1 黑 2 白 3 平
    property int userColor: 1
    signal again()
    signal home()

    // 半透明遮罩
    Rectangle {
        anchors.fill: parent
        color: "#b0000000"
    }

    Rectangle {
        width: Math.min(360, parent.width - 48)
        height: 300
        radius: 24
        color: "#f4ecd8"
        anchors.centerIn: parent
        border.color: "#c9a24b"
        border.width: 2

        Column {
            anchors.centerIn: parent
            spacing: 22

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: popup.winner === 3
                      ? qsTr("平局")
                      : (popup.winner === popup.userColor ? qsTr("你赢了！") : qsTr("你输了"))
                font.pixelSize: 34
                color: popup.winner === 3 ? "#8a7a5a"
                     : (popup.winner === popup.userColor ? "#3f7a3f" : "#a04030")
                font.weight: Font.Bold
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: popup.winner === 3
                      ? qsTr("棋盘已满，不分胜负")
                      : (popup.winner === popup.userColor ? qsTr("再赢一局？") : qsTr("再来一局扳回一城！"))
                font.pixelSize: 16
                color: "#7a705a"
            }

            Item { width: 1; height: 4 }

            RoundButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("再来一局")
                onClicked: popup.again()
            }
            RoundButton {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("返回首页")
                bgColor: "#6a6355"
                onClicked: popup.home()
            }
        }
    }
}
