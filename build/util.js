"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveResourcePath = exports.resolveHtmlPath = exports.logger = exports.getOS = exports.byOS = exports.OS = exports.isDevelopment = void 0;
var electron_1 = require("electron");
var lodash_1 = __importDefault(require("lodash"));
var path_1 = __importDefault(require("path"));
var process_1 = __importDefault(require("process"));
var winston_1 = require("winston");
require("winston-daily-rotate-file");
// Check if process is running in development mode
exports.isDevelopment = process_1.default.env.NODE_ENV === 'development' || process_1.default.env.DEBUG_PROD === 'true';
/** Allowed platform. From `process.platform` */
var OS;
(function (OS) {
    OS["Windows"] = "win32";
    OS["Mac"] = "darwin";
    OS["Linux"] = "linux";
})(OS = exports.OS || (exports.OS = {}));
/**
 * Return a value/function based on current OS.
 * If the result is undefinded, return defaultValue.
 * Currently allowed OS: Windows: `win32`, Mac: `darwin`, Linux: `linux`.
 * @param handlers A dictionary with OS names as keys.
 * @param defaultValue Value/Function to use if `handlers[process.platform]` returns `undefined`.
 * @returns Return a value/function based on current OS.
 * @example
 *
 * let foo = byOS({
 *  "win32": "Running on Windows",
 *  "darwin": "Running on Mac"
 * }, "Unsupported OS");
 */
function byOS(handlers, defaultValue) {
    var handler = handlers[process_1.default.platform];
    if (lodash_1.default.isUndefined(handler)) {
        return defaultValue;
    }
    return handler;
}
exports.byOS = byOS;
function getOS() {
    return process_1.default.platform;
}
exports.getOS = getOS;
// Configure logging output to log file
exports.logger = (0, winston_1.createLogger)({
    transports: [
        // Log output to a file
        /* new transports.File({
          filename: isDevelopment
            ? path.resolve(__dirname, '..', 'log', `${app.getName()}.log`)
            : path.resolve(app.getPath('userData'), `${app.getName()}.log`),
          level: 'debug',
          format: format.combine(
            format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
            format.printf((info) => `${info.timestamp}[${info.level}] ${info.message}`)
          )
        }) */
        // Log output to a file with rotation
        new winston_1.transports.DailyRotateFile({
            level: 'debug',
            format: winston_1.format.combine(winston_1.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }), winston_1.format.printf(function (info) { return "".concat(info.timestamp, "[").concat(info.level, "] ").concat(info.message); })),
            filename: "".concat(electron_1.app.getName(), "-%DATE%.log"),
            dirname: exports.isDevelopment
                ? path_1.default.resolve(__dirname, '..', 'log')
                : path_1.default.resolve(electron_1.app.getPath('userData'), 'log'),
            datePattern: 'YYYY-MM-DD-HH',
            frequency: '1h',
            maxSize: '20m',
            maxFiles: '7d'
        })
    ]
});
// Configure output log to console
if (exports.isDevelopment) {
    exports.logger.add(new winston_1.transports.Console({
        level: 'debug',
        format: winston_1.format.combine(winston_1.format.colorize(), winston_1.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }), winston_1.format.printf(function (info) { return "".concat(info.timestamp, "[").concat(info.level, "] ").concat(info.message); }))
    }));
}
var _resolveHtmlPath;
if (exports.isDevelopment) {
    var port_1 = process_1.default.env.PORT || 3000;
    _resolveHtmlPath = function (htmlFileName) {
        var url = new URL("http://localhost:".concat(port_1));
        url.pathname = htmlFileName;
        return url.href;
    };
}
else {
    _resolveHtmlPath = function (htmlFileName) {
        return "file://".concat(path_1.default.resolve(__dirname, htmlFileName));
    };
}
/**
 * Resolve the path of a html page.
 * @param htmlFileName File name of the html page.
 * @returns Resolved path of the html.
 */
function resolveHtmlPath(htmlFileName) {
    return _resolveHtmlPath(htmlFileName);
}
exports.resolveHtmlPath = resolveHtmlPath;
var _resolveResourcePath;
if (exports.isDevelopment) {
    _resolveResourcePath = function (resourcePath, unpacked) {
        if (unpacked === void 0) { unpacked = false; }
        return path_1.default.resolve(__dirname, '..', 'public', resourcePath);
    };
}
else {
    _resolveResourcePath = function (resourcePath, unpacked) {
        if (unpacked === void 0) { unpacked = false; }
        var _path = path_1.default.resolve(__dirname, resourcePath);
        if (unpacked) {
            _path = lodash_1.default.replace(_path, 'app.asar', 'app.asar.unpacked');
        }
        return _path;
    };
}
/**
 * Resolve the path of a resource file.
 * @param resourcePath File path of the resource file.
 * @param unpacked Whether the file will be in app.asar.unpacked when the app packs. Default is `false`.
 * @returns Resolved path of the resource file.
 */
function resolveResourcePath(resourcePath, unpacked) {
    if (unpacked === void 0) { unpacked = false; }
    return _resolveResourcePath(resourcePath, unpacked);
}
exports.resolveResourcePath = resolveResourcePath;
