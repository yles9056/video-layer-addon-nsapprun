"use strict";
// video layer控制相關IPC事件處理
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupVideoLayerIpc = void 0;
var util_1 = require("../util");
var const_1 = require("./const");
var util_2 = require("./util");
/**
 * 設定video layer控制相關IPC事件處理
 * @param ipcMain 主程序的ipcMain
 * @param mainWindow 主視窗
 */
function setupVideoLayerIpc(ipcMain, mainWindow) {
    /**
     * 請求前端回傳顯示區域大小
     */
    var sendVideoLayerRequireResize = function () {
        mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.webContents.send(const_1.EVideoLayerEvent.onVideoLayerRequireResize);
    };
    // 視窗正在改變大小時，先隱藏video layer
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('resize', function () {
        (0, util_2.setVideoLayerSize)(0, 0);
    });
    // 視窗大小改變後，請求前端回傳顯示區域大小
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('resized', function () {
        sendVideoLayerRequireResize();
    });
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('maximize', function () {
        sendVideoLayerRequireResize();
    });
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('unmaximize', function () {
        sendVideoLayerRequireResize();
    });
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('restore', function () {
        sendVideoLayerRequireResize();
    });
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('enter-full-screen', function () {
        sendVideoLayerRequireResize();
    });
    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.on('leave-full-screen', function () {
        sendVideoLayerRequireResize();
    });
    // 前端請求設定video layer位置
    ipcMain.on(const_1.EVideoLayerEvent.setVideoLayerPosition, function (event, x, y) {
        util_1.logger.verbose("Receive ".concat(const_1.EVideoLayerEvent.setVideoLayerPosition, " ").concat(x, " ").concat(y));
        (0, util_2.setVideoLayerPosition)(x, y);
    });
    // 前端請求設定video layer大小
    ipcMain.on(const_1.EVideoLayerEvent.setVideoLayerSize, function (event, width, height) {
        util_1.logger.verbose("Receive ".concat(const_1.EVideoLayerEvent.setVideoLayerSize, " ").concat(width, " ").concat(height));
        (0, util_2.setVideoLayerSize)(width, height);
    });
}
exports.setupVideoLayerIpc = setupVideoLayerIpc;
