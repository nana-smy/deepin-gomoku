import QtQuick

// 竖屏顶部的对局信息区：把桌面版 PlayingScreen 的“提示语 + 双方头像/棋子”
// 从竖排改为横向紧凑布局，元素尺寸、贴图与配色与桌面版完全一致。
Item {
    id: panel
    width: 1024
    height: 230

    readonly property int aiColor: controller ? (controller.userColor === 1 ? 2 : 1) : 2
    // 当前思考方：AI 思考时是 AI，否则是玩家
    readonly property int curColor: !controller ? 1
            : (controller.aiThinking ? aiColor : controller.userColor)
    readonly property int othColor: curColor === 1 ? 2 : 1

    // 未开局：欢迎语（字号 30，同桌面版）
    Text {
        visible: !(controller && controller.started)
        width: parent.width
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("欢迎来到五子棋")
        color: "#FFDB9E"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 30
    }

    // 对局中的提示语（字号 32，竖屏略放大）
    Text {
        visible: controller && controller.started
        width: parent.width
        y: 8
        horizontalAlignment: Text.AlignHCenter
        text: controller && controller.gameStatus === 1
              ? qsTr("游戏结束！")
              : (controller && controller.aiThinking
                 ? qsTr("让我想想...")
                 : qsTr("请放置您的棋子..."))
        color: "#FFDB9E"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 32
    }

    // 当前棋手：底板 + 头像 + 棋子颜色（组宽 134）
    Image {
        visible: controller && controller.started
        x: 334
        y: 100
        width: 131; height: 90
        source: "qrc:/ui/player_plate_current.png"
    }
    Image {
        visible: controller && controller.started
        x: 334 + 56
        y: 100 + 14
        width: 60; height: 60
        source: controller && controller.aiThinking
                ? "qrc:/ui/avatar_ai_active.png"
                : "qrc:/ui/avatar_user_active.png"
    }
    Image {
        visible: controller && controller.started
        x: 334 + 94
        y: 100 + 54
        width: 40; height: 40
        source: curColor === 1 ? "qrc:/ui/badge_black.png" : "qrc:/ui/badge_white.png"
    }

    // 另一方（组宽 91）
    Image {
        visible: controller && controller.started
        x: 598
        y: 100
        width: 78; height: 78
        source: "qrc:/ui/player_plate_other.png"
    }
    Image {
        visible: controller && controller.started
        x: 598 + 13
        y: 100 + 10
        width: controller && controller.aiThinking ? 48 : 50
        height: width
        source: controller && controller.aiThinking
                ? "qrc:/ui/avatar_user_idle.png"
                : "qrc:/ui/avatar_ai_idle.png"
    }
    Image {
        visible: controller && controller.started
        x: 598 + 51
        y: 100 + 38
        width: 40; height: 40
        source: othColor === 1 ? "qrc:/ui/badge_black.png" : "qrc:/ui/badge_white.png"
    }
}
