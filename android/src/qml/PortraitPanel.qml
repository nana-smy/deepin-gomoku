import QtQuick

// 竖屏顶部的对局信息区：把桌面版 PlayingScreen 的“提示语 + 双方头像/棋子”
// 从竖排改为横向紧凑布局。素材与配色完全沿用桌面版；
// 手机屏幕上逻辑像素接近物理像素，因此整组元素按 uiScale 放大，保证可读。
Item {
    id: panel
    width: 1024
    height: 290

    readonly property int aiColor: controller ? (controller.userColor === 1 ? 2 : 1) : 2
    // 当前思考方：AI 思考时是 AI，否则是玩家
    readonly property int curColor: !controller ? 1
            : (controller.aiThinking ? aiColor : controller.userColor)
    readonly property int othColor: curColor === 1 ? 2 : 1
    // 头像/棋子组的整体放大倍数
    readonly property real uiScale: 1.95

    // 未开局：欢迎语
    Text {
        visible: !(controller && controller.started)
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("欢迎来到五子棋")
        color: "#FFDB9E"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 56
    }

    // 对局中的提示语
    Text {
        visible: controller && controller.started
        width: parent.width
        y: 10
        horizontalAlignment: Text.AlignHCenter
        text: controller && controller.gameStatus === 1
              ? qsTr("游戏结束！")
              : (controller && controller.aiThinking
                 ? qsTr("让我想想...")
                 : qsTr("请放置您的棋子..."))
        color: "#FFDB9E"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 56
    }

    // 双方头像 + 棋子颜色：保持桌面版 300x200 面板内的相对比例，整体放大
    Item {
        id: cluster
        width: 355
        height: 94
        anchors.horizontalCenter: parent.horizontalCenter
        // 以中心缩放，因此 y 按放大后的实际高度反推，避免顶部压到提示语
        y: 135
        scale: panel.uiScale
        transformOrigin: Item.Center

        // 当前棋手：底板 + 头像 + 棋子颜色
        Image {
            visible: controller && controller.started
            x: 0
            y: 0
            width: 131; height: 90
            source: "qrc:/ui/player_plate_current.png"
        }
        Image {
            visible: controller && controller.started
            x: 56
            y: 14
            width: 60; height: 60
            source: controller && controller.aiThinking
                    ? "qrc:/ui/avatar_ai_active.png"
                    : "qrc:/ui/avatar_user_active.png"
        }
        Image {
            visible: controller && controller.started
            x: 94
            y: 54
            width: 40; height: 40
            source: panel.curColor === 1 ? "qrc:/ui/badge_black.png" : "qrc:/ui/badge_white.png"
        }

        // 另一方
        Image {
            visible: controller && controller.started
            x: 264
            y: 0
            width: 78; height: 78
            source: "qrc:/ui/player_plate_other.png"
        }
        Image {
            visible: controller && controller.started
            x: 277
            y: 10
            width: controller && controller.aiThinking ? 48 : 50
            height: width
            source: controller && controller.aiThinking
                    ? "qrc:/ui/avatar_user_idle.png"
                    : "qrc:/ui/avatar_ai_idle.png"
        }
        Image {
            visible: controller && controller.started
            x: 315
            y: 38
            width: 40; height: 40
            source: panel.othColor === 1 ? "qrc:/ui/badge_black.png" : "qrc:/ui/badge_white.png"
        }
    }
}
