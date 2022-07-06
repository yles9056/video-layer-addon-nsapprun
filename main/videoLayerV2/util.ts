import _ from "lodash";
import { logger } from "../util";
import { IVideoLayerLib } from "./interface";

let videoLayerLib: IVideoLayerLib | undefined = undefined;
try {
  videoLayerLib = require("../VideoLayerLibV2.node");
} catch (e) {
  logger.error(`Failed to load VideoLayerLibV2.node`);
}

/**
 * 警告video layer控制模組沒有正常載入
 */
function warnVideoLayerNotLoaded() {
  logger.warn("VideoLayer.node not loaded!");
}

export function getVideoLayerLib() {
  return videoLayerLib;
}

/**
 * 初始化video layer
 * @param bufferData bufferData為指向UI視窗的記憶體位置 可以轉換成NSView
 */
export function initVideoLayer(contextId: number, bufferData: Buffer) {
  if (_.isNil(videoLayerLib)) {
    warnVideoLayerNotLoaded();
    return;
  }

  videoLayerLib.initVideoLayer(contextId, bufferData);
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
  return new Promise<boolean>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve(false);
      return;
    }

    videoLayerLib.getCameraIsOpen((err, isCameraOpen) => {
      if (err) {
        reject(err);
      } else {
        resolve(isCameraOpen ? isCameraOpen : false);
      }
    });
  });
}

/**
 * 取得video layer控制模組正在使用攝影機的locationId
 * @returns
 */
export function getCameraLocationId() {
  return new Promise<string>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve("");
      return;
    }

    videoLayerLib.getCameraLocationId((err, cameraLocationId) => {
      if (err) {
        reject(err);
      } else {
        resolve(cameraLocationId ? cameraLocationId : "");
      }
    });
  });
}

/**
 * 指定video layer控制模組使用攝影機的locationId
 * @param locationId 攝影機的locationId
 * @returns
 */
export function setCameraLocationId(locationId: string) {
  return new Promise<string>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve("");
      return;
    }

    videoLayerLib.setCameraLocationId(locationId, (err, cameraLocationId) => {
      if (err) {
        reject(err);
      } else {
        resolve(cameraLocationId ? cameraLocationId : "");
      }
    });
  });
}

/**
 * 請求video layer控制模組開啟攝影機
 * @returns 執行成功則回傳`true`，否則`false`
 */
export function openCamera() {
  return new Promise<boolean>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve(false);
      return;
    }

    videoLayerLib.openCamera((err, isSuccessful) => {
      if (err) {
        reject(err);
      } else {
        resolve(isSuccessful ? isSuccessful : false);
      }
    });
  });
}

/**
 * 請求video layer控制模組關閉攝影機
 * @returns 執行成功則回傳`true`，否則`false`
 */
export function closeCamera() {
  return new Promise<boolean>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve(false);
      return;
    }

    videoLayerLib.closeCamera((err, isSuccessful) => {
      if (err) {
        reject(err);
      } else {
        resolve(isSuccessful ? isSuccessful : false);
      }
    });
  });
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
  return new Promise<string>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve("");
      return;
    }

    videoLayerLib.getCameraResolution((err, resolution) => {
      if (err) {
        reject(err);
      } else {
        resolve(resolution ? resolution : "");
      }
    });
  });
}

/**
 * 指定video layer控制模組使用
 * @param resolution 指定解析度，格式為: {width}x{height} 例如:`1280x720`
 * @returns 解析度，格式為: {width}x{height} 例如:`1280x720`
 */
export function setCameraResolution(resolution: string) {
  return new Promise<string>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve("");
      return;
    }

    videoLayerLib.setCameraResolution(resolution, (err, resolution) => {
      if (err) {
        reject(err);
      } else {
        resolve(resolution ? resolution : "");
      }
    });
  });
}

/**
 * 取得video layer顯示位置，原點為視窗左下角
 * @returns 位置座標，格式為: [x, y]
 */
export function getVideoLayerPosition() {
  return new Promise<[number, number]>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve([0, 0]);
      return;
    }

    videoLayerLib.getVideoLayerPosition((err, position) => {
      if (err) {
        reject(err);
      } else {
        resolve(position ? position : [0, 0]);
      }
    });
  });
}

/**
 * 設定video layer顯示位置，原點為視窗左下角
 * @param x x座標
 * @param y y座標
 * @returns 位置座標，格式為: [x, y]
 */
export function setVideoLayerPosition(x: number, y: number) {
  return new Promise<[number, number]>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve([0, 0]);
      return;
    }

    videoLayerLib.setVideoLayerPosition(x, y, (err, position) => {
      if (err) {
        reject(err);
      } else {
        resolve(position ? position : [0, 0]);
      }
    });
  });
}

/**
 * 取得video layer顯示大小
 * @returns 大小，格式為: [width, height]
 */
export function getVideoLayerSize() {
  return new Promise<[number, number]>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve([0, 0]);
      return;
    }

    videoLayerLib.getVideoLayerSize((err, size) => {
      if (err) {
        reject(err);
      } else {
        resolve(size ? size : [0, 0]);
      }
    });
  });
}

/**
 * 設定video layer顯示大小
 * @param width 寬度
 * @param height 高度
 * @returns 大小，格式為: [width, height]
 */
export function setVideoLayerSize(width: number, height: number) {
  return new Promise<[number, number]>((resolve, reject) => {
    if (_.isNil(videoLayerLib)) {
      warnVideoLayerNotLoaded();
      resolve([0, 0]);
      return;
    }

    videoLayerLib.setVideoLayerSize(width, height, (err, position) => {
      if (err) {
        reject(err);
      } else {
        resolve(position ? position : [0, 0]);
      }
    });
  });
}
