// SPDX-FileCopyrightText: 2025 UnionTech Software Technology Co., Ltd.
//
// SPDX-License-Identifier: GPL-3.0-or-later
//
// Android 移植版：替换原版对 DConfig / DLog（DTK）的依赖，
// 仅使用 QtCore 的 QLoggingCategory 提供同样的 appLog 日志类别。

#ifndef DDLOG_H
#define DDLOG_H

#include <QLoggingCategory>

namespace {
inline Q_LOGGING_CATEGORY(appLog, "com.deepin.gomoku")
}

#endif   // DDLOG_H
