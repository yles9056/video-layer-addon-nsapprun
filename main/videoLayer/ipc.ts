// video layer控制相關IPC事件處理

import { BrowserWindow, IpcMain } from "electron";
import _ from "lodash";
import { logger } from "../util";
import { EVideoLayerEvent } from "./const";
import {
  setVideoLayerSize,
  setVideoLayerPosition,
  initVideoLayer,
} from "./util";

/**
 * 設定video layer控制相關IPC事件處理
 * @param ipcMain 主程序的ipcMain
 * @param mainWindow 主視窗
 */
export function setupVideoLayerIpc(
  ipcMain: IpcMain,
  mainWindow?: BrowserWindow
) {
  let childWindow = new BrowserWindow({
    show: false,
    backgroundColor: "#0FFF",
    transparent: true,
    frame: false,
    parent: mainWindow,
    opacity: 1,
    hasShadow: false,
  });
  childWindow.setIgnoreMouseEvents(true);

  const moveChildWindow = () => {
    if (mainWindow) {
      let bounds = mainWindow?.getBounds();
      childWindow.setBounds(bounds);
    }
  };

  moveChildWindow();

  /**
   * 請求前端回傳顯示區域大小
   */
  const sendVideoLayerRequireResize = () => {
    mainWindow?.webContents.send(EVideoLayerEvent.onVideoLayerRequireResize);
  };

  childWindow.once("show", () => {
    initVideoLayer(childWindow.getNativeWindowHandle());
  });

  childWindow.on('focus', () => {
    if (mainWindow) {
      mainWindow.focus();
    }
  })

  mainWindow?.once("show", () => {
    childWindow.show();
  });

  // 視窗正在改變大小時，先隱藏video layer
  mainWindow?.on("resize", () => {
    //setVideoLayerSize(0, 0);
    childWindow.hide();
  });

  // 視窗大小改變後，請求前端回傳顯示區域大小
  mainWindow?.on("resized", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  mainWindow?.on("maximize", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  mainWindow?.on("unmaximize", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  mainWindow?.on("restore", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  mainWindow?.on("enter-full-screen", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  mainWindow?.on("leave-full-screen", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });

  // 前端請求設定video layer位置
  ipcMain.on(
    EVideoLayerEvent.setVideoLayerPosition,
    (event, x: number, y: number) => {
      logger.verbose(
        `Receive ${EVideoLayerEvent.setVideoLayerPosition} ${x} ${y}`
      );
      if (!childWindow.isVisible()) {
        childWindow.show();
      }
      setVideoLayerPosition(x, y);
    }
  );

  // 前端請求設定video layer大小
  ipcMain.on(
    EVideoLayerEvent.setVideoLayerSize,
    (event, width: number, height: number) => {
      logger.verbose(
        `Receive ${EVideoLayerEvent.setVideoLayerSize} ${width} ${height}`
      );
      if (!childWindow.isVisible()) {
        childWindow.show();
      }
      setVideoLayerSize(width, height);
    }
  );
}
