/**
 * Entry of electron app
 */
import { app, BrowserWindow, ipcMain, screen } from "electron";
import settings from "electron-settings";
import windowStateKeeper from "electron-window-state";
import _ from "lodash";
import path from "path";
import { setupCameraIpc } from "./camera/ipc";
import { byOS, isDevelopment, logger, OS, resolveHtmlPath } from "./util";
import { setupVideoLayerIpc } from "./videoLayer/ipc";
import { destroyVideoLayer, initVideoLayer } from "./videoLayer/util";

let mainWindow: BrowserWindow | null = null;

// 只允許開啟一個app
const gotTheLock = app.requestSingleInstanceLock();
if (!gotTheLock) {
  app.quit();
  process.exit();
}

// Debug設定
if (isDevelopment) {
  const debug = require("electron-debug");
  debug({ devToolsMode: "undocked" });
}

/**
 * 初始化設定檔
 */
const initSettingsFile = () => {
  // 設定JSON設定檔的路徑、格式、名稱
  settings.configure({
    dir: isDevelopment // 設定檔路徑，依照作業系統設定不同路徑，開發模式時則設定於專案資料夾內
      ? path.resolve(__dirname, "..", "config")
      : byOS(
          {
            [OS.Windows]: path.resolve(app.getPath("userData"), "config"),
            [OS.Mac]: path.resolve(
              app.getPath("home"),
              "Library",
              "Konnect",
              "config"
            ),
          },
          path.resolve(app.getPath("userData"), "config")
        ),
    fileName: `${app.getName()}_settings.json`,
    numSpaces: 2,
    prettify: true,
  });

  // 檢查設定檔是否已存在並且可讀取，如果失敗則用空白設定檔複寫
  try {
    settings.getSync();
  } catch (e) {
    logger.error(`Error when loading settings: ${e}`);
    settings.setSync({});
  }
};

/**
 * 安裝React開發者工具外掛
 */
const installExtensions = async () => {
  let installer = await import("electron-devtools-installer");
  const forceDownload = Boolean(process.env.UPGRADE_EXTENSIONS);
  const extensions = [installer.REACT_DEVELOPER_TOOLS];
  return installer.default(extensions, forceDownload).catch(console.log);
};

/**
 * 初始化主視窗
 */
const createMainWindow = async () => {
  if (isDevelopment) {
    await installExtensions();
  }

  // Store and restore window sizes and positions
  let mainWindowState = windowStateKeeper({
    defaultWidth: screen.getPrimaryDisplay().workArea.width,
    defaultHeight: screen.getPrimaryDisplay().workArea.height,
  });

  mainWindow = new BrowserWindow({
    x: mainWindowState.x,
    y: mainWindowState.y,
    width: mainWindowState.width,
    height: mainWindowState.height,
    minWidth: 640,
    minHeight: 480,
    show: false,
    backgroundColor: "white",
    icon: "public/logo512.png",
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.resolve(__dirname, "preload.js"),
      devTools: isDevelopment,
    },
  });

  // 設定IPC事件處理
  setupCameraIpc(ipcMain, mainWindow);
  setupVideoLayerIpc(ipcMain, mainWindow);

  // 設定主視窗URL
  const port = process.env.PORT || 3000;
  const startUrl = isDevelopment
    ? `http://localhost:${port}`
    : `file://${path.resolve(__dirname, "index.html")}`; // 注意: mac上的檔案路徑一定要有file://
  logger.debug(`startUrl ${startUrl}`);
  mainWindow.loadURL(startUrl); // 主視窗讀取URL

  // 等主視窗出現後再執行
  /* mainWindow.once("show", () => {
    // 初始化video layer
    if (mainWindow) {
      initVideoLayer(mainWindow.getNativeWindowHandle());
    }
  }); */

  mainWindow.once("ready-to-show", () => {
    mainWindow?.show();
  });

  mainWindow.on("closed", () => {
    mainWindow = null;
  });
};

initSettingsFile();

app.whenReady().then(() => {
  createMainWindow();

  app.on("activate", () => {
    if (!BrowserWindow.getAllWindows().length) {
      createMainWindow();
    }
  });
});

app.on("second-instance", (event, commandLine, workingDirectory) => {
  // Someone tried to run a second instance, we should focus our window.
  if (!_.isNil(mainWindow)) {
    if (mainWindow.isMinimized()) {
      mainWindow.restore();
    }
    mainWindow.focus();
  }
});

app.on("window-all-closed", () => {
  /* if (process.platform !== 'darwin') {
    app.quit();
  } */
  app.quit();
});

app.on("before-quit", () => {
  _.forEach(BrowserWindow.getAllWindows(), (window) => {
    window.close();
  });
  destroyVideoLayer();
});
