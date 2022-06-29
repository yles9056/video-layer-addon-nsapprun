// video layer控制相關常數

/**
 * video layer IPC事件
 */
export enum EVideoLayerEvent {
  setVideoLayerPosition = 'setVideoLayerPosition', // 前端請求設定video layer位置
  setVideoLayerSize = 'setVideoLayerSize', // 前端請求設定video layer大小
  onVideoLayerRequireResize = 'onVideoLayerRequireResize' // 後端請求前端回傳顯示區域大小
}
