"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * Entry of electron app
 */
var electron_1 = require("electron");
var electron_settings_1 = __importDefault(require("electron-settings"));
var electron_window_state_1 = __importDefault(require("electron-window-state"));
var lodash_1 = __importDefault(require("lodash"));
var path_1 = __importDefault(require("path"));
var ipc_1 = require("./camera/ipc");
var util_1 = require("./util");
var ipc_2 = require("./videoLayer/ipc");
var util_2 = require("./videoLayer/util");
var mainWindow = null;
// 只允許開啟一個app
var gotTheLock = electron_1.app.requestSingleInstanceLock();
if (!gotTheLock) {
    electron_1.app.quit();
    process.exit();
}
// Debug設定
if (util_1.isDevelopment) {
    var debug_1 = require("electron-debug");
    debug_1({ devToolsMode: "undocked" });
}
/**
 * 初始化設定檔
 */
var initSettingsFile = function () {
    var _a;
    // 設定JSON設定檔的路徑、格式、名稱
    electron_settings_1.default.configure({
        dir: util_1.isDevelopment // 設定檔路徑，依照作業系統設定不同路徑，開發模式時則設定於專案資料夾內
            ? path_1.default.resolve(__dirname, "..", "config")
            : (0, util_1.byOS)((_a = {},
                _a[util_1.OS.Windows] = path_1.default.resolve(electron_1.app.getPath("userData"), "config"),
                _a[util_1.OS.Mac] = path_1.default.resolve(electron_1.app.getPath("home"), "Library", "Konnect", "config"),
                _a), path_1.default.resolve(electron_1.app.getPath("userData"), "config")),
        fileName: "".concat(electron_1.app.getName(), "_settings.json"),
        numSpaces: 2,
        prettify: true,
    });
    // 檢查設定檔是否已存在並且可讀取，如果失敗則用空白設定檔複寫
    try {
        electron_settings_1.default.getSync();
    }
    catch (e) {
        util_1.logger.error("Error when loading settings: ".concat(e));
        electron_settings_1.default.setSync({});
    }
};
/**
 * 安裝React開發者工具外掛
 */
var installExtensions = function () { return __awaiter(void 0, void 0, void 0, function () {
    var installer, forceDownload, extensions;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0: return [4 /*yield*/, Promise.resolve().then(function () { return __importStar(require("electron-devtools-installer")); })];
            case 1:
                installer = _a.sent();
                forceDownload = Boolean(process.env.UPGRADE_EXTENSIONS);
                extensions = [installer.REACT_DEVELOPER_TOOLS];
                return [2 /*return*/, installer.default(extensions, forceDownload).catch(console.log)];
        }
    });
}); };
/**
 * 初始化主視窗
 */
var createMainWindow = function () { return __awaiter(void 0, void 0, void 0, function () {
    var mainWindowState, port, startUrl;
    return __generator(this, function (_a) {
        switch (_a.label) {
            case 0:
                if (!util_1.isDevelopment) return [3 /*break*/, 2];
                return [4 /*yield*/, installExtensions()];
            case 1:
                _a.sent();
                _a.label = 2;
            case 2:
                mainWindowState = (0, electron_window_state_1.default)({
                    defaultWidth: electron_1.screen.getPrimaryDisplay().workArea.width,
                    defaultHeight: electron_1.screen.getPrimaryDisplay().workArea.height,
                });
                mainWindow = new electron_1.BrowserWindow({
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
                        preload: path_1.default.resolve(__dirname, "preload.js"),
                        devTools: util_1.isDevelopment,
                    },
                });
                // 設定IPC事件處理
                (0, ipc_1.setupCameraIpc)(electron_1.ipcMain, mainWindow);
                (0, ipc_2.setupVideoLayerIpc)(electron_1.ipcMain, mainWindow);
                port = process.env.PORT || 3000;
                startUrl = util_1.isDevelopment
                    ? "http://localhost:".concat(port)
                    : "file://".concat(path_1.default.resolve(__dirname, "index.html"));
                util_1.logger.debug("startUrl ".concat(startUrl));
                mainWindow.loadURL(startUrl); // 主視窗讀取URL
                // 等主視窗出現後再執行
                mainWindow.once("show", function () {
                    // 初始化video layer
                    if (mainWindow) {
                        (0, util_2.initVideoLayer)(mainWindow.getNativeWindowHandle());
                    }
                });
                mainWindow.once("ready-to-show", function () {
                    mainWindow === null || mainWindow === void 0 ? void 0 : mainWindow.show();
                });
                mainWindow.on("closed", function () {
                    mainWindow = null;
                });
                return [2 /*return*/];
        }
    });
}); };
initSettingsFile();
electron_1.app.whenReady().then(function () {
    createMainWindow();
    electron_1.app.on("activate", function () {
        if (!electron_1.BrowserWindow.getAllWindows().length) {
            createMainWindow();
        }
    });
});
electron_1.app.on("second-instance", function (event, commandLine, workingDirectory) {
    // Someone tried to run a second instance, we should focus our window.
    if (!lodash_1.default.isNil(mainWindow)) {
        if (mainWindow.isMinimized()) {
            mainWindow.restore();
        }
        mainWindow.focus();
    }
});
electron_1.app.on("window-all-closed", function () {
    /* if (process.platform !== 'darwin') {
      app.quit();
    } */
    electron_1.app.quit();
});
electron_1.app.on("before-quit", function () {
    lodash_1.default.forEach(electron_1.BrowserWindow.getAllWindows(), function (window) {
        window.close();
    });
    (0, util_2.destroyVideoLayer)();
});
