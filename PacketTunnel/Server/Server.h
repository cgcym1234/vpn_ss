//
//  Server.h
//  vpn-client
//
//  Created by yuany on 2020/8/17.
//  Copyright © 2020 huan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Server : NSObject

+ (void)startUDPServer;

+ (void)startUDPClient;

@end

