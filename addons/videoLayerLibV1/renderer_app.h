#ifndef CA_LAYERS_RENDERER_APP_H
#define CA_LAYERS_RENDERER_APP_H

#include "stdio.h"
#include <iostream>
#include <vector>
#include <string>
#include <memory>
#import <Foundation/Foundation.h>
// #import "AppDelegate.h"
// #import "/Users/user/Documents/thermossmartlid_ios/Thermos/AppDelegate.h"
#include <AVFoundation/AVFoundation.h>
#include <AVFoundation/AVCaptureSession.h>
#import "remote_layer_api.h"

// @interface threadApp: NSObject

// - (void) run;
// - (void) start;
// @end

@interface RendererApp: NSObject


@property (atomic, strong) AVCaptureSession* sess;
@property (atomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (atomic, strong) NSArray* deviceList;

@property (atomic, strong) NSString* resolution;
@property (atomic, strong) NSArray* pos;
@property (atomic, strong) NSArray* sz;
@property (atomic, strong) AVCaptureDevice* device;
@property (atomic, strong) NSString* uniqueId;
@property (atomic, strong) NSNotificationCenter* notiCenter;
@property (atomic, strong) id add;
@property (atomic, strong) id remove;

- (void) initSessionLayer;

- (void) configLayer;
- (void) setLayerAnchorPoint:(CGFloat)x_axis
                            y:(CGFloat)y_axis;
- (void) setLayerResizeMethod;
- (void) setLayerBgColor:(CGFloat)r 
                    green:(CGFloat)g
                    blue:(CGFloat)b
                    alpha:(CGFloat)a;
- (void) setLayerSize:(NSArray*)sz;
- (void) setLayerPosition:(NSArray*)pos;
- (CAContextID) getLayerId;

- (AVCaptureDevice*) getCameraDeviceByUniID:(std::string)uniId_string;
- (AVCaptureDeviceInput*) getDeviceInputByDevice:(AVCaptureDevice*)device;
- (void) setSessionInput:(AVCaptureSession*)sess device:(AVCaptureDevice*)d;
- (void) startSession;
- (void) stopSession;
- (bool) setSessionResolution:(NSString*) preset;

- (void) listAllDevices;
- (NSArray*) getBuildInCameraDevices;
- (NSArray*) getExternelCameraDevices;
- (NSArray*) getAllCameraDevices;

- (void) resetInputSignal;
- (void) refreshList;

@end

// Call for addon.cpp
void initVideoLayerMM(void **handle);
void destroyVideoLayerMM();
bool getCameraIsOpenMM();
std::string getCameraLocationIdMM();
bool setCameraLocationIdMM(std::string uniId_string);
bool openCameraMM();
bool closeCameraMM();
std::string getCameraResolutionMM();
bool setCameraResolutionMM(std::string resolutionStr);
std::vector<float> getVideoLayerPositionMM();
void setVideoLayerPositionMM(std::vector<float> pos);
std::vector<float> getVideoLayerSizeMM();
void setVideoLayerSizeMM(std::vector<float> sz);

#endif // CA_LAYERS_RENDERER_APP_H
