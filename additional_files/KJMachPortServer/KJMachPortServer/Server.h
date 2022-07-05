//
//  Server.h
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoLayerHandler.h"

@interface Server : NSObject

@property (atomic, strong) NSPort* _Nullable port;

@property (atomic, strong) VideoLayerHandler* _Nullable videoLayerHandler;

- (void)run;

- (void)replyMsg:(NSPortMessage *_Nullable)message
        withComponents: (nullable NSArray*)components
        log:(NSString* _Nullable)log;
@end
