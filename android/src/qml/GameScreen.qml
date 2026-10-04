import QtQuick
import QtMultimedia

// 对局主界面
Item {
    id: screen
    signal exit()

    // 音效开关
    property bool soundOn: true

    // 音效资源
    SoundEffect {
        id: chessSound
        source: "qrc:/resources/music/chessone.wav"
        volume: 0.8
    }
    SoundEffect {
        id: winSound
        source: "qrc:/resources/music/win.wav"
        volume: 0.9
    }
    SoundEffect {
        id: failSound
        source: "qrc:/resources/music/fail.wav"
        volume: 0.9
    }

    // 落子音效
    Connections {
        target: controller
        function onMovePlayed() {
            if (screen.soundOn)
                chessSound.play()
        }
        function onGameStatusChanged() {
            if (controller && controller.gameStatus === 1 && screen.soundOn) {
                if (controller.winner === controller.userColor)
                    winSound.play()
                else
                    failSound.play()
            }
        }
    }

    // 顶部状态栏
    Rectangle {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 64
        color: "#00000055"

        Text {
            id: turnText
            anchors.centerIn: parent
            text: controller
                  ? (controller.aiThinking
                     ? qsTr("AI 思考中…")
                     : (controller.gameStatus === 1 ? qsTr("对局结束") : qsTr("你的回合")))
                  : ""
            font.pixelSize: 24
            color: controller && controller.aiThinking ? "#f0c060" : "#ecd9a0"
            font.weight: Font.DemiBold
        }

        // 我的棋子颜色标识
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: controller ? (controller.userColor === 1 ? qsTr("你执黑") : qsTr("你执白")) : ""
            font.pixelSize: 16
            color: "#b9aa87"
        }

        // 返回首页
        RoundButton {
            anchors.right: soundBtn.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 44
            text: qsTr("退出")
            fontSize: 15
            bgColor: "#7a4a3a"
            onClicked: screen.exit()
        }
        RoundButton {
            id: soundBtn
            anchors.right: restartBtn.left
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 44
            text: screen.soundOn ? qsTr("音效") : qsTr("静音")
            fontSize: 15
            bgColor: "#5a5a45"
            onClicked: screen.soundOn = !screen.soundOn
        }
        RoundButton {
            id: restartBtn
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 64
            height: 44
            text: qsTr("重来")
            fontSize: 15
            bgColor: "#3f6b5a"
            onClicked: {
                if (controller)
                    controller.resetGame()
            }
        }
    }

    // 棋盘
    BoardCanvas {
        id: boardCanvas
        anchors.top: topBar.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        controller: controller
        onTapped: function (row, col) {
            if (controller)
                controller.userMove(row, col)
        }
    }

    // 结算弹窗
    ResultPopup {
        anchors.fill: parent
        visible: controller && controller.gameStatus === 1
        winner: controller ? controller.winner : 0
        userColor: controller ? controller.userColor : 1
        onAgain: {
            if (controller)
                controller.resetGame()
        }
        onHome: screen.exit()
    }
}
