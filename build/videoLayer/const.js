"use strict";
// video layer控制相關常數
Object.defineProperty(exports, "__esModule", { value: true });
exports.EVideoLayerEvent = void 0;
/**
 * video layer IPC事件
 */
var EVideoLayerEvent;
(function (EVideoLayerEvent) {
    EVideoLayerEvent["setVideoLayerPosition"] = "setVideoLayerPosition";
    EVideoLayerEvent["setVideoLayerSize"] = "setVideoLayerSize";
    EVideoLayerEvent["onVideoLayerRequireResize"] = "onVideoLayerRequireResize"; // 後端請求前端回傳顯示區域大小
})(EVideoLayerEvent = exports.EVideoLayerEvent || (exports.EVideoLayerEvent = {}));
