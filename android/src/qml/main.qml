import QtQuick
import QtQuick.Window
import QtMultimedia
import "Metrics.js" as M

// deepin-gomoku Android 版主界面。
// 设计基准完全对齐桌面版：1024x718 的逻辑画布（原窗口 1024x768 去掉 50px 标题栏），
// 背景 #4C9394→#387D7E 竖向渐变，左侧木棋盘，右侧对局详情，右下三个功能按钮。
//
// 横屏：整块 1024x718 画布等比缩放居中，与桌面版逐像素一致。
// 竖屏：同一套素材与尺寸，改为“顶部对局信息 + 中间放大棋盘 + 底部三按钮”的自适应排布，
//       棋盘按宽度等比放大，棋子尺寸/线距同比例缩放，观感与桌面版保持一致。
Window {
    id: root
    visible: true
    width: 1024
    height: 718
    title: qsTr("五子棋")
    color: "#387D7E"

    visibility: Qt.platform.os === "android" ? Window.FullScreen : Window.AutomaticVisibility

    // 竖屏判定：高度明显大于宽度（兼容 16:9 / 19.5:9 / 全面屏）
    readonly property bool portrait: height > width * 1.15
    // 横屏按整窗等比适配；竖屏按宽度适配、纵向自适应
    readonly property real landscapeScale: Math.min(width / M.W, height / M.H)
    readonly property real portraitScale: width / M.W

    readonly property int aiColor: controller ? (controller.userColor === 1 ? 2 : 1) : 2
    property bool soundOn: true
    property bool resultVisible: false
    property bool resultWin: false

    // 棋子的唯一数据源：横竖屏共用，旋转屏幕不会丢子
    ListModel { id: pieceModel }

    function placePiece(row, col, color) {
        pieceModel.append({"row": row, "col": col, "color": color})
    }
    function clearPieces() {
        pieceModel.clear()
    }

    // 开始/暂停共用逻辑（两种方向同一套行为）
    function handleStartPause() {
        if (!controller)
            return
        if (!controller.started || controller.gameStatus === 1) {
            root.resultVisible = false
            controller.resetAll()
            selectDialog.selectedColor = controller.userColor
            selectDialog.visible = true
        } else {
            controller.setPaused(!controller.paused)
        }
    }

    readonly property bool boardInteractive: controller
            ? (controller.started && !controller.paused
               && controller.gameStatus === 0 && !controller.aiThinking) : false

    // 整窗背景（桌面版 drawBackground 绘制 background.svg，1024x768 竖向渐变）
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#4C9394" }
            GradientStop { position: 1.0; color: "#387D7E" }
        }
    }

    // 弹窗整窗遮罩：独立于弹窗绘制，弹窗缩放时遮罩不会被一起缩小
    Rectangle {
        id: modalDim
        anchors.fill: parent
        z: 95
        color: "#4D000000"
        visible: selectDialog.visible || resultDialog.visible
                 || exitDialog.visible || replayDialog.visible
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

    // ---------------------------------------------------------------- 横屏
    Item {
        id: landscapeView
        width: M.W
        height: M.H
        anchors.centerIn: parent
        visible: !root.portrait
        scale: root.landscapeScale
        transformOrigin: Item.Center

        GameBoard {
            x: M.BOARD_X
            y: M.BOARD_Y
            sourceModel: pieceModel
            interactive: root.boardInteractive
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
            onClicked: root.handleStartPause()
        }

        // 重玩
        FunctionButton {
            x: M.BTN_X
            y: controller && controller.started ? M.BTN_REPLAY_GAME : M.BTN_REPLAY_IDLE
            label: qsTr("重 玩")
            iconSource: "qrc:/ui/ico_replay.png"
            onClicked: replayDialog.visible = true
        }

        // 音效
        FunctionButton {
            x: M.BTN_X
            y: M.BTN_MUSIC
            label: root.soundOn ? qsTr("关闭音效") : qsTr("开启音效")
            iconSource: root.soundOn ? "qrc:/ui/ico_sound_on.png" : "qrc:/ui/ico_sound_off.png"
            onClicked: root.soundOn = !root.soundOn
        }
    }

    // ---------------------------------------------------------------- 竖屏
    Item {
        id: portraitView
        // 逻辑宽度固定 1024，高度取屏幕实际高度换算，整体按宽度缩放
        width: M.W
        height: root.height / root.portraitScale
        visible: root.portrait
        scale: root.portraitScale
        transformOrigin: Item.TopLeft

        // 顶部预留状态栏/摄像头挖孔区域
        readonly property real topInset: 40
        readonly property real panelY: topInset + 16
        readonly property real panelH: 290
        readonly property real btnY: height - 160
        readonly property real availTop: panelY + panelH + 30
        readonly property real availBottom: btnY - 40
        // 棋盘按宽度铺满（左右各留 16），纵向空间不足时自动缩小
        readonly property real bSize: Math.max(320, Math.min(M.W - 32,
                                                             availBottom - availTop))

        PortraitPanel {
            x: 0
            y: portraitView.panelY
            height: portraitView.panelH
        }

        GameBoard {
            x: (M.W - portraitView.bSize) / 2
            y: portraitView.availTop + (portraitView.availBottom - portraitView.availTop
                                        - portraitView.bSize) / 2
            boardSize: portraitView.bSize
            sourceModel: pieceModel
            interactive: root.boardInteractive
        }

        // 三个功能按钮横排（竖屏整体放大，更贴合手指点击）
        readonly property real btnScale: 1.55
        FunctionButton {
            x: 20
            y: portraitView.btnY
            scale: portraitView.btnScale
            transformOrigin: Item.TopLeft
            readonly property bool idleState: !controller || !controller.started
                    || controller.gameStatus === 1
            label: idleState ? qsTr("开 始")
                             : (controller.paused ? qsTr("继 续") : qsTr("暂 停"))
            iconSource: idleState ? "qrc:/ui/ico_start.png" : "qrc:/ui/ico_pause.png"
            onClicked: root.handleStartPause()
        }
        FunctionButton {
            x: 354
            y: portraitView.btnY
            scale: portraitView.btnScale
            transformOrigin: Item.TopLeft
            label: qsTr("重 玩")
            iconSource: "qrc:/ui/ico_replay.png"
            onClicked: replayDialog.visible = true
        }
        FunctionButton {
            x: 688
            y: portraitView.btnY
            scale: portraitView.btnScale
            transformOrigin: Item.TopLeft
            label: root.soundOn ? qsTr("关闭音效") : qsTr("开启音效")
            iconSource: root.soundOn ? "qrc:/ui/ico_sound_on.png" : "qrc:/ui/ico_sound_off.png"
            onClicked: root.soundOn = !root.soundOn
        }
    }

    // ---------------------------------------------------------------- 弹窗
    SelectColorDialog {
        id: selectDialog
        objectName: "selectDialog"
        uiScale: root.portrait ? Math.min(root.width / 560, 2.1) : 1
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
        uiScale: root.portrait ? Math.min(root.width / 560, 2.1) : 1
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
        uiScale: root.portrait ? Math.min(root.width / 560, 2.1) : 1
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
        uiScale: root.portrait ? Math.min(root.width / 560, 2.1) : 1
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
            root.placePiece(row, col, color)
            if (root.soundOn && chessSound)
                chessSound.play()
        }
        function onStartedChanged() {
            if (controller.started)
                root.clearPieces()
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
