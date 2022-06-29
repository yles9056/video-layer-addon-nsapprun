"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var electron_1 = require("electron");
var const_1 = require("./const");
electron_1.contextBridge.exposeInMainWorld('camera', {
    openCamera: function () {
        electron_1.ipcRenderer.send(const_1.ECameraEvent.openCamera);
    },
    closeCamera: function () {
        electron_1.ipcRenderer.send(const_1.ECameraEvent.closeCamera);
    },
    getCameras: function () {
        return electron_1.ipcRenderer.invoke(const_1.ECameraEvent.getCameras);
    },
    setCamera: function (locationId) {
        return electron_1.ipcRenderer.invoke(const_1.ECameraEvent.setCamera, locationId);
    }
});
