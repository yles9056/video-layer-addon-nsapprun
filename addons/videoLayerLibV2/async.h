#ifndef EXAMPLES_ASYNC_PI_ESTIMATE_ASYNC_H_
#define EXAMPLES_ASYNC_PI_ESTIMATE_ASYNC_H_

#include <napi.h>

Napi::Value GetCameraIsOpen(const Napi::CallbackInfo& info);
Napi::Value OpenCamera(const Napi::CallbackInfo& info);
Napi::Value CloseCamera(const Napi::CallbackInfo& info);
Napi::Value GetCameraLocationId(const Napi::CallbackInfo& info);
Napi::Value SetCameraLocationId(const Napi::CallbackInfo& info);
Napi::Value GetVideoLayerSize(const Napi::CallbackInfo& info);
Napi::Value SetVideoLayerSize(const Napi::CallbackInfo& info);
Napi::Value GetVideoLayerPosition(const Napi::CallbackInfo& info);
Napi::Value SetVideoLayerPosition(const Napi::CallbackInfo& info);
Napi::Value GetCameraResolution(const Napi::CallbackInfo& info);
Napi::Value SetCameraResolution(const Napi::CallbackInfo& info);

#endif  // EXAMPLES_ASYNC_PI_ESTIMATE_ASYNC_H_