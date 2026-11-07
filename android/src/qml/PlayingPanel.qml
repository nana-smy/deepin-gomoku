import QtQuick
import "Metrics.js" as M

// 右侧“对局详情”面板，复刻桌面版 PlayingScreen：
// 未开局显示“欢迎来到五子棋”，对局中显示提示语与双方头像/棋子，
// 所有偏移比例取自 playingscreen.h。
Item {
    id: panel
    width: M.PANEL_W
    height: controller && controller.started ? M.PANEL_H_GAME : M.PANEL_H_IDLE

    readonly property int side: 200 // 对局中的布局基准高度

    // 欢迎语：rectY + 59，字号 30
    Text {
        visible: !(controller && controller.started)
        width: parent.width
        y: 59
        horizontalAlignment: Text.AlignHCenter
        text: qsTr("欢迎来到五子棋")
        color: "#FFDB9E"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 30
    }

    // 对局中的提示语：rectY + 40，字号 24
    Text {
        visible: controller && controller.started
        width: parent.width
        y: 40
        horizontalAlignment: Text.AlignHCenter
        text: controller && controller.gameStatus === 1
              ? qsTr("游戏结束！")
              : (controller && controller.aiThinking
                 ? qsTr("让我想想...")
                 : qsTr("请放置您的棋子..."))
        color: "#FFDB9E"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 24
    }

    // 当前棋手：底板 + 头像 + 棋子颜色
    Image {
        visible: controller && controller.started
        x: parent.width * 0.0788
        y: side * 0.52
        width: 131; height: 90
        source: "qrc:/ui/player_plate_current.png"
    }
    Image {
        visible: controller && controller.started
        x: parent.width * 0.2663
        y: side * 0.59
        width: 60; height: 60
        source: controller && controller.aiThinking
                ? "qrc:/ui/avatar_ai_active.png"
                : "qrc:/ui/avatar_user_active.png"
    }
    Image {
        visible: controller && controller.started
        x: parent.width * 0.3920
        y: side * 0.79
        width: 40; height: 40
        source: (controller && ((controller.aiThinking && root.aiColor === 1)
                 || (!controller.aiThinking && controller.userColor === 1)))
                ? "qrc:/ui/badge_black.png"
                : "qrc:/ui/badge_white.png"
    }

    // 另一方
    Image {
        visible: controller && controller.started
        x: parent.width * 0.5578
        y: side * 0.6
        width: 78; height: 78
        source: "qrc:/ui/player_plate_other.png"
    }
    Image {
        visible: controller && controller.started
        x: parent.width * 0.6019
        y: side * 0.65
        width: controller && controller.aiThinking ? 48 : 50
        height: width
        source: controller && controller.aiThinking
                ? "qrc:/ui/avatar_user_idle.png"
                : "qrc:/ui/avatar_ai_idle.png"
    }
    Image {
        visible: controller && controller.started
        x: parent.width * 0.7278
        y: side * 0.79
        width: 40; height: 40
        source: (controller && ((controller.aiThinking && root.aiColor === 2)
                 || (!controller.aiThinking && controller.userColor === 2)))
                ? "qrc:/ui/badge_white.png"
                : "qrc:/ui/badge_black.png"
    }
}
