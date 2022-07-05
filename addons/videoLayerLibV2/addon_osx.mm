#include "addon_osx.h"

void initVideoLayer(void **windowHandle, unsigned contextId) {
  NSView *viewParent =
      static_cast<NSView *>(*reinterpret_cast<void **>(windowHandle));
  NSWindow *winParent = [viewParent window];

  [viewParent setWantsLayer:YES];

  CALayerHost *layer_host = getLayerHost(contextId);

  [[[winParent contentView] layer] addSublayer:layer_host];
  [layer_host setPosition:CGPointMake(0, 0)];
}

CALayerHost *getLayerHost(unsigned contextId) {
  NSLog(@"contextId: %u\n", contextId);
  CALayerHost *layer_host = [[CALayerHost alloc] init];
  [layer_host setContextId:contextId];
  return layer_host;
}