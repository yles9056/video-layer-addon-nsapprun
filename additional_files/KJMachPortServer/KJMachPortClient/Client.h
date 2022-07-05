//
//  Client.h
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Client : NSObject

@property (atomic, assign) BOOL responseReceived;

- (Client *)init;

- (void)sendNotifyMessage;

- (void)sendExitMessage;

- (void)sendEchoMessage:(NSString *)string;

@end
