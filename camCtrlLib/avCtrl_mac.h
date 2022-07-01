#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureSession.h>
#import <CoreVideo/CoreVideo.h>
#import <AppKit/AppKit.h>
#include <iostream>

//std::string getmacCamList();
int getDeviceList(std::string* outresult);