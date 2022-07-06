//
//  ServerProtocol.h
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#ifndef ServerProtocol_h
#define ServerProtocol_h

// Definitions shared between Server and its clients.

#define SERVER_NAME @"net.kristopherjohnson.KJMachPortServer"

typedef NS_ENUM(uint32_t, ServerMsgId) {
    ServerMsgIdNotify = 1,
    ServerMsgIdExit = 2,
    ServerMsgIdEcho = 3,
    ServerGetVideoLayerSize = 4,
    ServerSetVideoLayerSize = 5,
    ServerGetVideoLayerPosition = 6,
    ServerSetVideoLayerPosition = 7,
    ServerOpenCamera = 8,
    ServerCloseCamera = 9,
    ServerDestroyVideoLayer = 10,
    ServerGetCameraIsOpen = 11,
    ServerGetCameraLocationId = 12,
    ServerSetCameraLocationId = 13,
    ServerGetCameraResolution = 14,
    ServerSetCameraResolution = 15,
};

#endif /* ServerProtocol_h */
