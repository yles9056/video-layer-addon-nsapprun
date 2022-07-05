//
//  VideoLayerHandler.h
//  KJMachPortServer
//
//  Created by Jonathan on 2022/7/2.
//  Copyright © 2022 Kristopher Johnson. All rights reserved.
//

#ifndef VideoLayerHandler_h
#define VideoLayerHandler_h

#ifdef __cplusplus
#import <iostream>
#endif

#include <AVFoundation/AVFoundation.h>
#include <AVFoundation/AVCaptureSession.h>
#import "remote_layer_api.h"

@interface VideoLayerHandler : NSObject

@property (atomic, assign) CAContextID contextId;

@property (atomic, strong) AVCaptureSession* _Nullable sess;
@property (atomic, strong) AVCaptureVideoPreviewLayer* _Nullable previewLayer;
@property (atomic, strong) NSArray* _Nullable deviceList;

@property (atomic, strong) NSString* _Nullable resolution;
@property (atomic, strong) NSArray* _Nullable pos;
@property (atomic, strong) NSArray* _Nullable sz;
@property (atomic, strong) AVCaptureDevice* _Nullable device;
@property (atomic, strong) NSString* _Nullable uniqueId;

- (void)initSessionLayer;

- (void) configLayer;
- (void) setLayerAnchorPoint:(CGFloat)x_axis
                           y:(CGFloat)y_axis;
- (void) setLayerResizeMethod;
- (void) setLayerBgColor:(CGFloat)r
                   green:(CGFloat)g
                    blue:(CGFloat)b
                   alpha:(CGFloat)a;
- (void) setLayerSize:(NSArray* _Nonnull)sz;
- (void) setLayerPosition:(NSArray* _Nonnull)pos;

- (void) startSession;
- (void) stopSession;

- (void) resetInputSignal;

- (void)exportLayer:(CALayer* _Nullable)gl_layer;

- (AVCaptureDevice* _Nullable) getDeviceByUniID:(NSString* _Nullable)uniId;
- (void) setSessionInput:(AVCaptureSession* _Nullable)sess device:(AVCaptureDevice* _Nullable)d;
@end

#endif /* VideoLayerHandler_h */
