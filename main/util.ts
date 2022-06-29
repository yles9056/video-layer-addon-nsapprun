import { app } from 'electron';
import _ from 'lodash';
import path from 'path';
import process from 'process';
import { createLogger, format, transports } from 'winston';
import 'winston-daily-rotate-file';

// Check if process is running in development mode
export const isDevelopment =
  process.env.NODE_ENV === 'development' || process.env.DEBUG_PROD === 'true';

/** Allowed platform. From `process.platform` */
export enum OS {
  Windows = 'win32',
  Mac = 'darwin',
  Linux = 'linux'
}

type TOSHandlerMap<TReturn> = { [os in OS]?: TReturn };
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
export function byOS<TReturn = any>(
  handlers: TOSHandlerMap<TReturn>,
  defaultValue: TReturn
): TReturn {
  const handler = handlers[process.platform as OS];

  if (_.isUndefined(handler)) {
    return defaultValue;
  }

  return handler;
}

export function getOS() {
  return process.platform;
}

// Configure logging output to log file
export const logger = createLogger({
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
    new transports.DailyRotateFile({
      level: 'debug',
      format: format.combine(
        format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
        format.printf((info) => `${info.timestamp}[${info.level}] ${info.message}`)
      ),
      filename: `${app.getName()}-%DATE%.log`,
      dirname: isDevelopment
        ? path.resolve(__dirname, '..', 'log')
        : path.resolve(app.getPath('userData'), 'log'),
      datePattern: 'YYYY-MM-DD-HH',
      frequency: '1h',
      maxSize: '20m',
      maxFiles: '7d'
    })
  ]
});

// Configure output log to console
if (isDevelopment) {
  logger.add(
    new transports.Console({
      level: 'debug',
      format: format.combine(
        format.colorize(),
        format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
        format.printf((info) => `${info.timestamp}[${info.level}] ${info.message}`)
      )
    })
  );
}

let _resolveHtmlPath: (htmlFileName: string) => string;
if (isDevelopment) {
  const port = process.env.PORT || 3000;
  _resolveHtmlPath = (htmlFileName: string) => {
    const url = new URL(`http://localhost:${port}`);
    url.pathname = htmlFileName;
    return url.href;
  };
} else {
  _resolveHtmlPath = (htmlFileName: string) => {
    return `file://${path.resolve(__dirname, htmlFileName)}`;
  };
}

/**
 * Resolve the path of a html page.
 * @param htmlFileName File name of the html page.
 * @returns Resolved path of the html.
 */
export function resolveHtmlPath(htmlFileName: string) {
  return _resolveHtmlPath(htmlFileName);
}

let _resolveResourcePath: (resourcePath: string, unpacked: boolean) => string;
if (isDevelopment) {
  _resolveResourcePath = (resourcePath: string, unpacked = false) =>
    path.resolve(__dirname, '..', 'public', resourcePath);
} else {
  _resolveResourcePath = (resourcePath: string, unpacked = false) => {
    let _path = path.resolve(__dirname, resourcePath);
    if (unpacked) {
      _path = _.replace(_path, 'app.asar', 'app.asar.unpacked');
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
export function resolveResourcePath(resourcePath: string, unpacked = false) {
  return _resolveResourcePath(resourcePath, unpacked);
}
