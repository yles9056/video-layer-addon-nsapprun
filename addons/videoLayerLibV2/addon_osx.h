#ifndef ADDON_OSX_H
#define ADDON_OSX_H

#include "remote_layer_api.h"

void initVideoLayer(void **handle, unsigned contextId);
CALayerHost* getLayerHost(unsigned contextId);

#endif