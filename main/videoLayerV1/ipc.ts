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

let _mainWindow: BrowserWindow | undefined = undefined;
let childWindow: BrowserWindow | undefined = undefined;

/**
 * 設定video layer控制相關IPC事件處理
 * @param ipcMain 主程序的ipcMain
 * @param mainWindow 主視窗
 */
export function setupVideoLayerIpc(
  ipcMain: IpcMain,
  mainWindow?: BrowserWindow
) {
  _mainWindow = mainWindow;

  childWindow = new BrowserWindow({
    show: false,
    backgroundColor: "#0FF",
    //transparent: true,
    frame: false,
    parent: mainWindow,
    opacity: 0.5,
    title: "VideoLayer Preview",
    hasShadow: false,
    resizable: false,
    acceptFirstMouse: false,
    focusable: false,
  });
  childWindow.excludedFromShownWindowsMenu = true;
  childWindow.setIgnoreMouseEvents(true);

  const moveChildWindow = () => {
    if (mainWindow && childWindow) {
      let bounds = mainWindow.getBounds();
      let position = mainWindow.getPosition();
      logger.debug(
        `moveChildWindow mainWindow bounds ${JSON.stringify(bounds)}`
      );
      logger.debug(
        `moveChildWindow mainWindow position ${JSON.stringify(position)}`
      );
      childWindow.setBounds(bounds);
      mainWindow.setBounds(childWindow.getBounds());
      // childWindow.setSize(bounds.width, bounds.height);
      // childWindow.setPosition(bounds.x, bounds.y);
      //mainWindow.focus();
      logger.debug(
        `moveChildWindow mainWindow ${JSON.stringify(mainWindow.getPosition())}`
      );
      logger.debug(
        `moveChildWindow childWindow ${JSON.stringify(
          childWindow.getPosition()
        )}`
      );
    }
  };

  moveChildWindow();

  /**
   * 請求前端回傳顯示區域大小
   */
  const sendVideoLayerRequireResize = () => {
    mainWindow?.webContents.send(EVideoLayerEvent.onVideoLayerRequireResize);
  };

  const _update = _.debounce(() => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  }, 500);

  _mainWindow?.once("closed", () => {
    _mainWindow = undefined;
    childWindow?.close();
  });

  /* _mainWindow?.on("focus", () => {
    childWindow?.setAlwaysOnTop(true);
  }); */

  /* _mainWindow?.on("blur", () => {
    childWindow?.setAlwaysOnTop(false);
  }); */

  childWindow.once("show", () => {
    if (childWindow) {
      initVideoLayer(childWindow.getNativeWindowHandle());
    }
  });

  childWindow.on("closed", () => {
    childWindow = undefined;
  });

  childWindow.on("focus", () => {
    _mainWindow?.focus();
  });

  mainWindow?.once("show", () => {
    childWindow?.show();
  });

  // 視窗正在改變大小時，先隱藏video layer
  mainWindow?.on("resize", () => {
    //setVideoLayerSize(0, 0);
    childWindow?.hide();
  });
  mainWindow?.on("move", () => {
    //setVideoLayerSize(0, 0);
    childWindow?.hide();
  });

  // 視窗大小改變後，請求前端回傳顯示區域大小
  mainWindow?.on("resized", () => {
    _update();
  });
  mainWindow?.on("moved", () => {
    _update();
  });
  mainWindow?.on("maximize", () => {
    _update();
  });
  mainWindow?.on("unmaximize", () => {
    _update();
  });
  mainWindow?.on("restore", () => {
    _update();
  });
  mainWindow?.on("enter-full-screen", () => {
    _update();
  });
  mainWindow?.on("leave-full-screen", () => {
    _update();
  });

  // 前端請求設定video layer位置
  ipcMain.on(
    EVideoLayerEvent.setVideoLayerPosition,
    (event, x: number, y: number) => {
      logger.verbose(
        `Receive ${EVideoLayerEvent.setVideoLayerPosition} ${x} ${y}`
      );
      if (!childWindow?.isVisible()) {
        childWindow?.show();
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
      if (!childWindow?.isVisible()) {
        childWindow?.show();
      }
      setVideoLayerSize(width, height);
    }
  );
}
