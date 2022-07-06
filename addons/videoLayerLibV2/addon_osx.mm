#include "addon_osx.h"

CALayerHost* videoLayer;

void initVideoLayer(unsigned contextId, void **handle) {
  printf("initVideoLayer\n");

  NSView *viewParent =
      static_cast<NSView *>(*reinterpret_cast<void **>(handle));
  NSWindow *winParent = [viewParent window];

  [viewParent setWantsLayer:YES];

  videoLayer = getLayerHost(contextId);

  [[[winParent contentView] layer] addSublayer:videoLayer];
  [videoLayer setPosition:CGPointMake(0, 0)];
}

CALayerHost *getLayerHost(unsigned contextId) {
  //CAContextID context_id_ = 1591718317;
  //CAContextID context_id_ = (CAContextID)std::stol(name);
  printf("contextId: %u\n", contextId);
  CALayerHost *layer_host = [[CALayerHost alloc] init];
  [layer_host setContextId:contextId];
  return layer_host;
}

void destroyVideoLayer()
{
    [videoLayer removeFromSuperlayer];
}