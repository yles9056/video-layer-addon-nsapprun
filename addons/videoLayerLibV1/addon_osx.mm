#include "addon_osx.h"

CALayerHost *layer_host;
NSWindow *winParent;

void createWindow(void **handle, CAContextID context_id_) {

  printf("[Info] Create window in addon_osx.\n");

  NSView *viewParent = static_cast<NSView *>(*reinterpret_cast<void **>(handle));
  winParent = [viewParent window];

  [viewParent setWantsLayer:YES];

  layer_host = getLayerHost(context_id_);

  [[[winParent contentView] layer] addSublayer:layer_host];
  //[layer_host setPosition:CGPointMake(0, 0)];
}

void removeWindow()
{
  [[[winParent contentView] layer] removefromsuperlayer];
}

CALayerHost *getLayerHost(CAContextID context_id_) {
  //CAContextID context_id_ = context_id;
  //CAContextID context_id_ = 0;
  //ipc::Ipc::instance().read_data(&context_id_);
  printf("[Info] Context_id_: %d in addon_osx.mm.\n", context_id_);
  layer_host = [[CALayerHost alloc] init];
  [layer_host setContextId:context_id_];
  return layer_host;
}