"use strict";
// camera控制相關常數
Object.defineProperty(exports, "__esModule", { value: true });
exports.ECameraEvent = void 0;
/**
 * camera IPC事件
 */
var ECameraEvent;
(function (ECameraEvent) {
    ECameraEvent["openCamera"] = "openCamera";
    ECameraEvent["closeCamera"] = "closeCamera";
    ECameraEvent["getCameras"] = "getCameras";
    ECameraEvent["setCamera"] = "setCamera"; // 前端請求設定攝影機
})(ECameraEvent = exports.ECameraEvent || (exports.ECameraEvent = {}));
