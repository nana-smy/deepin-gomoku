// SPDX-FileCopyrightText: 2026 deepin-gomoku android port
//
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Android 移植入口：使用 Qt Quick 承载移动端界面，
// 复用自 deepin-gomoku 桌面版的 C++ 棋局核心逻辑。

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFont>
#include <QFontDatabase>
#include <QDir>
#include <QUrl>

#include "ddlog.h"
#include "gamecontroller.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    app.setOrganizationName("deepin");
    app.setApplicationName("deepin-gomoku");
    app.setApplicationVersion("1.2.2");

    // 加载内置圆角中文字体（与桌面版一致），避免安卓系统字体不一致
    const int fontId = QFontDatabase::addApplicationFont(":/resources/font/ResourceHanRoundedCN-Bold.ttf");
    if (fontId != -1) {
        const QStringList families = QFontDatabase::applicationFontFamilies(fontId);
        if (!families.isEmpty())
            app.setFont(QFont(families.first()));
    }

    qmlRegisterType<GameController>("DeepinGomoku", 1, 0, "GameController");

    QQmlApplicationEngine engine;
    // 将唯一的游戏控制器作为全局上下文属性注入，供所有界面访问
    auto *controller = new GameController(&engine);
    engine.rootContext()->setContextProperty(QStringLiteral("controller"), controller);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        qCCritical(appLog) << "Failed to load QML main window";
        return -1;
    }

    return app.exec();
}
