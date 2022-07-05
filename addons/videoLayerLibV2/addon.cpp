#include <napi.h>
#include <node.h>
#include <stdio.h>
#include <iostream>
#include "addon_osx.h"

namespace VideoLayerLib {
Napi::Value initVideoLayerJS(const Napi::CallbackInfo& info) {
  Napi::Buffer<void*> windowHandle = info[0].As<Napi::Buffer<void*>>();
  unsigned contextId = info[1].As<Napi::Number>().Uint32Value();
  initVideoLayer(windowHandle.Data(), contextId);
  return info.Env().Undefined();
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "initVideoLayer"),
              Napi::Function::New(env, initVideoLayerJS));
  return exports;
}

NODE_API_MODULE(NODE_GYP_MODULE_NAME, Init);
}  // namespace VideoLayerLib
