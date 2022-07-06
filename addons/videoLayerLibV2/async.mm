#include "async.h" // NOLINT(build/include)
#include "Client.h"
#include "ServerProtocol.h"
#include <napi.h>

NSMutableData *convertFloatToNSData(float floatdata) {
  NSMutableData *nsdata = [NSMutableData dataWithCapacity:0];
  [nsdata appendBytes:&floatdata length:sizeof(float)];
  return nsdata;
}

float convertNSDataToFloat(NSData *nsdata) {
  float floatdata;
  [nsdata getBytes:&floatdata length:sizeof(float)];
  return floatdata;
}

NSString *convertNSDataToNSString(NSData *nsdata) {
  NSString *nsstring = [[NSString alloc] initWithData:nsdata
                                             encoding:NSUTF8StringEncoding];
  return nsstring;
}

NSData *convertNSStringToNSData(NSString *nsstring) {
  NSData *nsdata = [nsstring dataUsingEncoding:NSUTF8StringEncoding];
  return nsdata;
}

std::string convertNSDataToString(NSData *nsdata) {
  std::string strdata =
      [[[NSString alloc] initWithData:nsdata
                             encoding:NSUTF8StringEncoding] UTF8String];
  return strdata;
}

NSData *convertStringToNSData(std::string strdata) {
  NSData *nsdata = [[NSData alloc] initWithBytes:strdata.data()
                                          length:strdata.length()];
  return nsdata;
}

NSData *convertNSArrayToNSData(NSArray *nsarray) {
  NSData *nsdata = [NSKeyedArchiver archivedDataWithRootObject:nsarray];
  return nsdata;
}

NSArray *convertNSDataToNSArray(NSData *nsdata) {
  NSArray *nsarray = [NSKeyedUnarchiver unarchiveObjectWithData:nsdata];
  return nsarray;
}

NSData *convertBoolToNSData(bool boolean) {
  NSMutableData *nsdata = [NSMutableData dataWithCapacity:0];
  [nsdata appendBytes:&boolean length:sizeof(bool)];
  return nsdata;
}

bool convertNSDataToBool(NSData *nsdata) {
  bool boolean;
  [nsdata getBytes:&boolean length:sizeof(bool)];
  return boolean;
}

class ClientWorker : public Napi::AsyncWorker {
public:
  ClientWorker(Napi::Function &callback, uint32_t msgId, NSData *payload)
      : Napi::AsyncWorker(callback), msgId(msgId), payload(payload),
        receivedData(NULL) {
    client = [[Client alloc] init];
  }
  ~ClientWorker() { [client dealloc]; }
  void Execute() {
    switch (msgId) {
    case ServerGetCameraIsOpen:
    case ServerOpenCamera:
    case ServerCloseCamera:
    case ServerGetCameraLocationId:
    case ServerGetCameraResolution:
    case ServerGetVideoLayerSize:
    case ServerGetVideoLayerPosition:
      receivedData = [client sendVideoLayerMessage:msgId];
      break;
    case ServerSetCameraLocationId:
    case ServerSetCameraResolution:
      receivedData = [client sendVideoLayerMessage:msgId withPayload:payload];
      break;
    }
  }
  void OnOK() {
    switch (msgId) {
    case ServerGetCameraIsOpen:
    case ServerOpenCamera:
    case ServerCloseCamera: {
      bool resBool = convertNSDataToBool(receivedData);
      Callback().Call({Env().Undefined(), Napi::Boolean::New(Env(), resBool)});
    } break;
    case ServerGetVideoLayerSize:
    case ServerGetVideoLayerPosition: {
      NSArray *resMM = convertNSDataToNSArray(receivedData);
      Napi::Float32Array resCPP = Napi::Float32Array::New(Env(), [resMM count]);
      for (int i = 0; i < [resMM count]; i++) {
        resCPP[i] = convertNSDataToFloat(resMM[i]);
      }
      Callback().Call({Env().Undefined(), resCPP});
    } break;
    case ServerGetCameraLocationId:
    case ServerSetCameraLocationId:
    case ServerGetCameraResolution:
    case ServerSetCameraResolution: {
      std::string cameraLocationId = convertNSDataToString(receivedData);
      Callback().Call(
          {Env().Undefined(), Napi::String::New(Env(), cameraLocationId)});
    } break;
    default:
      Callback().Call({Env().Undefined()});
    }
  }

protected:
  uint32_t msgId;
  NSData *payload;
  NSData *receivedData;
  Client *client;
};

class ClientWorkerArray : public ClientWorker {
public:
  ClientWorkerArray(Napi::Function &callback, uint32_t msgId,
                    std::vector<float> &floatArr)
      : ClientWorker(callback, msgId, NULL), floatArr(floatArr) {}
  void Execute() {
    switch (msgId) {
    case ServerSetVideoLayerSize:
    case ServerSetVideoLayerPosition:
      NSLog(@"ClientWorkerArray %f %f", floatArr[0], floatArr[1]);
      NSMutableData *val0 = convertFloatToNSData(floatArr[0]);
      NSMutableData *val1 = convertFloatToNSData(floatArr[1]);
      NSData *payload = convertNSArrayToNSData(@[ val0, val1 ]);
      receivedData = [client sendVideoLayerMessage:msgId withPayload:payload];
      break;
    }
  }
  void OnOK() {
    switch (msgId) {
    case ServerSetVideoLayerSize:
    case ServerSetVideoLayerPosition: {
      NSArray *resMM = convertNSDataToNSArray(receivedData);
      Napi::Float32Array resCPP = Napi::Float32Array::New(Env(), [resMM count]);
      for (int i = 0; i < [resMM count]; i++) {
        resCPP[i] = convertNSDataToFloat(resMM[i]);
      }
      Callback().Call({Env().Undefined(), resCPP});
    } break;
    default:
      Callback().Call({Env().Undefined()});
    }
  }

protected:
  std::vector<float> floatArr;
};

Napi::Value GetCameraIsOpen(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerGetCameraIsOpen, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value OpenCamera(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerOpenCamera, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value CloseCamera(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerCloseCamera, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value GetCameraLocationId(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerGetCameraLocationId, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value SetCameraLocationId(const Napi::CallbackInfo &info) {
  std::string locationId = info[0].ToString().Utf8Value();
  Napi::Function callback = info[1].As<Napi::Function>();

  NSData *payload = convertStringToNSData(locationId);
  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerSetCameraLocationId, payload);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value GetVideoLayerSize(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerGetVideoLayerSize, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value SetVideoLayerSize(const Napi::CallbackInfo &info) {
  float szW = info[0].As<Napi::Number>().FloatValue();
  float szH = info[1].As<Napi::Number>().FloatValue();
  Napi::Function callback = info[2].As<Napi::Function>();

  NSLog(@"$SetVideoLayerSize %f %f", szW, szH);

  std::vector<float> szMM = {szW, szH};

  ClientWorker *clientWorker =
      new ClientWorkerArray(callback, ServerSetVideoLayerSize, szMM);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value GetVideoLayerPosition(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerGetVideoLayerPosition, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value SetVideoLayerPosition(const Napi::CallbackInfo &info) {
  float posX = info[0].As<Napi::Number>().FloatValue();
  float posY = info[1].As<Napi::Number>().FloatValue();
  Napi::Function callback = info[2].As<Napi::Function>();

  NSLog(@"$SetVideoLayerPosition %f %f", posX, posY);

  std::vector<float> posMM = {posX, posY};

  ClientWorkerArray *clientWorker =
      new ClientWorkerArray(callback, ServerSetVideoLayerPosition, posMM);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value GetCameraResolution(const Napi::CallbackInfo &info) {
  Napi::Function callback = info[0].As<Napi::Function>();

  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerGetCameraResolution, NULL);
  clientWorker->Queue();

  return info.Env().Undefined();
}

Napi::Value SetCameraResolution(const Napi::CallbackInfo &info) {
  std::string resolution = info[0].ToString().Utf8Value();
  Napi::Function callback = info[1].As<Napi::Function>();

  NSData *payload = convertStringToNSData(resolution);
  ClientWorker *clientWorker =
      new ClientWorker(callback, ServerSetCameraResolution, payload);
  clientWorker->Queue();

  return info.Env().Undefined();
}