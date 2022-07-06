import { contextBridge, ipcRenderer } from "electron";
import { EVideoLayerEvent } from "./const";

contextBridge.exposeInMainWorld('videoLayer', {
  setVideoLayerPosition(x: number, y: number) {
    ipcRenderer.send(EVideoLayerEvent.setVideoLayerPosition, x, y);
  },
  setVideoLayerSize(width: number, height: number) {
    ipcRenderer.send(EVideoLayerEvent.setVideoLayerSize, width, height);
  },
  onVideoLayerRequireResize(func: () => void): () => void {
    const listener = (event: Electron.IpcRendererEvent) => {
      func();
    };
    ipcRenderer.on(EVideoLayerEvent.onVideoLayerRequireResize, listener);
    return () => {
      ipcRenderer.removeListener(EVideoLayerEvent.onVideoLayerRequireResize, listener);
    };
  }
});
