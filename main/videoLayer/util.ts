import _ from 'lodash';
import { logger } from '../util';
import { IVideoLayerLib } from './interface';

let videoLayerLib: IVideoLayerLib | undefined = undefined;
try {
  videoLayerLib = require('../addon.node');
} catch (e) {
  logger.error(`Failed to load addon.node`);
}

/**
 * 警告video layer控制模組沒有正常載入
 */
function warnVideoLayerNotLoaded() {
  logger.warn('VideoLayer.node not loaded!');
}

export function getVideoLayerLib() {
  return videoLayerLib;
}

/**
 * 初始化video layer
 * @param bufferData bufferData為指向UI視窗的記憶體位置 可以轉換成NSView
 */
export function initVideoLayer(bufferData: Buffer) {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return;
  }

  videoLayerLib.initVideoLayer(bufferData);
}

/**
 * 摧毀video layer
 */
export function destroyVideoLayer() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return;
  }

  videoLayerLib.destroyVideoLayer();
}

/**
 * video layer控制模組是否正在使用攝影機
 * @returns
 */
export function getCameraIsOpen() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return false;
  }

  return videoLayerLib.getCameraIsOpen();
}

/**
 * 取得video layer控制模組正在使用攝影機的locationId
 * @returns
 */
export function getCameraLocationId() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return '';
  }
  /*logger.debug('isture');
  let strid = videoLayerLib.getCameraLocationId();
  logger.debug('strid:',strid);*/
  return videoLayerLib.getCameraLocationId();
  //return strid;
}

/**
 * 指定video layer控制模組使用攝影機的locationId
 * @param locationId 攝影機的locationId
 * @returns
 */
export function setCameraLocationId(locationId: string) {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return '';
  }

  return videoLayerLib.setCameraLocationId(locationId);
}

/**
 * 請求video layer控制模組開啟攝影機
 * @returns 執行成功則回傳`true`，否則`false`
 */
export function openCamera() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return false;
  }
  logger.debug('Call openCamera in addon.cpp');
  return videoLayerLib.openCamera();
}

/**
 * 請求video layer控制模組關閉攝影機
 * @returns 執行成功則回傳`true`，否則`false`
 */
export function closeCamera() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return false;
  }

  return videoLayerLib.closeCamera();
}

/**
 * 列舉video layer控制模組能支援的解析度字串
 * @returns
 */
export function getSupportedResolution() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return [];
  }

  return videoLayerLib.getSupportedResolution();
}

/**
 * 取得video layer控制模組目前正在使用的解析度
 * @returns 解析度，格式為: {width}x{height} 例如:`1280x720`
 */
export function getCameraResolution() {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return '';
  }

  return videoLayerLib.getCameraResolution();
}

/**
 * 指定video layer控制模組使用
 * @param resolution 指定解析度，格式為: {width}x{height} 例如:`1280x720`
 * @returns 解析度，格式為: {width}x{height} 例如:`1280x720`
 */
export function setCameraResolution(resolution: string) {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return '';
  }

  return videoLayerLib.setCameraResolution(resolution);
}

/**
 * 取得video layer顯示位置，原點為視窗左下角
 * @returns 位置座標，格式為: [x, y]
 */
export function getVideoLayerPosition(): [number, number] {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return [0, 0];
  }

  return videoLayerLib.getVideoLayerPosition();
}

/**
 * 設定video layer顯示位置，原點為視窗左下角
 * @param x x座標
 * @param y y座標
 * @returns 位置座標，格式為: [x, y]
 */
export function setVideoLayerPosition(x: number, y: number): [number, number] {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return [0, 0];
  } else if (!_.isNumber(x) || !_.isNumber(y)) {
    logger.warn(`setVideoLayerPosition arguments must be number ${x} ${y}`);
    return [0, 0];
  }

  return videoLayerLib.setVideoLayerPosition(x, y);
}

/**
 * 取得video layer顯示大小
 * @returns 大小，格式為: [width, height]
 */
export function getVideoLayerSize(): [number, number] {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return [0, 0];
  }

  return videoLayerLib.getVideoLayerSize();
}

/**
 * 設定video layer顯示大小
 * @param width 寬度
 * @param height 高度
 * @returns 大小，格式為: [width, height]
 */
export function setVideoLayerSize(width: number, height: number): [number, number] {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return [0, 0];
  } else if (!_.isNumber(width) || !_.isNumber(height)) {
    logger.warn(`setVideoLayerSize arguments must be number ${width} ${height}`);
    return [0, 0];
  }

  return videoLayerLib.setVideoLayerSize(width, height);
}
