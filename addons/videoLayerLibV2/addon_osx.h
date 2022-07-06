#ifndef ADDON_OSX_H
#define ADDON_OSX_H
#import <Cocoa/Cocoa.h>
#include <stdio.h>

#include <iostream>
#include <string>
#include <AVFoundation/AVFoundation.h>
#include <AVFoundation/AVCaptureSession.h>

#include "remote_layer_api.h"

void initVideoLayer(unsigned contextId, void **handle);
void destroyVideoLayer();
CALayerHost* getLayerHost(unsigned contextId);

#endif