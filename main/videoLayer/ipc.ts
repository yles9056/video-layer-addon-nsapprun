// video layer控制相關IPC事件處理

import { BrowserWindow, IpcMain } from 'electron';
import _ from 'lodash';
import { logger } from '../util';
import { EVideoLayerEvent } from './const';
import { setVideoLayerSize, setVideoLayerPosition } from './util';

/**
 * 設定video layer控制相關IPC事件處理
 * @param ipcMain 主程序的ipcMain
 * @param mainWindow 主視窗
 */
export function setupVideoLayerIpc(ipcMain: IpcMain, mainWindow?: BrowserWindow) {
  /**
   * 請求前端回傳顯示區域大小
   */
  const sendVideoLayerRequireResize = () => {
    mainWindow?.webContents.send(EVideoLayerEvent.onVideoLayerRequireResize);
  };

  // 視窗正在改變大小時，先隱藏video layer
  mainWindow?.on('resize', () => {
    setVideoLayerSize(0, 0);
  });

  // 視窗大小改變後，請求前端回傳顯示區域大小
  mainWindow?.on('resized', () => {
    sendVideoLayerRequireResize();
  });
  mainWindow?.on('maximize', () => {
    sendVideoLayerRequireResize();
  });
  mainWindow?.on('unmaximize', () => {
    sendVideoLayerRequireResize();
  });
  mainWindow?.on('restore', () => {
    sendVideoLayerRequireResize();
  });
  mainWindow?.on('enter-full-screen', () => {
    sendVideoLayerRequireResize();
  });
  mainWindow?.on('leave-full-screen', () => {
    sendVideoLayerRequireResize();
  });

  // 前端請求設定video layer位置
  ipcMain.on(EVideoLayerEvent.setVideoLayerPosition, (event, x: number, y: number) => {
    logger.verbose(`Receive ${EVideoLayerEvent.setVideoLayerPosition} ${x} ${y}`);
    setVideoLayerPosition(x, y);
  });

  // 前端請求設定video layer大小
  ipcMain.on(EVideoLayerEvent.setVideoLayerSize, (event, width: number, height: number) => {
    logger.verbose(`Receive ${EVideoLayerEvent.setVideoLayerSize} ${width} ${height}`);
    setVideoLayerSize(width, height);
  });
}
