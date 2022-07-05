#ifndef ADDON_OSX_H
#define ADDON_OSX_H
#import <Cocoa/Cocoa.h>
#include <stdio.h>

#include <iostream>
#include <string>
#include <memory>
#include "remote_layer_api.h"
#include "renderer_app.h"

void createWindow(void **handle, CAContextID context_id_);
void removeWindow();
CALayerHost* getLayerHost(CAContextID context_id_);

#endif