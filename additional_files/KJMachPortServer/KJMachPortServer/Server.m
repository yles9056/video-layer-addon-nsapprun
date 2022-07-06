//
//  Server.m
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "Server.h"
#import "ServerProtocol.h"

@interface Server () <NSPortDelegate>
@end

@implementation Server

- (void)run {
    // Initialize the server and run
    NSLog(@"Server starting");
    
    // Initialize server and port
    self.port = [[NSMachBootstrapServer sharedInstance]
                 servicePortWithName:SERVER_NAME];
    if (self.port == nil) {
        // This probably means another instance is running.
        NSLog(@"Unable to open server port.");
        return;
    }
    
    self.port.delegate = self;
    
    // Configure runloop
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    
    [runLoop addPort:self.port forMode:NSDefaultRunLoopMode];
    
    
    // Initialize CALayer
    self.videoLayerHandler = [[VideoLayerHandler alloc] init];
    [self.videoLayerHandler initSessionLayer];
    [self.videoLayerHandler configLayer];
    [self.videoLayerHandler exportLayer:self.videoLayerHandler.previewLayer];
    [self.videoLayerHandler resetInputSignal];
    /* open camera at the beginning */
    [self.videoLayerHandler startSession];
    
    // Start run loop
    NSLog(@"Server running");
    [runLoop run];
    NSLog(@"Server exiting");
}


- (void)replyMsg:(NSPortMessage *)message
        withComponents:(nullable NSArray*)components
        log:(NSString*)log {

    NSPort *responsePort = message.sendPort;
    if (responsePort != nil) {
        NSPortMessage *response = [[NSPortMessage alloc]
                                   initWithSendPort:responsePort
                                   receivePort:nil
                                   components:components];
        response.msgid = message.msgid;
        NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
        [response sendBeforeDate:timeout];
        NSLog(@"%@", log);
    }
}

- (NSMutableData*) convertFloatToNSData:(float)floatdata {
    NSMutableData* nsdata = [NSMutableData dataWithCapacity:0];
    [nsdata appendBytes:&floatdata length:sizeof(float)];
    return nsdata;
}

- (float) convertNSDataToFloat:(NSData*)nsdata {
    float floatdata;
    [nsdata getBytes:&floatdata length:sizeof(float)];
    return floatdata;
}

- (NSString*) convertNSDataToNSString:(NSData*)nsdata {
    NSString* nsstring = [[NSString alloc]
                            initWithData:nsdata
                            encoding:NSUTF8StringEncoding];
    return nsstring;
}

- (NSData*) convertNSStringToNSData:(NSString*)nsstring {
    NSData* nsdata = [nsstring dataUsingEncoding:NSUTF8StringEncoding];
    return nsdata;
}

- (NSData*) convertNSArrayToNSData:(NSArray*)nsarray {
    NSData *nsdata = [NSKeyedArchiver archivedDataWithRootObject:nsarray];
    return nsdata;
}

- (NSArray*) convertNSDataToNSArray:(NSData*)nsdata {
    NSArray *nsarray = [NSKeyedUnarchiver unarchiveObjectWithData:nsdata];
    return nsarray;
}

- (NSData*) convertBoolToNSData:(bool)boolean {
    NSMutableData* nsdata = [NSMutableData dataWithCapacity:0];
    [nsdata appendBytes:&boolean length:sizeof(bool)];
    return nsdata;
}

- (bool) convertNSDataToBool:(NSData*)nsdata {
    bool boolean;
    [nsdata getBytes:&boolean length:sizeof(bool)];
    return boolean;
}

- (CAShapeLayer*) createMaskLayer:(CGFloat)_x y:(CGFloat)_y w:(CGFloat)_w h:(CGFloat)_h {
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGMutablePathRef maskPath = CGPathCreateMutable();
    
    CGFloat videoLayer_x = self.videoLayerHandler.previewLayer.position.x;
    CGFloat videoLayer_y = self.videoLayerHandler.previewLayer.position.y;
    CGFloat videoLayer_w = self.videoLayerHandler.previewLayer.frame.size.width;
    CGFloat videoLayer_h = self.videoLayerHandler.previewLayer.frame.size.height;
    
    CGPathAddRect(maskPath, NULL, CGRectMake(videoLayer_x, videoLayer_y, videoLayer_w, videoLayer_h));
    CGPathAddRect(maskPath, nil, CGRectMake(_x, _y, _w, _h));
    
    [maskLayer setPath:maskPath];
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    CGPathRelease(maskPath);
    return maskLayer;
}

- (void)handlePortMessage:(NSPortMessage *)message {
    switch (message.msgid) {
        case ServerMsgIdNotify:
            NSLog(@"Received Notify message");
            break;
            
        case ServerMsgIdExit:
            NSLog(@"Received Exit message");
            exit(0);
            break;

        case ServerMsgIdEcho:
            [self replyMsg:message
                withComponents:message.components
                       log:@"Echo"];
            break;
            
        case ServerGetVideoLayerSize: {
            
            CGFloat w_cg = self.videoLayerHandler.previewLayer.frame.size.width;
            CGFloat h_cg = self.videoLayerHandler.previewLayer.frame.size.height;
            
            float w_c = (float)w_cg;
            float h_c = (float)h_cg;

            NSMutableData* w = [self convertFloatToNSData:w_c];
            NSMutableData* h = [self convertFloatToNSData:h_c];

            NSData* uId = message.components[0];
            NSData* sz_data = [self convertNSArrayToNSData:@[w, h]];
            
            [self replyMsg:message withComponents:@[uId, sz_data] log:@"Sent GetVideoLayerSize response"];

        } break;

        case ServerSetVideoLayerSize: {
            /* message.components type:NSArray meaning:sz(w,h) - (CGFloat,CGFloat) */
            if (message.components.count > 1) {

                NSData* sz_data_input = message.components[1];
                NSArray* sz = [self convertNSDataToNSArray:sz_data_input];
                CGFloat w = (CGFloat)[self convertNSDataToFloat:sz[0]];
                CGFloat h = (CGFloat)[self convertNSDataToFloat:sz[1]];

                [self.videoLayerHandler setLayerSize:@[@(w), @(h)]];

                /* Get the Size for response */
                float w_c = (float)(self.videoLayerHandler.previewLayer.frame.size.width);
                float h_c = (float)(self.videoLayerHandler.previewLayer.frame.size.height);

                NSMutableData* w_data = [self convertFloatToNSData:w_c];
                NSMutableData* h_data = [self convertFloatToNSData:h_c];

                NSData* uId = message.components[0];
                NSData* sz_data = [self convertNSArrayToNSData:@[w_data, h_data]];
                
                [self replyMsg:message withComponents:@[uId, sz_data] log:@"Sent SetVideoLayerSize response"];
            }
            
        } break;

        case ServerGetVideoLayerPosition: {
           
            CGFloat x_cg = self.videoLayerHandler.previewLayer.position.x;
            CGFloat y_cg = self.videoLayerHandler.previewLayer.position.y;

            float x_c = (float)x_cg;
            float y_c = (float)y_cg;

            NSMutableData* x = [self convertFloatToNSData:x_c];
            NSMutableData* y = [self convertFloatToNSData:y_c];

            NSData* uId = message.components[0];
            NSData* pos_data = [self convertNSArrayToNSData:@[x, y]];
            [self replyMsg:message withComponents:@[uId, pos_data] log:@"Sent GetVideoLayerPosition response"];

        } break;

        case ServerSetVideoLayerPosition: {
            /* message.components type:NSArray meaning:pos(x,y) - (CGFloat,CGFloat) */
            if (message.components.count > 1) {

                NSData* pos_data_input = message.components[1];
                NSArray* pos = [self convertNSDataToNSArray:pos_data_input];
                CGFloat x = (CGFloat)[self convertNSDataToFloat:pos[0]];
                CGFloat y = (CGFloat)[self convertNSDataToFloat:pos[1]];

                [self.videoLayerHandler setLayerPosition:@[@(x), @(y)]];

                /* Get the Position for response */
                float x_c = (float)(self.videoLayerHandler.previewLayer.position.x);
                float y_c = (float)(self.videoLayerHandler.previewLayer.position.y);

                NSMutableData* x_data = [self convertFloatToNSData:x_c];
                NSMutableData* y_data = [self convertFloatToNSData:y_c];

                NSData* uId = message.components[0];
                NSData* pos_data = [self convertNSArrayToNSData:@[x_data, y_data]];
                [self replyMsg:message withComponents:@[uId, pos_data] log:@"Sent SetVideoLayerPosition response"];
            }
        } break;

        case ServerOpenCamera: {

            [self.videoLayerHandler startSession];

            NSData* uId = message.components[0];
            NSData* boolean = [self convertBoolToNSData:true];
            
            [self replyMsg:message withComponents:@[uId, boolean] log:@"Sent OpenCamera response"];

        } break;

        case ServerCloseCamera: {

            [self.videoLayerHandler stopSession];

            NSData* uId = message.components[0];
            NSData* boolean = [self convertBoolToNSData:true];
            
            [self replyMsg:message withComponents:@[uId, boolean] log:@"Sent CloseCamera response"];

        } break;
        
        case ServerDestroyVideoLayer: {
        
            /* CAN NOT CONVERT CALAYERHOST <-> NSDATA */
            
            // CALayerHost* videoLayer = message.components[1];
            // [videoLayer removeFromSuperlayer];

            NSData* uId = message.components[0];
            NSData* boolean = [self convertBoolToNSData:false];
            
            [self replyMsg:message withComponents:@[uId, boolean] log:@"Sent DestroyVideoLayer response"];

        }  break;

        case ServerGetCameraIsOpen: {

            bool isCamOpen = [self.videoLayerHandler.sess isRunning];
            
            NSData* uId = message.components[0];
            NSData* boolean = [self convertBoolToNSData:isCamOpen];
            
            [self replyMsg:message withComponents:@[uId, boolean] log:@"Sent GetCameraIsOpen response"];

        } break;
        
        case ServerGetCameraLocationId: {

            NSString* deviceLocationId = self.videoLayerHandler.uniqueId;
            NSData* locationId = [deviceLocationId dataUsingEncoding:NSUTF8StringEncoding];

            NSData* uId = message.components[0];
            [self replyMsg:message withComponents:@[uId, locationId] log:@"Sent GetCameraLocationId response"];

        } break;

        case ServerSetCameraLocationId: {

            if (message.components.count > 1) {

                /* Get the uniqueId from request */
                NSString* uniId_ns = [[NSString alloc]
                                        initWithData:message.components[1]
                                        encoding:NSUTF8StringEncoding];

                AVCaptureDevice* device = [self.videoLayerHandler getDeviceByUniID:uniId_ns];
                if(!device) break;

                bool isRunning = [self.videoLayerHandler.sess isRunning];
                if (isRunning) { [self.videoLayerHandler stopSession];}

                /* Remove the old input of session */
                for (AVCaptureInput* input in self.videoLayerHandler.sess.inputs){
                        [self.videoLayerHandler.sess removeInput:input];
                }

                [self.videoLayerHandler setSessionInput:self.videoLayerHandler.sess device:device];
                self.videoLayerHandler.device = device;
                self.videoLayerHandler.uniqueId = [device uniqueID];

                if (isRunning) [self.videoLayerHandler startSession];

                NSData* uId = message.components[0];
                NSString* deviceLocationId = self.videoLayerHandler.uniqueId;
                NSData *locationId = [deviceLocationId dataUsingEncoding:NSUTF8StringEncoding];
                [self replyMsg:message withComponents:@[uId, locationId] log:@"Sent SetCameraLocationId response"];
            }

        } break;

        case ServerGetCameraResolution: {

            
            NSString* resolutionNsstr = self.videoLayerHandler.resolution;
            NSData* resolution = [resolutionNsstr dataUsingEncoding:NSUTF8StringEncoding];

            NSData* uId = message.components[0];
            [self replyMsg:message withComponents:@[uId, resolution] log:@"Sent GetCameraResolution response"];

        } break;
        
        case ServerSetCameraResolution: {

            if (message.components.count > 1) {
                /* Get the resolution from request */
                NSString* preset = [[NSString alloc]
                                        initWithData:message.components[1]
                                        encoding:NSUTF8StringEncoding];

                if ([self.videoLayerHandler.device supportsAVCaptureSessionPreset:preset] && [self.videoLayerHandler.sess canSetSessionPreset:preset]) {
                    [self.videoLayerHandler.sess beginConfiguration];
                    [self.videoLayerHandler.sess setSessionPreset:preset];
                    [self.videoLayerHandler.sess commitConfiguration];
                    NSLog(@"Set resolution to the new one");
                } else {
                    NSLog(@"Can not support this resolution, set to dault 1280x720 one.");
                    [self.videoLayerHandler.sess setSessionPreset:AVCaptureSessionPreset1280x720];
                }

                NSData* uId = message.components[0];
                NSString* resolutionNsstr = self.videoLayerHandler.resolution;
                NSData* resolution = [resolutionNsstr dataUsingEncoding:NSUTF8StringEncoding];
                [self replyMsg:message withComponents:@[uId, resolution] log:@"Sent SetCameraLocationId response"];
            }

        } break;
            
        case ServerCreateMaskForCombobox: {
            /* message.components type:NSArray meaning:info(x,y,w,h) - (CGFloat,CGFloat,CGFloat,CGFloat) */
            NSData* maskInfo = message.components[1];
            NSArray* maskArray = [self convertNSDataToNSArray:maskInfo];
            
            CGFloat _x = (CGFloat)[self convertNSDataToFloat:maskArray[0]];
            CGFloat _y = (CGFloat)[self convertNSDataToFloat:maskArray[1]];
            CGFloat _w = (CGFloat)[self convertNSDataToFloat:maskArray[2]];
            CGFloat _h = (CGFloat)[self convertNSDataToFloat:maskArray[3]];
            
            CAShapeLayer* maskLayer = [self createMaskLayer:_x y:_y w:_w h:_h];
            self.videoLayerHandler.previewLayer.mask = maskLayer;
            
            NSData* uId = message.components[0];
            
            [self replyMsg:message withComponents:@[uId, maskInfo] log:@"Sent CreateMaskForCombobox response"];
            
        } break;

        case ServerDestroyMaskForCombobox: {
            
            self.videoLayerHandler.previewLayer.mask = nil;
            
            NSData* uId = message.components[0];
            NSData* boolean = [self convertBoolToNSData:true];
            [self replyMsg:message withComponents:@[uId, boolean] log:@"Sent DestoryMaskForCombobox response"];
            
        } break;
            
        default:
            NSLog(@"Unexpected message ID %u", (unsigned)message.msgid);
            break;
    }
}

@end
