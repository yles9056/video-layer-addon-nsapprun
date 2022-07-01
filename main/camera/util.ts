import _, { Dictionary } from "lodash";
import { byOS, logger, OS } from "../util";
import { ICamCtrlLib, ICamInfo } from "./interface";
import * as usbDetect from "usb-detection";
import deasync from "deasync";
import { exec, fork } from "child_process";
import path from "path";

let camCtrlLib: ICamCtrlLib | undefined = undefined;
try {
  camCtrlLib = require("../UVCCamCtrl.node");
} catch (e) {
  logger.error(`Failed to load UVCCamCtrl.node`);
}

// 取得控制攝影機addon
export function getCamCtrlLib() {
  return camCtrlLib;
}

// 取得攝影機清單
export function getCameras() {
  return byOS(
    {
      [OS.Windows]: getCamerasWin(),
      [OS.Mac]: getCamerasMac(),
    },
    [] as ICamInfo[]
  );
}

// 取得攝影機清單(Windows)
export function getCamerasWin() {
  if (_.isNil(camCtrlLib)) {
    return [] as ICamInfo[];
  }

  let tmp: string[] = camCtrlLib.GetCamList();
  // 整理格式
  let camInfos = _.chain(tmp)
    .compact()
    .chunk(4)
    .map((x) => {
      let camInfo = {
        name: x[0],
        path: x[1] === "0" ? "" : x[1],
        vid: x[2] === "0" ? "" : x[2],
        pid: x[3] === "0" ? "" : x[3],
        serialNumber: "",
      } as ICamInfo;
      if (
        !_.isNil(camCtrlLib) &&
        camInfo.path !== "" &&
        camInfo.vid === "047d"
      ) {
        camInfo.serialNumber = camCtrlLib.GetSerialNum(camInfo.path);
      }
      return camInfo;
    })
    .value();

  return camInfos;
}

// 取得攝影機清單(Mac)
export function getCamerasMac() {
  if (_.isNil(camCtrlLib)) {
    return [] as ICamInfo[];
  }

  /* let _devices: any = undefined;
  let exec = deasync(usbDetect.find);
  try {
    _devices = exec();
  } catch (err) {
    console.log(err);
  }
  
  if (_devices) {
    _devices = _.map(_devices as Dictionary<any>[], (device) => {
      let locationId = device.locationId.toString(16);
      let vendorId = device.vendorId.toString(16).padStart(4, "0");
      let productId = device.productId.toString(16).padStart(4, "0");
      let path = `0x${locationId}${vendorId}${productId}`;
      return {
        ...device,
        locationId: locationId,
        vendorId: vendorId,
        productId: productId,
        path: path,
      };
    });
  }

  console.log(_devices); */

  let tmp: string[] = camCtrlLib.GetCamList();
  /* let tmp = [
    "FaceTime HD Camera",
    "CC26517R93EG1HNBV",
    "Kensington W1050 Full HD Fixed Focus Webcam",
    "0x14100000047d80c5",
  ]; */
  logger.debug(`getCamerasMac 1-1 ${JSON.stringify(tmp)}`);

  /* let child = fork(path.join(__dirname, "../test.js"));
  child.on("message", (data) => {
    console.log(`父行程接收到訊息 -> ${data}`);
  });
  child.on("error", (err) => {
    console.error(err);
  });
  child.on('close', (code) => {
    console.log('子进程已退出，退出码 ' + code);
 }) */

  // 整理格式
  let camInfos = _.chain(tmp)
    .compact()
    .chunk(2)
    .transform((res, x) => {
      let tmp = getCamInfoMac(x[1], x[0]);
      if (tmp.vid !== "" && tmp.pid !== "") {
        // 篩選有vid和pid的usb裝置
        res.push(tmp);
      } else if (_.startsWith(tmp.name, "FaceTime")) {
        // 加入內建攝影機
        res.push(tmp);
      }

      return true;
    }, [] as ICamInfo[])
    .value();

  logger.debug(`getCamerasMac 2-1 ${JSON.stringify(camInfos)}`);

  return camInfos;
}

// 取得攝影機資訊
export function getCamInfo(cameraPath: string, cameraName?: string) {
  let res = {
    name: "",
    vid: "",
    pid: "",
    serialNumber: "",
  } as ICamInfo;

  return byOS(
    {
      [OS.Windows]: getCamInfoWin(cameraPath, cameraName),
      [OS.Mac]: getCamInfoMac(cameraPath, cameraName),
    },
    res
  );
}

// 取得攝影機資訊(Windows)
export function getCamInfoWin(cameraPath: string, cameraName?: string) {
  let res = {
    name: "",
    vid: "",
    pid: "",
    serialNumber: "",
  } as ICamInfo;

  // cameraPath of a USB camera should contain both "vid_" and "pid_"
  if (!(cameraPath.includes("vid_") && cameraPath.includes("pid_"))) {
    // Invalid
    return res;
  }

  //cameraPath = cameraPath.slice(cameraPath.indexOf('vid_'));
  let info = _.split(cameraPath, "&");
  if (
    _.size(info) > 1 &&
    _.startsWith(info[0], "vid_") &&
    _.startsWith(info[1], "pid_")
  ) {
    res.vid = info[0].slice(4);
    res.pid = info[1].slice(4);
    if (!_.isNil(camCtrlLib)) {
      try {
        let serialNum = camCtrlLib.GetSerialNum(cameraPath);
        res.serialNumber = serialNum;
        logger.debug(`Serial number of camera: ${cameraPath}\n${serialNum}`);
      } catch (e) {
        logger.warn(
          `Error occured when reading camera serial number from camera: ${cameraPath}`
        );
      }
    }
    return res;
  }

  return res;
}

// 取得攝影機資訊(Mac)
const Regex = /^[0-9a-zA-Z]+$/;
export function getCamInfoMac(cameraPath: string, cameraName?: string) {
  let res = {
    name: _.isNil(cameraName) ? "" : cameraName,
    path: cameraPath,
    vid: "",
    pid: "",
    serialNumber: "",
  } as ICamInfo;

  if (
    _.startsWith(cameraPath, "0x") &&
    Regex.test(cameraPath) &&
    cameraPath.length > 10
  ) {
    res.pid = cameraPath.slice(-4);
    res.vid = cameraPath.slice(-8, -4);
    if (!_.isNil(camCtrlLib)) {
      try {
        let serialNum = camCtrlLib.GetSerialNum(cameraPath);
        res.serialNumber = serialNum;
        logger.debug(`Serial number of camera: ${cameraPath}\n${serialNum}`);
      } catch (e) {
        logger.warn(
          `Error occured when reading camera serial number from camera: ${cameraPath}`
        );
      }
    }
  }

  return res;
}

/**
 * 比較攝影機資訊是否相同
 * @param camModelInfo1 攝影機資訊1
 * @param camModelInfo2 攝影機資訊2
 * @param compareSerialNumber 是否比較序號
 * @param compareName 是否比較名稱
 * @returns
 */
export function isCamInfoEqual(
  camModelInfo1: ICamInfo,
  camModelInfo2: ICamInfo,
  compareSerialNumber = false,
  compareName = false
) {
  let isEqual =
    camModelInfo1.vid === camModelInfo2.vid &&
    camModelInfo1.pid === camModelInfo2.pid;

  if (compareSerialNumber) {
    isEqual =
      isEqual && camModelInfo1.serialNumber === camModelInfo2.serialNumber;
  }

  if (compareName) {
    isEqual = isEqual && camModelInfo1.name === camModelInfo2.name;
  }

  return isEqual;
}
