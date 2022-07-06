// camera控制相關常數

/**
 * camera IPC事件
 */
export enum ECameraEvent {
  openCamera = "openCamera", // 前端請求打開攝影機
  closeCamera = "closeCamera", // 前端請求關閉攝影機
  getCameras = "getCameras", // 前端請求獲取攝影機清單
  setCamera = "setCamera", // 前端請求設定攝影機
  onCamerasChanged = "onCamerasChanged", // usb裝置插拔事件
}
