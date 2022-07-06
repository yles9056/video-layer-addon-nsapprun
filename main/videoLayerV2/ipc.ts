// video layer控制相關IPC事件處理

import { ChildProcessWithoutNullStreams, spawn } from "child_process";
import { BrowserWindow, IpcMain } from "electron";
import _ from "lodash";
import path from "path";
import { logger } from "../util";
import { EVideoLayerEvent } from "./const";
import {
  setVideoLayerSize,
  setVideoLayerPosition,
  initVideoLayer,
  getVideoLayerPosition,
  getVideoLayerSize,
} from "./util";

let _mainWindow: BrowserWindow | undefined = undefined;
let childWindow: BrowserWindow | undefined = undefined;
let p: ChildProcessWithoutNullStreams | undefined = undefined;

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
    backgroundColor: "#0FFF",
    transparent: true,
    frame: false,
    parent: _mainWindow,
    opacity: 1,
    hasShadow: false,
  });
  childWindow.setIgnoreMouseEvents(true);

  const moveChildWindow = () => {
    if (_mainWindow) {
      let bounds = _mainWindow?.getBounds();
      childWindow?.setBounds(bounds);
    }
  };

  moveChildWindow();

  /**
   * 請求前端回傳顯示區域大小
   */
  const sendVideoLayerRequireResize = () => {
    _mainWindow?.webContents.send(EVideoLayerEvent.onVideoLayerRequireResize);
  };

  _mainWindow?.once("show", () => {
    childWindow?.show();
  });

  _mainWindow?.once("closed", () => {
    _mainWindow = undefined;
    childWindow?.close();
    p?.once("close", () => {
      p = undefined;
    });
    p?.kill();
  });

  childWindow.on("closed", () => {
    childWindow = undefined;
  });

  childWindow.once("show", () => {
    p = spawn(path.join(__dirname, "..", "KJMachPortServer"), {
      stdio: "pipe",
    });

    p.stdout.on("data", (data) => {
      logger.info(`stdout: ${data}`);
    });

    p.stderr.on("data", (data) => {
      logger.info(`stderr: ${data}`);
      let dataStr = _.toString(data);
      if (dataStr.includes("_contextId")) {
        let contextId = _.chain(dataStr).split(" ").last().toInteger().value();
        logger.info(`contextId: ${contextId}`);
        if (_.isInteger(contextId) && childWindow) {
          initVideoLayer(contextId, childWindow.getNativeWindowHandle());
        }
      }
    });
  });

  childWindow.on("focus", () => {
    _mainWindow?.focus();
  });

  _mainWindow?.once("show", () => {
    childWindow?.show();
  });

  // 視窗正在改變大小時，先隱藏video layer
  _mainWindow?.on("resize", () => {
    //setVideoLayerSize(0, 0);
    childWindow?.hide();
  });

  // 視窗大小改變後，請求前端回傳顯示區域大小
  _mainWindow?.on("resized", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  _mainWindow?.on("maximize", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  _mainWindow?.on("unmaximize", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  _mainWindow?.on("restore", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  _mainWindow?.on("enter-full-screen", () => {
    moveChildWindow();
    sendVideoLayerRequireResize();
  });
  _mainWindow?.on("leave-full-screen", () => {
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
      if (!childWindow?.isVisible()) {
        childWindow?.show();
      }
      setVideoLayerPosition(x, y).then((res) => {
        logger.debug(`setVideoLayerPosition ${JSON.stringify(res)}`);
      });
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
      setVideoLayerSize(width, height).then((res) => {
        logger.debug(`setVideoLayerSize ${JSON.stringify(res)}`);
      });
    }
  );
}
