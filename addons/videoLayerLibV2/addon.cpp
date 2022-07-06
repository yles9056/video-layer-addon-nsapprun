#include <napi.h>

#include <iostream>

#include "addon_osx.h"
#include "async.h"

Napi::Value initVideoLayerJS(const Napi::CallbackInfo& info) {
  unsigned contextId = info[0].As<Napi::Number>().Uint32Value();
  Napi::Buffer<void*> bufferData = info[1].As<Napi::Buffer<void*>>();

  initVideoLayer(contextId, bufferData.Data());

  return info.Env().Undefined();
}

Napi::Value destroyVideoLayerJS(const Napi::CallbackInfo& info) {
  destroyVideoLayer();

  return info.Env().Undefined();
}

Napi::Value GetSupportedResolution(const Napi::CallbackInfo& info)  //直接訂
{
  Napi::Env env = info.Env();
  std::string strresolutionlist[4] = {"640x480", "960x540", "1280x720",
                                      "1920x1080"};

  Napi::Array arr = Napi::Array::New(env, 4);
  for (int i = 0; i < 3; i++) {
    arr[i] = Napi::String::New(env, strresolutionlist[i]);
  }
  return arr;
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "initVideoLayer"),
              Napi::Function::New(env, initVideoLayerJS));
  exports.Set(Napi::String::New(env, "destroyVideoLayer"),
              Napi::Function::New(env, destroyVideoLayerJS));

  exports.Set(Napi::String::New(env, "getCameraIsOpen"),
              Napi::Function::New(env, GetCameraIsOpen));
  exports.Set(Napi::String::New(env, "openCamera"),
              Napi::Function::New(env, OpenCamera));
  exports.Set(Napi::String::New(env, "closeCamera"),
              Napi::Function::New(env, CloseCamera));

  exports.Set(Napi::String::New(env, "getCameraLocationId"),
              Napi::Function::New(env, GetCameraLocationId));
  exports.Set(Napi::String::New(env, "setCameraLocationId"),
              Napi::Function::New(env, SetCameraLocationId));

  exports.Set(Napi::String::New(env, "getVideoLayerSize"),
              Napi::Function::New(env, GetVideoLayerSize));
  exports.Set(Napi::String::New(env, "setVideoLayerSize"),
              Napi::Function::New(env, SetVideoLayerSize));

  exports.Set(Napi::String::New(env, "getVideoLayerPosition"),
              Napi::Function::New(env, GetVideoLayerPosition));
  exports.Set(Napi::String::New(env, "setVideoLayerPosition"),
              Napi::Function::New(env, SetVideoLayerPosition));

  exports.Set(Napi::String::New(env, "getSupportedResolution"),
              Napi::Function::New(env, GetSupportedResolution));
  exports.Set(Napi::String::New(env, "getCameraResolution"),
              Napi::Function::New(env, GetCameraResolution));
  exports.Set(Napi::String::New(env, "setCameraResolution"),
              Napi::Function::New(env, SetCameraResolution));

  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init)