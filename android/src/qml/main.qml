import QtQuick
import QtQuick.Window
import QtMultimedia
import "Metrics.js" as M

// deepin-gomoku Android 版主界面。
// 视觉完全对齐桌面版：1024x718 的逻辑画布（原窗口 1024x768 去掉 50px 标题栏），
// 背景 #4C9394→#387D7E 竖向渐变，左侧木棋盘，右侧对局详情，右下三个功能按钮。
Window {
    id: root
    visible: true
    width: 1024
    height: 718
    title: qsTr("五子棋")
    color: "#387D7E"

    visibility: Qt.platform.os === "android" ? Window.FullScreen : Window.AutomaticVisibility

    readonly property int aiColor: controller ? (controller.userColor === 1 ? 2 : 1) : 2
    property bool soundOn: true
    property bool resultVisible: false
    property bool resultWin: false

    // 整窗背景（桌面版 drawBackground 绘制 background.svg，1024x768 竖向渐变）
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4C9394" }
            GradientStop { position: 1.0; color: "#387D7E" }
        }
    }

    SoundEffect {
        id: chessSound
        source: "qrc:/resources/music/chessone.wav"
    }
    SoundEffect {
        id: winSound
        source: "qrc:/resources/music/win.wav"
    }
    SoundEffect {
        id: failSound
        source: "qrc:/resources/music/fail.wav"
    }

    // 逻辑画布：按屏幕等比缩放并居中
    Item {
        id: stage
        width: M.W
        height: M.H
        anchors.centerIn: parent
        scale: Math.min(root.width / M.W, root.height / M.H)
        transformOrigin: Item.Center

        GameBoard {
            id: board
            x: M.BOARD_X
            y: M.BOARD_Y
            interactive: controller ? (controller.started && !controller.paused
                                       && controller.gameStatus === 0 && !controller.aiThinking) : false
        }

        PlayingPanel {
            x: M.PANEL_X
            y: M.PANEL_Y
        }

        // 开始 / 暂停
        FunctionButton {
            x: M.BTN_X
            y: controller && controller.started ? M.BTN_START_GAME : M.BTN_START_IDLE
            // 桌面版逻辑：未开局 / 已结束时按钮显示“开始”，对局中显示“暂停/继续”
            readonly property bool idleState: !controller || !controller.started
                    || controller.gameStatus === 1
            label: idleState ? qsTr("开 始")
                             : (controller.paused ? qsTr("继 续") : qsTr("暂 停"))
            iconSource: idleState ? "qrc:/ui/ico_start.png" : "qrc:/ui/ico_pause.png"
            onClicked: {
                if (!controller)
                    return
                if (idleState) {
                    root.resultVisible = false
                    controller.resetAll()
                    selectDialog.selectedColor = controller.userColor
                    selectDialog.visible = true
                } else {
                    controller.setPaused(!controller.paused)
                }
            }
        }

        // 重玩
        FunctionButton {
            x: M.BTN_X
            y: controller && controller.started ? M.BTN_REPLAY_GAME : M.BTN_REPLAY_IDLE
            label: qsTr("重 玩")
            iconSource: "qrc:/ui/ico_replay.png"
            onClicked: {
                if (!controller)
                    return
                replayDialog.visible = true
            }
        }

        // 音效
        FunctionButton {
            x: M.BTN_X
            y: M.BTN_MUSIC
            label: root.soundOn ? qsTr("关闭音效") : qsTr("开启音效")
            iconSource: root.soundOn ? "qrc:/ui/ico_sound_on.png" : "qrc:/ui/ico_sound_off.png"
            onClicked: root.soundOn = !root.soundOn
        }

        SelectColorDialog {
            id: selectDialog
            objectName: "selectDialog"
            onAccepted: (color) => {
                visible = false
                if (controller)
                    controller.newGame(color)
            }
            onCanceled: visible = false
        }

        ResultDialog {
            id: resultDialog
            objectName: "resultDialog"
            visible: root.resultVisible
            win: root.resultWin
            onRest: root.resultVisible = false
            onAgain: {
                root.resultVisible = false
                if (controller) {
                    controller.resetAll()
                    selectDialog.selectedColor = controller.userColor
                    selectDialog.visible = true
                }
            }
        }

        ExitDialog {
            id: exitDialog
            objectName: "exitDialog"
            message: qsTr("游戏正在进行中，确定退出吗？")
            confirmText: qsTr("退 出")
            onConfirmed: {
                visible = false
                Qt.quit()
            }
            onCanceled: visible = false
        }

        ExitDialog {
            id: replayDialog
            objectName: "replayDialog"
            message: qsTr("确定要重新开始吗？")
            confirmText: qsTr("重 玩")
            onConfirmed: {
                visible = false
                if (controller) {
                    controller.resetAll()
                    selectDialog.selectedColor = controller.userColor
                    selectDialog.visible = true
                }
            }
            onCanceled: visible = false
        }
    }

    // 安卓返回键：对局中先弹桌面版同款“确定退出吗”弹窗
    Item {
        anchors.fill: parent
        focus: true
        Keys.onReleased: (event) => {
            if (event.key !== Qt.Key_Back && event.key !== Qt.Key_Escape)
                return
            event.accepted = true
            if (replayDialog.visible) {
                replayDialog.visible = false
            } else if (resultDialog.visible) {
                resultDialog.visible = false
            } else if (selectDialog.visible) {
                selectDialog.visible = false
            } else if (controller && controller.started && controller.gameStatus === 0) {
                exitDialog.visible = true
            } else {
                Qt.quit()
            }
        }
    }

    Connections {
        target: controller
        function onMovePlayed(row, col, color) {
            board.place(row, col, color)
            if (root.soundOn && chessSound)
                chessSound.play()
        }
        function onStartedChanged() {
            if (controller.started)
                board.clear()
        }
        function onGameStatusChanged() {
            if (!controller || controller.gameStatus !== 1)
                return
            var win = (controller.winner !== 3 && controller.winner === controller.userColor)
            root.resultWin = win
            root.resultVisible = true
            if (root.soundOn) {
                if (win)
                    winSound.play()
                else
                    failSound.play()
            }
        }
    }
}
