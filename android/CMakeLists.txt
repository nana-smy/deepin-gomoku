# deepin-gomoku —— Android 移植版构建脚本
# 复用桌面版的 C++ 棋局核心逻辑，UI 改为 Qt Quick / QML。
# 构建要求：Qt for Android (6.x) + Android SDK + NDK，或直接在 GitHub Actions 中构建。

cmake_minimum_required(VERSION 3.16)
project(deepin-gomoku VERSION 1.2.2 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick Gui Multimedia)

# QML 文件随 qrc 编译进应用，运行期由 QQmlApplicationEngine 加载，
# 无需额外的 QML 预编译（qmlcachegen），从而不依赖宿主 Qt 工具链。
qt_add_executable(deepin-gomoku
    src/main.cpp
    src/gamecontroller.cpp
    src/game/artificialintelligence/artificialintelligence.cpp
    src/game/artificialintelligence/calculatescore.cpp
    src/game/artificialintelligence/chessfromjudge.cpp
    src/game/gamecontrol/checkerboard.cpp
    src/game/gamecontrol/gamecontrol.cpp
    app.qrc
)

target_include_directories(deepin-gomoku PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/game
)

target_link_libraries(deepin-gomoku PRIVATE
    Qt6::Quick
    Qt6::Gui
    Qt6::Multimedia
)

# Android 打包配置：使用本目录下 android/ 中的 AndroidManifest.xml 等部署文件
set_target_properties(deepin-gomoku PROPERTIES
    QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
)

# 构建完成后目标：cmake --build . --target apk （或 aab）
