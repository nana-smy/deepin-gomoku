import QtQuick
import QtQuick.Window

Window {
    id: root
    visible: true
    width: 480
    height: 820
    color: "#1e2119"

    // 安卓上全屏显示；桌面端保持可调窗口便于调试
    visibility: Qt.platform.os === "android" ? Window.FullScreen : Window.AutomaticVisibility
    title: qsTr("Gomoku 五子棋")

    // 页面导航状态
    property string page: "home"

    // 木质背景
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#3b3227" }
            GradientStop { position: 0.55; color: "#2b251c" }
            GradientStop { position: 1.0; color: "#201b14" }
        }
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        sourceComponent: page === "home" ? homeComp
                       : page === "select" ? selectComp
                       : gameComp

        Component {
            id: homeComp
            HomeScreen {
                onStart: root.page = "select"
            }
        }
        Component {
            id: selectComp
            SelectColorScreen {
                onBack: root.page = "home"
                onColorChosen: function (color) {
                    controller.newGame(color)
                    root.page = "game"
                }
            }
        }
        Component {
            id: gameComp
            GameScreen {
                onExit: {
                    controller.resetAll()
                    root.page = "home"
                }
            }
        }
    }
}
