# deepin-gomoku · Android 移植版

将 deepin Linux 桌面的五子棋（Gomoku）移植到安卓平台。

**技术路线**：Qt for Android。复用桌面版的 C++ 棋局核心逻辑（AI、规则、棋盘状态），
用 Qt Quick / QML 重写移动端界面，移除仅 Linux 可用的 DTK（Deepin 工具包）与 D-Bus 依赖。

## 移植说明

| 模块 | 桌面版 | 安卓版 |
|---|---|---|
| 棋局核心（AI / 规则 / 棋盘） | `gomoku/src/game/` | 原样复用 → `android/src/game/` |
| 日志 `ddlog.h` | 依赖 `DConfig` / `DLog`（DTK） | 替换为纯 QtCore 的 `QLoggingCategory` |
| 界面层 | `QtWidgets` + DTK | Qt Quick / QML 重写 |
| 系统集成 | D-Bus（`com.deepin.wm`） | 移除 |
| 音效 | Qt Multimedia | Qt Multimedia（`SoundEffect`） |

核心棋局逻辑与界面完全分离，因此移植后棋力与桌面版一致。

## 目录结构

```
android/
├── CMakeLists.txt            # Qt6 + Android 构建脚本
├── app.qrc                   # QML + 字体 + 音效资源
├── android/
│   └── AndroidManifest.xml   # 安卓打包清单（org.deepin.gomoku）
├── src/
│   ├── main.cpp              # 入口：加载字体、注入 GameController
│   ├── gamecontroller.{h,cpp}# QML <-> 核心逻辑 桥接
│   ├── game/                 # 复用自桌面版的棋局核心（GPL-3.0）
│   │   ├── artificialintelligence/
│   │   └── gamecontrol/
│   ├── constants.h / pub.h / ddlog.h
│   └── qml/                  # 移动端界面
│       ├── main.qml          # 页面导航
│       ├── HomeScreen.qml    # 首页
│       ├── SelectColorScreen.qml # 选择执黑/执白
│       ├── GameScreen.qml    # 对局界面
│       ├── BoardCanvas.qml   # 棋盘绘制与触控
│       ├── ResultPopup.qml   # 结算弹窗
│       └── RoundButton.qml   # 通用按钮
└── resources/                # 复用自桌面版（字体 + 落子/胜负音效）
```

## 在本地构建 APK

需要安装：
- **Qt for Android 6.x**（含 `qtmultimedia`）
- **Android SDK** + **NDK r26** + **JDK 17**
- CMake、Ninja

```bash
qt-cmake -S android -B build \
  -DCMAKE_BUILD_TYPE=Release \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-23 \
  -DANDROID_SDK_ROOT=$ANDROID_SDK_ROOT \
  -DANDROID_NDK_ROOT=$ANDROID_NDK_ROOT

cmake --build build --target apk --parallel
# 产物：build/android-build/build/outputs/apk/debug/*.apk
```

## 自动构建（GitHub Actions）

仓库根目录 `.github/workflows/android-build.yml` 会在以下时机自动构建 `arm64-v8a` 的 debug APK
并上传为 Actions artifact，可直接下载安装到安卓手机：

- push 或 PR 修改了 `android/**` 或该工作流文件
- 在 Actions 页面手动触发（`workflow_dispatch`）

下载路径：**Actions → “Build Android APK” → 最新一次运行 → Artifacts → 下载 APK**。

## 版权

沿用上游许可：`GPL-3.0-or-later`，版权归 UnionTech（统信软件）及原 deepin-gomoku 贡献者。
