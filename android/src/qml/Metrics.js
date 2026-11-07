.pragma library

// 桌面版 GomokuMainWindow 为 1024x768，标题栏 50px，QGraphicsScene 区域为 1024x718。
// 下列比例全部取自桌面版源码（checkerboardscene.h / checkerboarditem.h /
// buttonitem.h / btreplay.h / btstartpause.h / btmusiccontrol.h / playingscreen.h），
// Android 版按同一套逻辑坐标绘制，再整体缩放到屏幕。

var W = 1024;
var H = 718;

var BOARD_X = W * 0.02;        // 20.48
var BOARD_Y = H * 0.007;       // 5.03
var BOARD = 694;
var MARGIN = 60;               // (694 - 41 * 14) / 2
var GAP = 41;
var LINES = 15;

var PANEL_X = W * 0.7;         // 716.8
var PANEL_Y = H * 0.005;       // 3.59
var PANEL_W = 300;
var PANEL_H_IDLE = 100;
var PANEL_H_GAME = 200;

var BTN_X = W * 0.74;          // 757.76
var BTN_W = 204;
var BTN_H = 64;
var BTN_START_IDLE = H * 0.2314;   // 166.14
var BTN_START_GAME = H * 0.333;    // 239.09
var BTN_REPLAY_IDLE = H * 0.3425;  // 245.91
var BTN_REPLAY_GAME = H * 0.444;   // 318.79
var BTN_MUSIC = H * 0.765;         // 549.27

// 棋子中心 = 棋盘原点 + 边距 + 线距 * 序号
function stoneX(col) { return BOARD_X + MARGIN + GAP * col; }
function stoneY(row) { return BOARD_Y + MARGIN + GAP * row; }
