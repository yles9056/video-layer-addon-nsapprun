// camera控制相關IPC事件處理

import { BrowserWindow, IpcMain } from "electron";
import _ from "lodash";
import { logger } from "../util";
import {
  getCameraLocationId,
  openCamera,
  closeCamera,
  setCameraLocationId,
} from "../videoLayerV1/util";
import { ECameraEvent } from "./const";
import { ICamInfoUI } from "./interface";
import { getCameras } from "./util";

/**
 * 整理攝影機清單以便回傳給前端
 * @returns
 */
function _getCameras() {
  let cameras = getCameras();
  // logger.debug('start _getCamera in ipc.ts and set locationID');
  //let intLocationId =  "0x14100000047d80c5";
  //setCameraLocationId(intLocationId);
  let currentCameraLocationId = getCameraLocationId();
  logger.debug("get locationId and print it");
  logger.debug(currentCameraLocationId);
  let camerasUI = _.map(cameras, (camera, index) => {
    return {
      ...camera,
      id: index.toString(),
      isChecked: camera.path === currentCameraLocationId, // 目前正在使用的攝影機為true，其餘為false
    } as ICamInfoUI;
  });
  return camerasUI;
}

/**
 * 設定camera控制相關IPC事件處理
 * @param ipcMain 主程序的ipcMain
 * @param mainWindow 主視窗
 */
export function setupCameraIpc(ipcMain: IpcMain, mainWindow?: BrowserWindow) {
  // 前端請求打開攝影機
  ipcMain.on(ECameraEvent.openCamera, (event) => {
    logger.debug(`Receive ${ECameraEvent.openCamera}`);
    //setCameraResolution('1280x720'); // 設定解析度
    openCamera(); // 開啟攝影機
  });

  // 前端請求關閉攝影機
  ipcMain.on(ECameraEvent.closeCamera, (event) => {
    logger.debug(`Receive ${ECameraEvent.closeCamera}`);
    closeCamera(); // 關閉攝影機
  });

  // 前端請求獲取攝影機清單
  ipcMain.handle(ECameraEvent.getCameras, (event) => {
    logger.debug(`Receive ${ECameraEvent.getCameras}`);
    return _getCameras();
  });

  // 前端請求設定攝影機
  ipcMain.handle(ECameraEvent.setCamera, (event, locationId: string) => {
    logger.debug(`Receive ${ECameraEvent.setCamera} ${locationId}`);
    if (_.isString(locationId)) {
      setCameraLocationId(locationId);
    }

    return _getCameras();
  });
}
