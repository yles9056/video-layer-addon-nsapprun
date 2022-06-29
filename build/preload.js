"use strict";
var __spreadArray = (this && this.__spreadArray) || function (to, from, pack) {
    if (pack || arguments.length === 2) for (var i = 0, l = from.length, ar; i < l; i++) {
        if (ar || !(i in from)) {
            if (!ar) ar = Array.prototype.slice.call(from, 0, i);
            ar[i] = from[i];
        }
    }
    return to.concat(ar || Array.prototype.slice.call(from));
};
Object.defineProperty(exports, "__esModule", { value: true });
var electron_1 = require("electron");
require("./camera/preload");
require("./videoLayer/preload");
electron_1.contextBridge.exposeInMainWorld('electron', {
    ipcRenderer: {
        /**
         * Add a listener that listens to a channel.
         * @param channel The channel to listen to.
         * @param listener Listener function.
         * @returns A function that removes the listener when called.
         */
        on: function (channel, listener) {
            var _listener = function (event) {
                var args = [];
                for (var _i = 1; _i < arguments.length; _i++) {
                    args[_i - 1] = arguments[_i];
                }
                listener.apply(void 0, args);
            };
            electron_1.ipcRenderer.on(channel, _listener);
            return function () {
                electron_1.ipcRenderer.removeListener(channel, _listener);
            };
        },
        /**
         * Add a listener that listens to a channel. Only trigger once.
         * @param channel The channel to listen to.
         * @param listener Listener function.
         * @returns A function that removes the listener when called.
         */
        once: function (channel, listener) {
            var _listener = function (event) {
                var args = [];
                for (var _i = 1; _i < arguments.length; _i++) {
                    args[_i - 1] = arguments[_i];
                }
                listener.apply(void 0, args);
            };
            electron_1.ipcRenderer.once(channel, _listener);
            return function () {
                electron_1.ipcRenderer.removeListener(channel, _listener);
            };
        },
        /**
         * Sends args to main process via ipcRenderer.send()
         * @param channel
         * @param args
         */
        send: function (channel) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            electron_1.ipcRenderer.send.apply(electron_1.ipcRenderer, __spreadArray([channel], args, false));
        },
        /**
         * Sends args to main process via ipcRenderer.invoke()
         * @param channel
         * @param args
         * @returns A promise.
         */
        invoke: function (channel) {
            var args = [];
            for (var _i = 1; _i < arguments.length; _i++) {
                args[_i - 1] = arguments[_i];
            }
            return electron_1.ipcRenderer.invoke.apply(electron_1.ipcRenderer, __spreadArray([channel], args, false));
        }
    }
});
