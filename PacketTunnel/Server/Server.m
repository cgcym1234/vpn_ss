//
//  Server.m
//  vpn-client
//
//  Created by yuany on 2020/8/17.
//  Copyright © 2020 huan. All rights reserved.
//

#import "Server.h"
#include "udp_server.h"
#include "udp_client.h"

int port = 8899;

@implementation Server


+ (void)startUDPServer {
    udp_server_start(port);
}

+ (void)startUDPClient {
    udp_client_start("127.0.0.1", port);
}

@end
