// camera控制相關介面

/**
 * 攝影機資訊介面
 */
export interface ICamInfo {
  name: string; // 名字
  vid: string; // vendor id 生產商id
  pid: string; // product id 產品id
  serialNumber: string; // 序號
  path: string; // 攝影機路徑，即locationId
}

/**
 * 攝影機資訊介面(前端使用)
 */
export interface ICamInfoUI extends ICamInfo {
  id: string; // 清單id
  isChecked: boolean; // 是否勾選
}

/**
 * camera控制模組介面
 */
export interface ICamCtrlLib {
  InitKGTCam: (cameraPath: string) => void; // 初始化攝影機
  GetCamList: () => string[]; // 取得影音裝置清單
  GetSerialNum: (cameraPath: string) => string; // 取得裝置序號
  /* GetKGTCamRange: (cameraPath: string, iamCamCtrlType: EIAMCamCtrlType) => number[];
  GetKGTCamValue: (cameraPath: string, iamCamCtrlType: EIAMCamCtrlType) => number[];
  SetKGTCamValue: (
    cameraPath: string,
    iamCamCtrlType: EIAMCamCtrlType,
    value: number,
    flag: number | ECameraControlFlag
  ) => void; */
}

