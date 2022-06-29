"use strict";
// camera控制相關IPC事件處理
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupCameraIpc = void 0;
var lodash_1 = __importDefault(require("lodash"));
var util_1 = require("../util");
var util_2 = require("../videoLayer/util");
var const_1 = require("./const");
var util_3 = require("./util");
/**
 * 整理攝影機清單以便回傳給前端
 * @returns
 */
function _getCameras() {
    var cameras = (0, util_3.getCameras)();
    // logger.debug('start _getCamera in ipc.ts and set locationID');
    var intLocationId = "0x14200000047d80b4";
    (0, util_2.setCameraLocationId)(intLocationId);
    var currentCameraLocationId = (0, util_2.getCameraLocationId)();
    util_1.logger.debug('get locationId and print it');
    util_1.logger.debug(currentCameraLocationId);
    var camerasUI = lodash_1.default.map(cameras, function (camera, index) {
        return __assign(__assign({}, camera), { id: index.toString(), isChecked: camera.path === currentCameraLocationId // 目前正在使用的攝影機為true，其餘為false
         });
    });
    return camerasUI;
}
/**
 * 設定camera控制相關IPC事件處理
 * @param ipcMain 主程序的ipcMain
 * @param mainWindow 主視窗
 */
function setupCameraIpc(ipcMain, mainWindow) {
    // 前端請求打開攝影機
    ipcMain.on(const_1.ECameraEvent.openCamera, function (event) {
        util_1.logger.debug("Receive ".concat(const_1.ECameraEvent.openCamera));
        //setCameraResolution('1280x720'); // 設定解析度
        (0, util_2.openCamera)(); // 開啟攝影機
    });
    // 前端請求關閉攝影機
    ipcMain.on(const_1.ECameraEvent.closeCamera, function (event) {
        util_1.logger.debug("Receive ".concat(const_1.ECameraEvent.closeCamera));
        (0, util_2.closeCamera)(); // 關閉攝影機
    });
    // 前端請求獲取攝影機清單
    ipcMain.handle(const_1.ECameraEvent.getCameras, function (event) {
        util_1.logger.debug("Receive ".concat(const_1.ECameraEvent.getCameras));
        return _getCameras();
    });
    // 前端請求設定攝影機
    ipcMain.handle(const_1.ECameraEvent.setCamera, function (event, locationId) {
        util_1.logger.debug("Receive ".concat(const_1.ECameraEvent.setCamera, " ").concat(locationId));
        if (lodash_1.default.isString(locationId)) {
            (0, util_2.setCameraLocationId)(locationId);
        }
        return _getCameras();
    });
}
exports.setupCameraIpc = setupCameraIpc;
