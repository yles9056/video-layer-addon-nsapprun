// video layer控制相關介面

/**
 * video layer控制模組介面
 */
export interface IVideoLayerLib {
  // 模組相關
  initVideoLayer: (contextId: number, bufferData: Buffer) => void; // 初始化  bufferData為指向UI視窗的記憶體位置 可以轉換成NSView
  destroyVideoLayer: () => void;
  // 攝影機相關
  getCameraIsOpen: (
    callback: (
      err: Error | null | undefined,
      isCameraOpen: boolean | undefined
    ) => void
  ) => void; // 攝影機是否開啟 攝影機已開啟則回傳true
  openCamera: (
    callback: (
      err: Error | null | undefined,
      isSuccessful: boolean | undefined
    ) => void
  ) => void; // 開啟攝影機 執行成功則回傳true
  closeCamera: (
    callback: (
      err: Error | null | undefined,
      isSuccessful: boolean | undefined
    ) => void
  ) => void; // 關閉攝影機 執行成功則回傳true
  getCameraLocationId: (
    callback: (
      err: Error | null | undefined,
      cameraLocationId: string | undefined
    ) => void
  ) => void; // 取得video layer控制模組正在使用攝影機的locationId
  setCameraLocationId: (
    locationId: string,
    callback: (
      err: Error | null | undefined,
      cameraLocationId: string | undefined
    ) => void
  ) => void; // 設定攝影機locationId

  getSupportedResolution: () => string[]; // 列出可用解析度
  getCameraResolution: (
    callback: (
      err: Error | null | undefined,
      resolution: string | undefined
    ) => void
  ) => void; // 取得目前使用解析度 {width}x{height}     ex: 1280x720
  setCameraResolution: (
    resolution: string,
    callback: (
      err: Error | null | undefined,
      resolution: string | undefined
    ) => void
  ) => void; // 設定目前使用解析度 {width}x{height}     ex: 1280x720
  // 視窗控制相關
  getVideoLayerPosition: (
    callback: (
      err: Error | null | undefined,
      position: [number, number] | undefined
    ) => void
  ) => void; // 取得位置 [x, y]
  setVideoLayerPosition: (
    x: number,
    y: number,
    callback: (
      err: Error | null | undefined,
      position: [number, number] | undefined
    ) => void
  ) => void; // 設定位置 [x, y]
  getVideoLayerSize: (
    callback: (
      err: Error | null | undefined,
      size: [number, number] | undefined
    ) => void
  ) => void; // 取得大小 [width, height]
  setVideoLayerSize: (
    width: number,
    height: number,
    callback: (
      err: Error | null | undefined,
      size: [number, number] | undefined
    ) => void
  ) => void; // 設定大小 [width, height]
}
