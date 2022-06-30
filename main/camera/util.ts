import _ from 'lodash';
import { byOS, logger, OS } from '../util';
import { ICamCtrlLib, ICamInfo } from './interface';

let camCtrlLib: ICamCtrlLib | undefined = undefined;
try {
  camCtrlLib = require('../UVCCamCtrl.node');
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
      [OS.Mac]: getCamerasMac()
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
        path: x[1] === '0' ? '' : x[1],
        vid: x[2] === '0' ? '' : x[2],
        pid: x[3] === '0' ? '' : x[3],
        serialNumber: ''
      } as ICamInfo;
      if (!_.isNil(camCtrlLib) && camInfo.path !== '' && camInfo.vid === '047d') {
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

  let tmp: string[] = camCtrlLib.GetCamList();
  logger.debug(`getCamerasMac 1 ${JSON.stringify(tmp)}`);
  // 整理格式
  let camInfos = _.chain(tmp)
    .compact()
    .chunk(2)
    .transform((res, x) => {
      let tmp = getCamInfoMac(x[1], x[0]);
      if (tmp.vid !== '' && tmp.pid !== '') { // 篩選有vid和pid的usb裝置
        res.push(tmp);
      } else if (_.startsWith(tmp.name, 'FaceTime')) { // 加入內建攝影機
        res.push(tmp);
      }

      return true;
    }, [] as ICamInfo[])
    .value();

  logger.debug(`getCamerasMac 2 ${JSON.stringify(camInfos)}`);

  return camInfos;
}

// 取得攝影機資訊
export function getCamInfo(cameraPath: string, cameraName?: string) {
  let res = {
    name: '',
    vid: '',
    pid: '',
    serialNumber: ''
  } as ICamInfo;

  return byOS(
    {
      [OS.Windows]: getCamInfoWin(cameraPath, cameraName),
      [OS.Mac]: getCamInfoMac(cameraPath, cameraName)
    },
    res
  );
}

// 取得攝影機資訊(Windows)
export function getCamInfoWin(cameraPath: string, cameraName?: string) {
  let res = {
    name: '',
    vid: '',
    pid: '',
    serialNumber: ''
  } as ICamInfo;

  // cameraPath of a USB camera should contain both "vid_" and "pid_"
  if (!(cameraPath.includes('vid_') && cameraPath.includes('pid_'))) {
    // Invalid
    return res;
  }

  //cameraPath = cameraPath.slice(cameraPath.indexOf('vid_'));
  let info = _.split(cameraPath, '&');
  if (_.size(info) > 1 && _.startsWith(info[0], 'vid_') && _.startsWith(info[1], 'pid_')) {
    res.vid = info[0].slice(4);
    res.pid = info[1].slice(4);
    if (!_.isNil(camCtrlLib)) {
      try {
        let serialNum = camCtrlLib.GetSerialNum(cameraPath);
        res.serialNumber = serialNum;
        logger.debug(`Serial number of camera: ${cameraPath}\n${serialNum}`);
      } catch (e) {
        logger.warn(`Error occured when reading camera serial number from camera: ${cameraPath}`);
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
    name: _.isNil(cameraName) ? '' : cameraName,
    path: cameraPath,
    vid: '',
    pid: '',
    serialNumber: ''
  } as ICamInfo;

  if (_.startsWith(cameraPath, '0x') && Regex.test(cameraPath) && cameraPath.length > 10) {
    res.pid = cameraPath.slice(-4);
    res.vid = cameraPath.slice(-8, -4);
    if (!_.isNil(camCtrlLib)) {
      try {
        let serialNum = camCtrlLib.GetSerialNum(cameraPath);
        res.serialNumber = serialNum;
        logger.debug(`Serial number of camera: ${cameraPath}\n${serialNum}`);
      } catch (e) {
        logger.warn(`Error occured when reading camera serial number from camera: ${cameraPath}`);
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
  let isEqual = camModelInfo1.vid === camModelInfo2.vid && camModelInfo1.pid === camModelInfo2.pid;

  if (compareSerialNumber) {
    isEqual = isEqual && camModelInfo1.serialNumber === camModelInfo2.serialNumber;
  }

  if (compareName) {
    isEqual = isEqual && camModelInfo1.name === camModelInfo2.name;
  }

  return isEqual;
}
