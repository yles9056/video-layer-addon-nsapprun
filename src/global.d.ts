/**
 * Define global variable for fscripts in src folder.
 * You can defint your own interface.
 * Below is an example of how to call in React component:
 * @example
 * const { example } = window;
 * example.foo.bar(...);
 * example.ping();
 */
declare global {
  interface Window {
    example: IExample;
    electron: IElectron;
    camera: ICamera;
    videoLayer: IVideoLayer;
  }
}

export interface ICamInfo {
  name: string;
  vid: string;
  pid: string;
  serialNumber: string;
  path: string;
}

export interface ICamInfoUI extends ICamInfo {
  id: string;
  isChecked: boolean;
}

// This is an interface for electron.ipcRenderer
export interface IElectron {
  ipcRenderer: {
    /**
     * Add a listener that listens to a channel.
     * @param channel The channel to listen to.
     * @param listener Listener function.
     * @returns A function that removes the listener when called.
     */
    on: (channel: string, listener: (...args: any[]) => void) => () => void;
    /**
     * Add a listener that listens to a channel. Only trigger once.
     * @param channel The channel to listen to.
     * @param listener Listener function.
     * @returns A function that removes the listener when called.
     */
    once: (channel: string, listener: (...args: any[]) => void) => () => void;
    /**
     * Sends args to main process via ipcRenderer.send()
     * @param channel
     * @param args
     */
    send: (channel: string, ...args: any[]) => void;
    /**
     * Sends args to main process via ipcRenderer.invoke()
     * @param channel
     * @param args
     * @returns A promise.
     */
    invoke: (channel: string, ...args: any[]) => Promise<any>;
  };
}

export interface ICamera {
  // 開啟攝影機
  openCamera(): void;
  // 關閉攝影機
  closeCamera(): void;
  // 取得所有攝影機裝置
  getCameras(): Promise<ICamInfoUI[]>;
  // 設定要使用的攝影機裝置
  setCamera(locationId: string): Promise<ICamInfoUI[]>;
}

export interface IVideoLayer {
  setVideoLayerPosition(x: number, y: number): void;
  setVideoLayerSize(width: number, height: number): void;
  onVideoLayerRequireResize(func: () => void): () => void;
}
