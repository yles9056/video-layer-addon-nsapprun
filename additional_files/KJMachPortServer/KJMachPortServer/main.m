//
//  main.m
//  KJMachPortServer
//
//  Created by Kristopher Johnson on 6/29/17.
//  Copyright © 2017 Kristopher Johnson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        Server *server = [[Server alloc] init];
        [server run];
    }
    return 0;
}
