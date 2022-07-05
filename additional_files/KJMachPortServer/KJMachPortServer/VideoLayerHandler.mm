//
//  VideoLayerHandler.m
//  KJMachPortServer
//
//  Created by Jonathan on 2022/7/2.
//  Copyright © 2022 Kristopher Johnson. All rights reserved.
//

#define GL_SILENCE_DEPRECATION
#define DEV 1

#if DEV
#define Log(fmt, ...) {NSLog(@"%@", [NSString stringWithUTF8String:fmt]);}
#else
#define Log(format, ...)
#endif

#import "VideoLayerHandler.h"

@implementation VideoLayerHandler

- (void)initSessionLayer {
    Log("Session and AVCaptureVideoPreviewLayer initialized.");
    self.sess = [[AVCaptureSession alloc] init];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sess];
    self.deviceList = [self getAllCameraDevices];
    //[self.previewLayer setZPosition:999];
    //[self.previewLayer setDrawsAsynchronously:YES];
    
    // Default setting
    // Note: set the default device to list[0]
    //self.resolution = AVCaptureSessionPreset1280x720;
    self.resolution = NULL;
    self.pos = @[@(0), @(0)];
    self.sz = @[@(640), @(360)];
    
    if ([self.deviceList count] > 0) {
        self.device = self.deviceList[0];
        self.uniqueId = [self.device uniqueID];
    } else {
        self.device = NULL;
        self.uniqueId = NULL;
    }
}

- (void) configLayer {
    Log("Config the layer to the default setting.");
    // Default setting
    CGFloat x_anchor = 0;
    CGFloat y_anchor = 0;
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    
    [self setLayerResizeMethod];
    [self setLayerBgColor:red green:green blue:blue alpha:alpha];
    [self setLayerAnchorPoint:x_anchor y:y_anchor];
    [self setLayerSize:self.sz];
    [self setLayerPosition:self.pos];
}

- (void) setLayerAnchorPoint:(CGFloat)x_axis
                           y:(CGFloat)y_axis {
    if (DEV) {
        std::string x_str = std::to_string((float)x_axis);
        std::string y_str = std::to_string((float)y_axis);
        Log(("Set the Anchor point of video layer ("+ x_str + "," + y_str + ").").c_str());
    }
    
    [self.previewLayer setAnchorPoint:CGPointMake(0, 0)];
}

- (void) setLayerResizeMethod {
    Log("Set the video layer to the default resize method.");
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
}

- (void) setLayerBgColor:(CGFloat)r
                   green:(CGFloat)g
                    blue:(CGFloat)b
                   alpha:(CGFloat)a {
    // component value only range (0.0 - 1.0)
    Log("Set the background color of video layer.");
    [self.previewLayer setBackgroundColor:CGColorCreateGenericRGB(r, g, b, a)];
}

- (void) setLayerSize:(NSArray*)sz {
    if (DEV) {
        std::string w_mm = std::to_string([sz[0] floatValue]);
        std::string h_mm = std::to_string([sz[1] floatValue]);
        Log(("Set the size of video layer ("+ w_mm + "," + h_mm + ").").c_str());
    }
    
    
    [self.previewLayer setBounds:CGRectMake(0, 0, [(NSNumber*)[sz objectAtIndex:0] intValue],
                                            [(NSNumber*)[sz objectAtIndex:1] intValue])];
}

- (void) setLayerPosition:(NSArray*)pos {
    if (DEV) {
        std::string x_mm = std::to_string([pos[0] floatValue]);
        std::string y_mm = std::to_string([pos[1] floatValue]);
        Log(("Set the position of video layer ("+ x_mm + "," + y_mm + ").").c_str());
    }
    
    [self.previewLayer setPosition:CGPointMake([(NSNumber*)[pos objectAtIndex:0] intValue],
                                               [(NSNumber*)[pos objectAtIndex:1] intValue])];
}

- (void) startSession {
    [self.sess startRunning];
}

- (void) stopSession {
    [self.sess stopRunning];
}

- (NSArray*) getBuildInCameraDevices {
    // AVCaptureDeviceTypeBuiltInWideAngleCamera to get Externel devices
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    NSArray *devs = [captureDeviceDiscoverySession devices];
    return devs;
}

- (NSArray*) getExternelCameraDevices {
    // AVCaptureDeviceTypeExternalUnknown to get Externel devices
    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeExternalUnknown] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    NSArray *devs = [captureDeviceDiscoverySession devices];
    return devs;
}

- (NSArray*) getAllCameraDevices {
    NSArray* buildInDevices = [self getBuildInCameraDevices];
    NSArray* externelDevices = [self getExternelCameraDevices];
    NSArray *allDevices=buildInDevices?[buildInDevices arrayByAddingObjectsFromArray:externelDevices]:[[NSArray alloc] initWithArray:externelDevices];
    return allDevices;
}

- (AVCaptureDeviceInput*) getDeviceInputByDevice:(AVCaptureDevice*)device {
    NSError* error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) Log(std::string([[error localizedDescription] UTF8String]).c_str());
    return deviceInput;
}

- (void) resetInputSignal {
    NSError* error;
    AVCaptureDeviceInput* input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if ( [self.sess canAddInput:input] ) {
        [self.sess addInput:input];
    }
}

- (void)exportLayer:(CALayer *)gl_layer {
    NSDictionary* dict = [[NSDictionary alloc] init];
    CGSConnectionID connection_id = CGSMainConnectionID();
    CAContext* remoteContext = [CAContext contextWithCGSConnection:connection_id options:dict];
    
    Log("Renderer: Setting the CAContext's layer to the CALayer to export");
    [remoteContext setLayer:gl_layer];
    
    Log("Renderer: Sending the ID of the context back to the server");
    
    self.contextId = [remoteContext contextId];
    
    NSLog(@"_contextId %u", self.contextId);
}

- (AVCaptureDevice*) getDeviceByUniID:(NSString*)uniId {

    std::string uniId_string = [uniId UTF8String];
    AVCaptureDevice* targetDevice = nil;

    for (AVCaptureDevice *device in self.deviceList)
    {
        if ([[device uniqueID] UTF8String] == uniId_string){
            targetDevice = device;
            break;
        }
    }

    if(targetDevice) {
        NSLog(@"Get the device with uniqueId: %@", uniId);
    } else {
        NSLog(@"Can not find any device by giving uniqueId.");
    }

    return targetDevice;
}

- (void) setSessionInput:(AVCaptureSession*)sess device:(AVCaptureDevice*)d {
    AVCaptureDeviceInput* input = [self getDeviceInputByDevice: d];
    NSAssert(input != nil, @"Can not get input of device.");
    if ([sess canAddInput:input]) {
        [sess addInput:input];
    }
}

@end

