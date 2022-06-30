"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.isCamInfoEqual = exports.getCamInfoMac = exports.getCamInfoWin = exports.getCamInfo = exports.getCamerasMac = exports.getCamerasWin = exports.getCameras = exports.getCamCtrlLib = void 0;
var lodash_1 = __importDefault(require("lodash"));
var util_1 = require("../util");
var camCtrlLib = undefined;
try {
    camCtrlLib = require('../UVCCamCtrl.node');
}
catch (e) {
    util_1.logger.error("Failed to load UVCCamCtrl.node");
}
// 取得控制攝影機addon
function getCamCtrlLib() {
    return camCtrlLib;
}
exports.getCamCtrlLib = getCamCtrlLib;
// 取得攝影機清單
function getCameras() {
    var _a;
    return (0, util_1.byOS)((_a = {},
        _a[util_1.OS.Windows] = getCamerasWin(),
        _a[util_1.OS.Mac] = getCamerasMac(),
        _a), []);
}
exports.getCameras = getCameras;
// 取得攝影機清單(Windows)
function getCamerasWin() {
    if (lodash_1.default.isNil(camCtrlLib)) {
        return [];
    }
    var tmp = camCtrlLib.GetCamList();
    // 整理格式
    var camInfos = lodash_1.default.chain(tmp)
        .compact()
        .chunk(4)
        .map(function (x) {
        var camInfo = {
            name: x[0],
            path: x[1] === '0' ? '' : x[1],
            vid: x[2] === '0' ? '' : x[2],
            pid: x[3] === '0' ? '' : x[3],
            serialNumber: ''
        };
        if (!lodash_1.default.isNil(camCtrlLib) && camInfo.path !== '' && camInfo.vid === '047d') {
            camInfo.serialNumber = camCtrlLib.GetSerialNum(camInfo.path);
        }
        return camInfo;
    })
        .value();
    return camInfos;
}
exports.getCamerasWin = getCamerasWin;
// 取得攝影機清單(Mac)
function getCamerasMac() {
    if (lodash_1.default.isNil(camCtrlLib)) {
        return [];
    }
    var tmp = camCtrlLib.GetCamList();
    util_1.logger.debug("getCamerasMac 1 ".concat(JSON.stringify(tmp)));
    // 整理格式
    var camInfos = lodash_1.default.chain(tmp)
        .compact()
        .chunk(2)
        .transform(function (res, x) {
        var tmp = getCamInfoMac(x[1], x[0]);
        if (tmp.vid !== '' && tmp.pid !== '') { // 篩選有vid和pid的usb裝置
            res.push(tmp);
        }
        else if (lodash_1.default.startsWith(tmp.name, 'FaceTime')) { // 加入內建攝影機
            res.push(tmp);
        }
        return true;
    }, [])
        .value();
    util_1.logger.debug("getCamerasMac 2 ".concat(JSON.stringify(camInfos)));
    return camInfos;
}
exports.getCamerasMac = getCamerasMac;
// 取得攝影機資訊
function getCamInfo(cameraPath, cameraName) {
    var _a;
    var res = {
        name: '',
        vid: '',
        pid: '',
        serialNumber: ''
    };
    return (0, util_1.byOS)((_a = {},
        _a[util_1.OS.Windows] = getCamInfoWin(cameraPath, cameraName),
        _a[util_1.OS.Mac] = getCamInfoMac(cameraPath, cameraName),
        _a), res);
}
exports.getCamInfo = getCamInfo;
// 取得攝影機資訊(Windows)
function getCamInfoWin(cameraPath, cameraName) {
    var res = {
        name: '',
        vid: '',
        pid: '',
        serialNumber: ''
    };
    // cameraPath of a USB camera should contain both "vid_" and "pid_"
    if (!(cameraPath.includes('vid_') && cameraPath.includes('pid_'))) {
        // Invalid
        return res;
    }
    //cameraPath = cameraPath.slice(cameraPath.indexOf('vid_'));
    var info = lodash_1.default.split(cameraPath, '&');
    if (lodash_1.default.size(info) > 1 && lodash_1.default.startsWith(info[0], 'vid_') && lodash_1.default.startsWith(info[1], 'pid_')) {
        res.vid = info[0].slice(4);
        res.pid = info[1].slice(4);
        if (!lodash_1.default.isNil(camCtrlLib)) {
            try {
                var serialNum = camCtrlLib.GetSerialNum(cameraPath);
                res.serialNumber = serialNum;
                util_1.logger.debug("Serial number of camera: ".concat(cameraPath, "\n").concat(serialNum));
            }
            catch (e) {
                util_1.logger.warn("Error occured when reading camera serial number from camera: ".concat(cameraPath));
            }
        }
        return res;
    }
    return res;
}
exports.getCamInfoWin = getCamInfoWin;
// 取得攝影機資訊(Mac)
var Regex = /^[0-9a-zA-Z]+$/;
function getCamInfoMac(cameraPath, cameraName) {
    var res = {
        name: lodash_1.default.isNil(cameraName) ? '' : cameraName,
        path: cameraPath,
        vid: '',
        pid: '',
        serialNumber: ''
    };
    if (lodash_1.default.startsWith(cameraPath, '0x') && Regex.test(cameraPath) && cameraPath.length > 10) {
        res.pid = cameraPath.slice(-4);
        res.vid = cameraPath.slice(-8, -4);
        if (!lodash_1.default.isNil(camCtrlLib)) {
            try {
                var serialNum = camCtrlLib.GetSerialNum(cameraPath);
                res.serialNumber = serialNum;
                util_1.logger.debug("Serial number of camera: ".concat(cameraPath, "\n").concat(serialNum));
            }
            catch (e) {
                util_1.logger.warn("Error occured when reading camera serial number from camera: ".concat(cameraPath));
            }
        }
    }
    return res;
}
exports.getCamInfoMac = getCamInfoMac;
/**
 * 比較攝影機資訊是否相同
 * @param camModelInfo1 攝影機資訊1
 * @param camModelInfo2 攝影機資訊2
 * @param compareSerialNumber 是否比較序號
 * @param compareName 是否比較名稱
 * @returns
 */
function isCamInfoEqual(camModelInfo1, camModelInfo2, compareSerialNumber, compareName) {
    if (compareSerialNumber === void 0) { compareSerialNumber = false; }
    if (compareName === void 0) { compareName = false; }
    var isEqual = camModelInfo1.vid === camModelInfo2.vid && camModelInfo1.pid === camModelInfo2.pid;
    if (compareSerialNumber) {
        isEqual = isEqual && camModelInfo1.serialNumber === camModelInfo2.serialNumber;
    }
    if (compareName) {
        isEqual = isEqual && camModelInfo1.name === camModelInfo2.name;
    }
    return isEqual;
}
exports.isCamInfoEqual = isCamInfoEqual;
