// video layer控制相關介面

/**
 * video layer控制模組介面
 */
export interface IVideoLayerLib {
  // 模組相關
  initVideoLayer: (bufferData: Buffer) => void; // 初始化  bufferData為指向UI視窗的記憶體位置 可以轉換成NSView
  destroyVideoLayer: () => void;
  // 攝影機相關
  getCameraIsOpen: () => boolean; // 攝影機是否開啟 攝影機已開啟則回傳true
  getCameraLocationId: () => string; // 取得video layer控制模組正在使用攝影機的locationId
  setCameraLocationId: (locationId: string) => string; // 設定攝影機locationId
  openCamera: () => boolean; // 開啟攝影機 執行成功則回傳true
  closeCamera: () => boolean; // 關閉攝影機 執行成功則回傳true
  getSupportedResolution: () => string[]; // 列出可用解析度
  getCameraResolution: () => string; // 取得目前使用解析度 {width}x{height}     ex: 1280x720
  setCameraResolution: (resolution: string) => string; // 設定目前使用解析度 {width}x{height}     ex: 1280x720
  // 視窗控制相關
  getVideoLayerPosition: () => [number, number]; // 取得位置 [x, y]
  setVideoLayerPosition: (x: number, y: number) =>[number, number]; // 設定位置 [x, y]
  getVideoLayerSize: () => [number, number]; // 取得大小 [width, height]
  setVideoLayerSize: (width: number, height: number) => [number, number]; // 設定大小 [width, height]
}
