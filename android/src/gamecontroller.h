// SPDX-FileCopyrightText: 2026 deepin-gomoku android port
//
// SPDX-License-Identifier: GPL-3.0-or-later
//
// GameController：QML 与核心棋局逻辑（GameControl / Checkerboard / AI）之间的桥接层。
// 复用自 deepin-gomoku 桌面版的核心规则，仅替换了 UI 接入方式。

#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>

#include "constants.h"
#include "game/gamecontrol/gamecontrol.h"

class GameController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int userColor READ userColor WRITE setUserColor NOTIFY userColorChanged)
    Q_PROPERTY(bool aiThinking READ aiThinking NOTIFY aiThinkingChanged)
    Q_PROPERTY(int gameStatus READ gameStatus NOTIFY gameStatusChanged)
    Q_PROPERTY(int winner READ winner NOTIFY winnerChanged)
    // 是否已开局（对应桌面版“欢迎”/“开局”两种界面状态）
    Q_PROPERTY(bool started READ started NOTIFY startedChanged)
    // 是否暂停（对应桌面版开始/暂停按钮）
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)

public:
    explicit GameController(QObject *parent = nullptr);
    ~GameController() override;

    int userColor() const;
    void setUserColor(int color);

    // 是否轮到 AI 落子（AI 思考中）
    bool aiThinking() const;
    // 0=对局中 1=已结束
    int gameStatus() const;
    // 1=黑胜 2=白胜 3=平局 0=未结束
    int winner() const;
    bool started() const;
    bool paused() const;
    // 暂停/继续（继续时若 AI 已算好落子，补画该子）
    Q_INVOKABLE void setPaused(bool paused);

    // 供 QML 查询棋格颜色：0 空、1 黑、2 白
    Q_INVOKABLE int cell(int row, int col) const;

    // 开始一局新游戏，color 为用户棋子颜色
    Q_INVOKABLE void newGame(int color);
    // 用户在某交叉点落子
    Q_INVOKABLE void userMove(int row, int col);
    // 重开一局（沿用当前颜色）
    Q_INVOKABLE void resetGame();
    // 清空当前棋局并返回主页前的清理
    Q_INVOKABLE void resetAll();

signals:
    void userColorChanged();
    void aiThinkingChanged(bool thinking);
    void gameStatusChanged();
    void winnerChanged();
    void startedChanged();
    void pausedChanged();
    // 棋盘状态变化（供 QML 重绘）
    void boardChanged();
    // 某方落下棋子（供音效/动效），color: 1黑 2白
    void movePlayed(int row, int col, int color);

private slots:
    void onAIPlayChess(const Chess &chess);
    void onIsAIPlaying(bool aiPlaying);
    void onGameOver(ChessResult result);

private:
    GameControl *m_game;
    int m_userColor;
    int m_aiColor;
    int m_gameStatus; // 0 对局中 1 结束
    int m_winner;     // 0 无 1 黑 2 白 3 平
    bool m_aiThinking;
    bool m_started = false;
    bool m_paused = false;
    // 暂停期间 AI 算出的落子先暂存，继续时再落到棋盘上
    Chess m_pendingAI{-1, -1, 0};
    bool m_hasPendingAI = false;
    void applyAIMove(const Chess &chess);
};

#endif // GAMECONTROLLER_H
