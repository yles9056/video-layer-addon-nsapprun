import _ from "lodash";
import { useCallback, useEffect, useRef, useState } from "react";
import { ICamInfoUI } from "../../global";

const { camera, videoLayer } = window;

const DisplayArea = () => {
  const displayRef = useRef<HTMLDivElement>(null);

  const updateVideoLayerSize = useCallback(() => {
    if (displayRef.current) {
      let rect = displayRef.current.getBoundingClientRect();
      console.log("DisplayArea", "useVideoControl", rect);
      videoLayer.setVideoLayerPosition(
        rect.x,
        window.innerHeight - rect.bottom
      ); //修改座標
      //videoLayer.setVideoLayerPosition(10, 10);
      //videoLayer.setVideoLayerSize(rect.width, rect.height);
      videoLayer.setVideoLayerSize(rect.width, rect.height);
      //videoLayer.setVideoLayerSize(1280, 720);
    } else {
      console.warn("DisplayArea", "displayRef is null");
    }
  }, []);

  // 初始化
  useEffect(() => {
    updateVideoLayerSize();
    let rmFunc = videoLayer.onVideoLayerRequireResize(() => {
      setTimeout(() => {
        updateVideoLayerSize();
      }, 0);
    });
    return () => {
      rmFunc();
    };
  }, [updateVideoLayerSize]);

  return (
    <div style={{ flexGrow: 1, background: "lightgray" }} ref={displayRef}>
      display area
    </div>
  );
};

// 攝影機控制列
const CameraControlBar = () => {
  const [_cameras, setCameras] = useState<ICamInfoUI[]>([]); // 攝影機清單
  const isSelectedCameraChanged = useRef(false); // 使用者是否變更過攝影機清單
  const [selectedCameraPath, setSelectedCameraPath] = useState(""); // 目前選定攝影機的path/locationId

  // 比較新獲取到的攝影機清單與目前清單是否有差異，有差異才會更新
  const compareData = useCallback(
    (newData: ICamInfoUI[]) => {
      console.log("CameraBar", "compareData", newData);
      if (_cameras.length !== newData.length || !_.isEqual(_cameras, newData)) {
        setCameras(newData);
      }

      let _newSelectedCamera = _.find(newData, { isChecked: true });
      let newSelectedCameraPath = _newSelectedCamera
        ? _newSelectedCamera.path
        : "";
      if (newSelectedCameraPath !== selectedCameraPath) {
        setSelectedCameraPath(newSelectedCameraPath);
      }
    },
    [_cameras, selectedCameraPath]
  );

  // 獲取新的攝影機清單
  const getCameras = useCallback(() => {
    camera.getCameras().then((newData) => {
      compareData(newData);
    });
  }, [compareData]);

  // 發送切換攝影機請求至後端，並獲取新的攝影機清單
  const setCamera = useCallback(() => {
    if (selectedCameraPath === "") {
    } else {
      camera.setCamera(selectedCameraPath).then((newData) => {
        compareData(newData);
      });
    }
  }, [selectedCameraPath, compareData]);

  // 初始化
  useEffect(() => {
    //console.log('test');
    getCameras();
    //console.log('test');
  }, []);

  // 使用者切換攝影機後發送請求至後端
  useEffect(() => {
    if (isSelectedCameraChanged.current) {
      isSelectedCameraChanged.current = false;
      setCamera();
    }
  }, [selectedCameraPath, setCamera]);

  // 使用者切換攝影機
  const changeCamera = (e: React.ChangeEvent<HTMLSelectElement>) => {
    isSelectedCameraChanged.current = true;
    let newSelectedCamera = _.find(_cameras, { path: e.target.value });
    if (newSelectedCamera) {
      setSelectedCameraPath(e.target.value);
    } else {
      setSelectedCameraPath("");
    }
  };

  // 開啟攝影機
  const openCamera = () => {
    camera.openCamera();
  };

  // 關閉攝影機
  const closeCamera = () => {
    camera.closeCamera();
  };

  return (
    <div
      style={{
        display: "flex",
        flexDirection: "row",
        justifyContent: "center",
        marginTop: "20px",
        marginBottom: "20px",
      }}
    >
      <label htmlFor="cameras" style={{ marginRight: "0.2em" }}>
        Choose a camera:
      </label>
      <select
        name="cameras"
        id="cameras"
        value={selectedCameraPath}
        onChange={changeCamera}
        style={{ marginRight: "1em" }}
      >
        <option value="" disabled>
          --
        </option>
        {_.map(_cameras, (_camera) => {
          return (
            <option key={_camera.id} value={_camera.path}>
              {_camera.name}
            </option>
          );
        })}
      </select>
      <button onClick={getCameras} style={{ marginRight: "1em" }}>
        Refresh camera list
      </button>
      <button onClick={openCamera} style={{ marginRight: "0.2em" }}>
        Open camera
      </button>
      <button onClick={closeCamera}>Close camera</button>
    </div>
  );
};

const VideoView = () => {
  return (
    <div
      style={{
        width: "calc(100vw - 20px)",
        height: "calc(100vh - 30px)",
        display: "flex",
        flexDirection: "column",
      }}
    >
      <DisplayArea />
      <CameraControlBar />
    </div>
  );
};
export default VideoView;
