#include <napi.h>
#include <node.h>
//#include <nan.h>
#include <iostream>
#include <stdio.h>
// #include "addon_osx.h"
#include "renderer_app.h"

CAContextID CAid = 100;

namespace VideoLayerLib
{
	/*using v8::Context;
	using v8::FunctionCallbackInfo;
	using v8::Isolate;
	using v8::Local;
	using v8::Object;
	using v8::String;
	using v8::Value;*/
/*Napi::String Method(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  return Napi::String::New(env, "world");
}

Napi::Value openCam(const Napi::CallbackInfo& info){
  //RendererApp client_app;
  CAid = initLayer();
  std::cout << "CAid: " << CAid << "\n";
  run();
}

Napi::Value createWindowJS(const Napi::CallbackInfo& info) {
  std::string name = info[0].ToString().Utf8Value();
  Napi::Buffer<void*> bufferData = info[1].As<Napi::Buffer<void*>>();
  //double id = info[2];
  std::cout << "createWindowJS " << info[1] << "\n";
  //std::cout << "id " << info[2] << "\n";
  createWindow(name, bufferData.Data(), CAid);  
  return info.Env().Undefined();
}*/

Napi::Value initVideoLayer(const Napi::CallbackInfo& info)
{
  Napi::Buffer<void*> bufferData = info[0].As<Napi::Buffer<void*>>();
  initVideoLayerMM(bufferData.Data());
  return info.Env().Undefined();
}

Napi::Value destroyVideoLayer(const Napi::CallbackInfo& info)
{
  destroyVideoLayerMM();
  return info.Env().Undefined();
}

/*Napi::Value getCameraIsOpen(const Nan::FunctionCallbackInfo<v8::Value>& info)
{
  return info.Env();
}*/

Napi::String getCameraLocationId(const Napi::CallbackInfo& info) //抓取現在的設備
{
  // Input
  Napi::Env env = info.Env();
  // Code
  std::string deviceLocationId = getCameraLocationIdMM();
  // Output
  return Napi::String::New(env, deviceLocationId);
}

Napi::Boolean setCameraLocationId(const Napi::CallbackInfo& info) //切換新的設備 switchToDevice
{
  // Input
  Napi::Env env = info.Env();
  std::string locationId = info[0].ToString().Utf8Value();

  // Code & Output
  bool isSetLocationId = setCameraLocationIdMM(locationId);
  return Napi::Boolean::New(env, isSetLocationId);
}

Napi::Boolean openCamera(const Napi::CallbackInfo& info) //runSession
{
  // Input
  Napi::Env env = info.Env();

  // Code
  bool isConfigSucceed = openCameraMM();

  return Napi::Boolean::New(env, isConfigSucceed);
}

Napi::Boolean closeCamera(const Napi::CallbackInfo& info) //stopSession
{
  // Input
  Napi::Env env = info.Env();
  // Code
  bool isStopSession = closeCameraMM();
  // Output
  return Napi::Boolean::New(env, isStopSession);
}

Napi::Value getSupportedResolution(const Napi::CallbackInfo& info) //直接訂
{
  //v8::Isolate* isolate = info.GetIsolate();
  Napi::Env env = info.Env();
  std::string strresolutionlist[4] = {"640x480", "960x540", "1280x720", "1920x1080"};

  Napi::Array arr = Napi::Array::New(env, 4);
  for(int i=0;i<3;i++)
  {
    arr[i] = Napi::String::New(env, strresolutionlist[i]);
  }
  return arr;
}

Napi::String getCameraResolution(const Napi::CallbackInfo& info) //抓取現在的設備
{
  // Input
  Napi::Env env = info.Env();
  // Code
  std::string resolution = getCameraResolutionMM();
  // Output
  return Napi::String::New(env, resolution);
}

Napi::Boolean setCameraResolution(const Napi::CallbackInfo& info) //switchToResolution
{
  // Input
  
  Napi::Env env = info.Env();
  std::string strArg0 = info[0].ToString().Utf8Value();
  std::string resolution = "AVCaptureSessionPreset" + strArg0;

  // Code & Output
  return Napi::Boolean::New(env, setCameraResolutionMM(resolution));
}

Napi::Float32Array getVideoLayerPosition(const Napi::CallbackInfo& info)
{
  std::vector<float> posMM =  getVideoLayerPositionMM();
  Napi::Float32Array posCPP = Napi::Float32Array::New(info.Env(), 2);
  
  for(int i=0;i<2;i++)
    posCPP[i] = posMM[i];

  return posCPP;
}

void setVideoLayerPosition(const Napi::CallbackInfo& info)
{
  float posX = info[0].As<Napi::Number>().FloatValue();
  float posY = info[1].As<Napi::Number>().FloatValue();

  std::vector<float> posMM = {posX, posY};

  setVideoLayerPositionMM(posMM);
}

Napi::Float32Array getVideoLayerSize(const Napi::CallbackInfo& info)
{
  std::vector<float> szMM =  getVideoLayerSizeMM();
  Napi::Float32Array szCPP = Napi::Float32Array::New(info.Env(), 2);
  
  for(int i=0;i<2;i++)
    szCPP[i] = szMM[i];

  return szCPP;
}

void setVideoLayerSize(const Napi::CallbackInfo& info)
{
  float szW = info[0].As<Napi::Number>().FloatValue();
  float szH = info[1].As<Napi::Number>().FloatValue();

  std::vector<float> szMM = {szW, szH};

  setVideoLayerSizeMM(szMM);
}

// Napi::Value initrun(const Napi::CallbackInfo& info){
//   //RendererApp client_app;
//   std::cout<<"testrunCam"<<std::endl;
//   CAid = initapp(); 
//   // run();
// }

// Napi::Value runCam(const Napi::CallbackInfo& info){
//   //RendererApp client_app;
//   std::cout<<"testrunCam"<<std::endl;
//   // run();
// }

/*void getVideoLayerPosition(const Napi::CallbackInfo& info)
{
  Napi::Env env = info.Env();
  //v8::Isolate* isolate = info.GetIsolate();

  Napi::Array Napi::Array::New(info.Env(), 2);
  for(int i=0;i<2;i++)
  {
    Napi::Float32Array::New(env, result);
  }
}

void setVideoLayerPosition(const Napi::CallbackInfo& info)
{
  Napi::Env env = info.Env();
  //v8::Isolate* isolate = info.GetIsolate();
  Napi::Array array = info[0].As<Array>();

}

void getVideoLayerSize(const Napi::CallbackInfo& info)
{
  Napi::Env env = info.Env();
  //v8::Isolate* isolate = info.GetIsolate();
  Napi::Array Napi::Array::New(info.Env(), 2);
  for(int i=0;i<2;i++)
  {}
}

void setVideoLayerSize(const Napi::CallbackInfo& info)
{
  Napi::Env env = info.Env();
  //v8::Isolate* isolate = info.GetIsolate();
  Napi::Array array = info[0].As<Array>();
}*/

  /*destroyVideoLayer: () => void;
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
  setVideoLayerSize: (wi*/

Napi::Object Init(Napi::Env env, Napi::Object exports)
{
  //CAid = initapp(); 
  /*exports->Set(Nan::GetCurrentContext(),
              Nan::New("initVideoLayer").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(initVideoLayer)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("destroyVideoLayer").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(destroyVideoLayer)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("getCameraLocationId").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(getCameraLocationId)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("setCameraLocationId").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(setCameraLocationId)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("openCamera").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(openCamera)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("closeCamera").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(closeCamera)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("getSupportedResolution").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(getSupportedResolution)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("getCameraResolution").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(getCameraResolution)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("setCameraResolution").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(setCameraResolution)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("getVideoLayerPosition").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(getVideoLayerPosition)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("setVideoLayerPosition").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(setVideoLayerPosition)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("getVideoLayerSize").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(getVideoLayerSize)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());
  exports->Set(Nan::GetCurrentContext(),
              Nan::New("setVideoLayerSize").ToLocalChecked(), // the exported name
              Nan::New<v8::FunctionTemplate>(setVideoLayerSize)->GetFunction(Nan::GetCurrentContext()).ToLocalChecked());*/
  exports.Set(Napi::String::New(env, "initVideoLayer"),
              Napi::Function::New(env, initVideoLayer));
  exports.Set(Napi::String::New(env, "destroyVideoLayer"),
              Napi::Function::New(env, destroyVideoLayer));
  exports.Set(Napi::String::New(env, "getCameraLocationId"),
              Napi::Function::New(env, getCameraLocationId));
  exports.Set(Napi::String::New(env, "setCameraLocationId"),
              Napi::Function::New(env, setCameraLocationId));
  exports.Set(Napi::String::New(env, "openCamera"),
              Napi::Function::New(env, openCamera));
  exports.Set(Napi::String::New(env, "closeCamera"),
              Napi::Function::New(env, closeCamera));
  exports.Set(Napi::String::New(env, "getSupportedResolution"),
              Napi::Function::New(env, getSupportedResolution));
  exports.Set(Napi::String::New(env, "setCameraResolution"),
              Napi::Function::New(env, setCameraResolution));
  exports.Set(Napi::String::New(env, "getVideoLayerPosition"),
              Napi::Function::New(env, getVideoLayerPosition));
  exports.Set(Napi::String::New(env, "setVideoLayerPosition"),
              Napi::Function::New(env, setVideoLayerPosition));
  exports.Set(Napi::String::New(env, "getVideoLayerSize"),
              Napi::Function::New(env, getVideoLayerSize));
  exports.Set(Napi::String::New(env, "setVideoLayerSize"),
              Napi::Function::New(env, setVideoLayerSize));
  // exports.Set(Napi::String::New(env, "runCam"),
  //             Napi::Function::New(env, runCam));
  // exports.Set(Napi::String::New(env, "initrun"),
  //             Napi::Function::New(env, initrun));
  return exports;
}

//NODE_MODULE(addon, Init)
NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)
}