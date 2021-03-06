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

@implementation Client /*{
                        BOOL _responseReceived;
                        }*/

- (Client *)init {
    self = [super init];
    self.responseReceived = NO;
    return self;
}

- (NSPort *)serverPort {
    return [[NSMachBootstrapServer sharedInstance]
            portForName:SERVER_NAME];
}

- (void)sendNotifyMessage {
    NSPort *sendPort = [self serverPort];
    if (sendPort == nil) {
        NSLog(@"Unable to connect to server port");
        return;
    }
    
    NSPortMessage *message = [[NSPortMessage alloc]
                              initWithSendPort:sendPort
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
    
    NSPortMessage *message = [[NSPortMessage alloc]
                              initWithSendPort:sendPort
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
    
    NSPortMessage *message = [[NSPortMessage alloc]
                              initWithSendPort:sendPort
                              receivePort:receivePort
                              components:@[data]];
    message.msgid = ServerMsgIdEcho;
    
    //_responseReceived = NO;
    self.responseReceived = NO;
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
    if (![message sendBeforeDate:timeout]) {
        NSLog(@"Send failed");
    }
    
    //while (!_responseReceived) {
    while (!self.responseReceived) {
        [runLoop runUntilDate:
         [NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (NSMutableData*) convertFloatToNSData:(float)floatdata {
    NSMutableData* nsdata = [NSMutableData dataWithCapacity:0];
    [nsdata appendBytes:&floatdata length:sizeof(float)];
    return nsdata;
}

- (float) convertNSDataToFloat:(NSData*)nsdata {
    float floatdata;
    [nsdata getBytes:&floatdata length:sizeof(float)];
    return floatdata;
}

- (NSString*) convertNSDataToNSString:(NSData*)nsdata {
    NSString* nsstring = [[NSString alloc]
                            initWithData:nsdata
                            encoding:NSUTF8StringEncoding];
    return nsstring;
}

- (NSData*) convertNSStringToNSData:(NSString*)nsstring {
    NSData* nsdata = [nsstring dataUsingEncoding:NSUTF8StringEncoding];
    return nsdata;
}

- (NSData*) convertNSArrayToNSData:(NSArray*)nsarray {
    NSData *nsdata = [NSKeyedArchiver archivedDataWithRootObject:nsarray];
    return nsdata;
}

- (NSArray*) convertNSDataToNSArray:(NSData*)nsdata {
    NSArray *nsarray = [NSKeyedUnarchiver unarchiveObjectWithData:nsdata];
    return nsarray;
}

- (NSData*) convertBoolToNSData:(bool)boolean {
    NSMutableData* nsdata = [NSMutableData dataWithCapacity:0];
    [nsdata appendBytes:&boolean length:sizeof(bool)];
    return nsdata;
}

- (void)sendTestMessage {
    NSPort *sendPort = [self serverPort];
    if (sendPort == nil) {
        NSLog(@"Unable to connect to server port");
        return;
    }
    
    NSPort *receivePort = [NSMachPort port];
    receivePort.delegate = self;
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:receivePort forMode:NSDefaultRunLoopMode];
    
    float posX = 10.0;
    float posY = 10.0;
    NSMutableData* x_data = [self convertFloatToNSData:posX];
    NSMutableData* y_data = [self convertFloatToNSData:posY];
    NSData* pos_data = [self convertNSArrayToNSData:@[x_data, y_data]];
    
    NSData* data = [self convertNSStringToNSData:@"0x14100000047d80c5"];
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    NSData *uuidData = [uuid dataUsingEncoding:NSUTF8StringEncoding];
    
    NSPortMessage *message = [[NSPortMessage alloc]
                              initWithSendPort:sendPort
                              receivePort:receivePort
                              components:@[uuidData, pos_data]];
    message.msgid = ServerSetVideoLayerSize;
    
    self.responseReceived = NO;
    NSDate *timeout = [NSDate dateWithTimeIntervalSinceNow:5.0];
    if (![message sendBeforeDate:timeout]) {
        NSLog(@"Send failed");
    }
    
    while (!self.responseReceived) {
        [runLoop runUntilDate:
         [NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
}

- (void)handlePortMessage:(NSPortMessage *)message {
    switch (message.msgid) {
        case ServerMsgIdEcho: {
            NSArray *components = message.components;
            if (components.count > 0) {
                NSString *dataString = [[NSString alloc]
                                        initWithData:components[0]
                                        encoding:NSUTF8StringEncoding];
                NSLog(@"Received Echo response: \"%@\"", dataString);
            }
        } break;
            
        default:
            NSLog(@"Unexpected response msgid %u",
                  (unsigned)message.msgid);
            break;
    }
    
    //_responseReceived = YES;
    self.responseReceived = YES;
}

@end
