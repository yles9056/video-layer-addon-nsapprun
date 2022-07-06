import { contextBridge, ipcRenderer } from "electron";
import { ECameraEvent } from "./const";
import { ICamInfoUI } from "./interface";

contextBridge.exposeInMainWorld("camera", {
  openCamera() {
    ipcRenderer.send(ECameraEvent.openCamera);
  },
  closeCamera() {
    ipcRenderer.send(ECameraEvent.closeCamera);
  },
  getCameras(): Promise<ICamInfoUI[]> {
    return ipcRenderer.invoke(ECameraEvent.getCameras);
  },
  setCamera(locationId: string): Promise<ICamInfoUI[]> {
    return ipcRenderer.invoke(ECameraEvent.setCamera, locationId);
  },
  onCamerasChanged(func: () => void): () => void {
    const listener = (event: Electron.IpcRendererEvent) => {
      func();
    };
    ipcRenderer.on(ECameraEvent.onCamerasChanged, listener);
    return () => {
      ipcRenderer.removeListener(ECameraEvent.onCamerasChanged, listener);
    };
  },
});
