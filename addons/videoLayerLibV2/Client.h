//
//  Client.h
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Client : NSObject

@property(atomic, assign) BOOL responseReceived;
@property(atomic, retain) NSMutableDictionary* uuidDict;

- (Client*)init;

- (void)dealloc;

- (void)sendNotifyMessage;

- (void)sendExitMessage;

- (void)sendEchoMessage:(NSString*)string;

- (NSData* _Nullable)sendVideoLayerMessage:(uint32_t)msgid;

- (NSData* _Nullable)sendVideoLayerMessage:(uint32_t)msgid withPayload:(NSData* _Nullable)payload;

@end
