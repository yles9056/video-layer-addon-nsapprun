"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.setVideoLayerSize = exports.getVideoLayerSize = exports.setVideoLayerPosition = exports.getVideoLayerPosition = exports.setCameraResolution = exports.getCameraResolution = exports.getSupportedResolution = exports.closeCamera = exports.openCamera = exports.setCameraLocationId = exports.getCameraLocationId = exports.getCameraIsOpen = exports.destroyVideoLayer = exports.initVideoLayer = exports.getVideoLayerLib = void 0;
var lodash_1 = __importDefault(require("lodash"));
var util_1 = require("../util");
var videoLayerLib = undefined;
try {
    videoLayerLib = require('../addon.node');
}
catch (e) {
    util_1.logger.error("Failed to load addon.node");
}
/**
 * 警告video layer控制模組沒有正常載入
 */
function warnVideoLayerNotLoaded() {
    util_1.logger.warn('VideoLayer.node not loaded!');
}
function getVideoLayerLib() {
    return videoLayerLib;
}
exports.getVideoLayerLib = getVideoLayerLib;
/**
 * 初始化video layer
 * @param bufferData bufferData為指向UI視窗的記憶體位置 可以轉換成NSView
 */
function initVideoLayer(bufferData) {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return;
    }
    videoLayerLib.initVideoLayer(bufferData);
}
exports.initVideoLayer = initVideoLayer;
/**
 * 摧毀video layer
 */
function destroyVideoLayer() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return;
    }
    videoLayerLib.destroyVideoLayer();
}
exports.destroyVideoLayer = destroyVideoLayer;
/**
 * video layer控制模組是否正在使用攝影機
 * @returns
 */
function getCameraIsOpen() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return false;
    }
    return videoLayerLib.getCameraIsOpen();
}
exports.getCameraIsOpen = getCameraIsOpen;
/**
 * 取得video layer控制模組正在使用攝影機的locationId
 * @returns
 */
function getCameraLocationId() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return '';
    }
    /*logger.debug('isture');
    let strid = videoLayerLib.getCameraLocationId();
    logger.debug('strid:',strid);*/
    return videoLayerLib.getCameraLocationId();
    //return strid;
}
exports.getCameraLocationId = getCameraLocationId;
/**
 * 指定video layer控制模組使用攝影機的locationId
 * @param locationId 攝影機的locationId
 * @returns
 */
function setCameraLocationId(locationId) {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return '';
    }
    return videoLayerLib.setCameraLocationId(locationId);
}
exports.setCameraLocationId = setCameraLocationId;
/**
 * 請求video layer控制模組開啟攝影機
 * @returns 執行成功則回傳`true`，否則`false`
 */
function openCamera() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return false;
    }
    util_1.logger.debug('Call openCamera in addon.cpp');
    return videoLayerLib.openCamera();
}
exports.openCamera = openCamera;
/**
 * 請求video layer控制模組關閉攝影機
 * @returns 執行成功則回傳`true`，否則`false`
 */
function closeCamera() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return false;
    }
    return videoLayerLib.closeCamera();
}
exports.closeCamera = closeCamera;
/**
 * 列舉video layer控制模組能支援的解析度字串
 * @returns
 */
function getSupportedResolution() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return [];
    }
    return videoLayerLib.getSupportedResolution();
}
exports.getSupportedResolution = getSupportedResolution;
/**
 * 取得video layer控制模組目前正在使用的解析度
 * @returns 解析度，格式為: {width}x{height} 例如:`1280x720`
 */
function getCameraResolution() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return '';
    }
    return videoLayerLib.getCameraResolution();
}
exports.getCameraResolution = getCameraResolution;
/**
 * 指定video layer控制模組使用
 * @param resolution 指定解析度，格式為: {width}x{height} 例如:`1280x720`
 * @returns 解析度，格式為: {width}x{height} 例如:`1280x720`
 */
function setCameraResolution(resolution) {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return '';
    }
    return videoLayerLib.setCameraResolution(resolution);
}
exports.setCameraResolution = setCameraResolution;
/**
 * 取得video layer顯示位置，原點為視窗左下角
 * @returns 位置座標，格式為: [x, y]
 */
function getVideoLayerPosition() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return [0, 0];
    }
    return videoLayerLib.getVideoLayerPosition();
}
exports.getVideoLayerPosition = getVideoLayerPosition;
/**
 * 設定video layer顯示位置，原點為視窗左下角
 * @param x x座標
 * @param y y座標
 * @returns 位置座標，格式為: [x, y]
 */
function setVideoLayerPosition(x, y) {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return [0, 0];
    }
    else if (!lodash_1.default.isNumber(x) || !lodash_1.default.isNumber(y)) {
        util_1.logger.warn("setVideoLayerPosition arguments must be number ".concat(x, " ").concat(y));
        return [0, 0];
    }
    return videoLayerLib.setVideoLayerPosition(x, y);
}
exports.setVideoLayerPosition = setVideoLayerPosition;
/**
 * 取得video layer顯示大小
 * @returns 大小，格式為: [width, height]
 */
function getVideoLayerSize() {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return [0, 0];
    }
    return videoLayerLib.getVideoLayerSize();
}
exports.getVideoLayerSize = getVideoLayerSize;
/**
 * 設定video layer顯示大小
 * @param width 寬度
 * @param height 高度
 * @returns 大小，格式為: [width, height]
 */
function setVideoLayerSize(width, height) {
    if (lodash_1.default.isNil(videoLayerLib)) {
        warnVideoLayerNotLoaded();
        return [0, 0];
    }
    else if (!lodash_1.default.isNumber(width) || !lodash_1.default.isNumber(height)) {
        util_1.logger.warn("setVideoLayerSize arguments must be number ".concat(width, " ").concat(height));
        return [0, 0];
    }
    return videoLayerLib.setVideoLayerSize(width, height);
}
exports.setVideoLayerSize = setVideoLayerSize;
