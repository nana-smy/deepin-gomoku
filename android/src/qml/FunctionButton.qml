import QtQuick
import "Metrics.js" as M

// 右下角功能按钮，复刻桌面版 ButtonItem：
// 背景三态贴图 204x64，图标 24x24 在 (0.147w, 0.3125h)，文字基线在 (0.372w, 0.646h)。
Item {
    id: btn
    width: M.BTN_W
    height: M.BTN_H

    property string label: ""
    property string iconSource: ""
    property bool down: mouse.pressed
    property bool interactive: true
    // 图标与文字相对贴图的放大倍数（竖屏手机像素密度高，需要更大的字）
    property real uiScale: 1

    signal clicked()

    Image {
        anchors.fill: parent
        smooth: true
        source: btn.down ? "qrc:/ui/btn_press.png"
                        : (mouse.containsMouse ? "qrc:/ui/btn_hover.png" : "qrc:/ui/btn_normal.png")
    }

    Image {
        x: parent.width * 0.147
        y: parent.height * 0.3125
        width: 24 * btn.uiScale
        height: 24 * btn.uiScale
        smooth: true
        source: btn.iconSource
    }

    TextMetrics {
        id: metrics
        font: labelText.font
        text: labelText.text
    }

    Text {
        id: labelText
        x: parent.width * 0.372
        // 桌面版用画文字的基线定位（QPainter::drawText(QPointF)）
        y: parent.height * 0.646 - metrics.ascent
        width: parent.width - x - 8
        text: btn.label
        elide: Text.ElideRight
        color: btn.down ? "#FFDB9E" : "#024526"
        font.family: "Resource Han Rounded CN"
        font.weight: Font.Black
        font.pixelSize: 22 * btn.uiScale
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: btn.interactive
        onClicked: btn.clicked()
    }
}
