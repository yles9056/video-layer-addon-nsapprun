"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var electron_1 = require("electron");
var const_1 = require("./const");
electron_1.contextBridge.exposeInMainWorld('videoLayer', {
    setVideoLayerPosition: function (x, y) {
        electron_1.ipcRenderer.send(const_1.EVideoLayerEvent.setVideoLayerPosition, x, y);
    },
    setVideoLayerSize: function (width, height) {
        electron_1.ipcRenderer.send(const_1.EVideoLayerEvent.setVideoLayerSize, width, height);
    },
    onVideoLayerRequireResize: function (func) {
        var listener = function (event) {
            func();
        };
        electron_1.ipcRenderer.on(const_1.EVideoLayerEvent.onVideoLayerRequireResize, listener);
        return function () {
            electron_1.ipcRenderer.removeListener(const_1.EVideoLayerEvent.onVideoLayerRequireResize, listener);
        };
    }
});
