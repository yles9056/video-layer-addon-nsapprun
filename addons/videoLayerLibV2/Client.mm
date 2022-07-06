//
//  Client.m
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#import "Client.h"
#import "ServerProtocol.h"

@interface Client () <NSPortDelegate>
@end

@implementation Client

- (Client *)init {
  self = [super init];
  self.responseReceived = NO;
  self.uuidDict = [[NSMutableDictionary alloc] init];
  return self;
}

- (void)dealloc {
  [self.uuidDict release];
  [super dealloc];
}

- (NSPort *)serverPort {
  return [[NSMachBootstrapServer sharedInstance] portForName:SERVER_NAME];
}

- (void)sendNotifyMessage {
  NSPort *sendPort = [self serverPort];
  if (sendPort == nil) {
    NSLog(@"Unable to connect to server port");
    return;
  }

  NSPortMessage *message = [[NSPortMessage alloc] initWithSendPort:sendPort
                                                       receivePort:nil
                                                        components:nil];
  message.msgid = ServerMsgIdNotify;

  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
  if (![message sendBeforeDate:timeout]) {
    NSLog(@"Send failed");
  }
}

- (void)sendExitMessage {
  NSPort *sendPort = [self serverPort];
  if (sendPort == nil) {
    NSLog(@"Unable to connect to server port");
    return;
  }

  NSPortMessage *message = [[NSPortMessage alloc] initWithSendPort:sendPort
                                                       receivePort:nil
                                                        components:nil];
  message.msgid = ServerMsgIdExit;

  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
  if (![message sendBeforeDate:timeout]) {
    NSLog(@"Send failed");
  }
}

- (void)sendEchoMessage:(NSString *)string {
  NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];

  NSPort *sendPort = [self serverPort];
  if (sendPort == nil) {
    NSLog(@"Unable to connect to server port");
    return;
  }

  NSPort *receivePort = [NSMachPort port];
  receivePort.delegate = self;

  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [runLoop addPort:receivePort forMode:NSDefaultRunLoopMode];

  NSPortMessage *message = [[NSPortMessage alloc] initWithSendPort:sendPort
                                                       receivePort:receivePort
                                                        components:@[ data ]];
  message.msgid = ServerMsgIdEcho;

  self.responseReceived = NO;

  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
  if (![message sendBeforeDate:timeout]) {
    NSLog(@"Send failed");
  }

  while (!self.responseReceived) {
    [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }
}

- (NSData *_Nullable)sendVideoLayerMessage:(uint32_t)msgid {
  return [self sendVideoLayerMessage:msgid withPayload:nil];
}

- (NSData *_Nullable)sendVideoLayerMessage:(uint32_t)msgid
                               withPayload:(NSData *_Nullable)payload {
  NSPort *sendPort = [self serverPort];
  if (sendPort == nil) {
    NSLog(@"Unable to connect to server port");
    return nil;
  }

  NSPort *receivePort = [NSMachPort port];
  receivePort.delegate = self;
  NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
  [runLoop addPort:receivePort forMode:NSDefaultRunLoopMode];

  NSString *uuid = [[NSUUID UUID] UUIDString];
  NSData *uuidData = [uuid dataUsingEncoding:NSUTF8StringEncoding];

  NSPortMessage *message;
  if (payload) {
    message = [[NSPortMessage alloc] initWithSendPort:sendPort
                                          receivePort:receivePort
                                           components:@[ uuidData, payload ]];
  } else {
    message = [[NSPortMessage alloc] initWithSendPort:sendPort
                                          receivePort:receivePort
                                           components:@[ uuidData ]];
  }
  message.msgid = msgid;

  NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
  if (![message sendBeforeDate:timeout]) {
    NSLog(@"Send failed");
    return nil;
  }

  while ([self.uuidDict objectForKey:uuid] == nil) {
    [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
  }

  if ([self.uuidDict objectForKey:uuid] == [NSNull null]) {
    [self.uuidDict removeObjectForKey:uuid];
    return nil;
  } else if ([self.uuidDict objectForKey:uuid]) {
    // [NSDictionary removeObjectForKey] will remove the pointer. So you need to
    // copy the value.
    NSData *receivedData =
        [NSData dataWithData:[self.uuidDict objectForKey:uuid]];
    [self.uuidDict removeObjectForKey:uuid];
    return receivedData;
  }

  return nil;
}

- (void)handlePortMessage:(NSPortMessage *)message {
  NSLog(@"Received response with msgid %u", (unsigned)message.msgid);
  NSArray *components = message.components;
  NSLog(@"Response components.count %u", (unsigned)components.count);
  if (components.count > 0) {
    NSString *uuid = [[NSString alloc] initWithData:components[0]
                                           encoding:NSUTF8StringEncoding];
    if (components.count > 1) {
      [self.uuidDict setValue:components[1] forKey:uuid];
    } else {
      [self.uuidDict setValue:[NSNull null] forKey:uuid];
    }
  }

  self.responseReceived = YES;
}

@end
