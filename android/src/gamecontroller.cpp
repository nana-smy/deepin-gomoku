// SPDX-FileCopyrightText: 2026 deepin-gomoku android port
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "gamecontroller.h"
#include "ddlog.h"

#include <QDebug>

GameController::GameController(QObject *parent)
    : QObject(parent)
    , m_game(nullptr)
    , m_userColor(chess_black)
    , m_aiColor(chess_white)
    , m_gameStatus(0)
    , m_winner(0)
    , m_aiThinking(false)
{
    m_game = new GameControl(m_aiColor, m_userColor, this);

    connect(m_game, &GameControl::AIPlayChess,
            this, &GameController::onAIPlayChess);
    connect(m_game, &GameControl::isAIPlaying,
            this, &GameController::onIsAIPlaying);
    connect(m_game, &GameControl::gameOver,
            this, &GameController::onGameOver);
}

GameController::~GameController()
{
    qCDebug(appLog) << "GameController destroyed";
}

int GameController::userColor() const
{
    return m_userColor;
}

void GameController::setUserColor(int color)
{
    if (m_userColor == color)
        return;
    m_userColor = color;
    m_aiColor = (color == chess_black) ? chess_white : chess_black;
    emit userColorChanged();
}

bool GameController::aiThinking() const
{
    return m_aiThinking;
}

int GameController::gameStatus() const
{
    return m_gameStatus;
}

int GameController::winner() const
{
    return m_winner;
}

bool GameController::started() const
{
    return m_started;
}

bool GameController::paused() const
{
    return m_paused;
}

int GameController::cell(int row, int col) const
{
    if (!m_game)
        return chess_none;
    const ChessState &state = m_game->checkerboardState();
    if (row < 0 || row >= line_row || col < 0 || col >= line_col)
        return chess_none;
    return state[row][col];
}

void GameController::newGame(int color)
{
    setUserColor(color);
    m_aiColor = (color == chess_black) ? chess_white : chess_black;

    if (m_game) {
        delete m_game;
        m_game = nullptr;
    }
    m_game = new GameControl(m_aiColor, m_userColor, this);
    connect(m_game, &GameControl::AIPlayChess, this, &GameController::onAIPlayChess);
    connect(m_game, &GameControl::isAIPlaying, this, &GameController::onIsAIPlaying);
    connect(m_game, &GameControl::gameOver, this, &GameController::onGameOver);

    m_gameStatus = 0;
    m_winner = 0;
    m_aiThinking = false;
    m_paused = false;
    m_hasPendingAI = false;
    m_started = true;
    emit gameStatusChanged();
    emit winnerChanged();
    emit aiThinkingChanged(false);
    emit pausedChanged();
    emit startedChanged();

    m_game->startGame();
    emit boardChanged();
}

void GameController::userMove(int row, int col)
{
    if (!m_started || m_paused || m_gameStatus != 0 || !m_game || m_aiThinking)
        return;
    // 该位置已有棋子则不响应
    if (cell(row, col) != chess_none)
        return;

    Chess userChess(row, col, m_userColor);
    emit movePlayed(row, col, m_userColor);
    emit boardChanged();
    m_game->chessCompleted(userChess);
}

void GameController::resetGame()
{
    if (!m_game)
        return;
    m_gameStatus = 0;
    m_winner = 0;
    m_aiThinking = false;
    m_paused = false;
    m_hasPendingAI = false;
    emit gameStatusChanged();
    emit winnerChanged();
    emit aiThinkingChanged(false);
    emit pausedChanged();
    m_game->resetGame();
    emit boardChanged();
}

void GameController::resetAll()
{
    m_gameStatus = 0;
    m_winner = 0;
    m_aiThinking = false;
    m_paused = false;
    m_hasPendingAI = false;
    m_started = false;
    if (m_game)
        m_game->resetGame();
    emit gameStatusChanged();
    emit winnerChanged();
    emit aiThinkingChanged(false);
    emit pausedChanged();
    emit startedChanged();
    emit boardChanged();
}

void GameController::setPaused(bool paused)
{
    if (m_paused == paused)
        return;
    m_paused = paused;
    emit pausedChanged();
    // 暂停期间 AI 已算好落子：继续时补画并继续对局
    if (!m_paused && m_hasPendingAI) {
        Chess chess = m_pendingAI;
        m_hasPendingAI = false;
        applyAIMove(chess);
    }
}

void GameController::applyAIMove(const Chess &chess)
{
    emit movePlayed(chess.x, chess.y, chess.color);
    emit boardChanged();
    m_game->chessCompleted(chess);
}

void GameController::onAIPlayChess(const Chess &chess)
{
    // 暂停状态下先记住落子，继续时再落子
    if (m_paused) {
        m_pendingAI = chess;
        m_hasPendingAI = true;
        return;
    }
    applyAIMove(chess);
}

void GameController::onIsAIPlaying(bool aiPlaying)
{
    m_aiThinking = aiPlaying;
    emit aiThinkingChanged(m_aiThinking);
}

void GameController::onGameOver(ChessResult result)
{
    m_gameStatus = 1;
    switch (result) {
    case black_win:
        m_winner = chess_black;
        break;
    case white_win:
        m_winner = chess_white;
        break;
    case tie:
        m_winner = 3;
        break;
    default:
        m_winner = 0;
        break;
    }
    m_aiThinking = false;
    emit gameStatusChanged();
    emit winnerChanged();
    emit aiThinkingChanged(false);
}
