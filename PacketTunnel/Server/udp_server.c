//
//  udp_server.c
//  vpn-client
//
//  Created by yuany on 2020/8/17.
//  Copyright © 2020 huan. All rights reserved.
//

#include "udp_server.h"
#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <netdb.h>
#include <errno.h>
#include <stdlib.h>
#include <time.h>
#include <arpa/inet.h>
#include <pthread/pthread.h>

#define BUFF_LEN 1024

void handle_udp_datagram(int fd) {
    char buf[BUFF_LEN];
    long count;
    struct sockaddr_in client;
    socklen_t len;
    while (1) {
        bzero(buf, sizeof(buf));
        len = sizeof(client);
        count = recvfrom(fd, buf, BUFF_LEN, 0, (struct sockaddr *)&client, &len);
        if (count == ANET_ERR) {
            printf("recieve data failed:[%s]", strerror(errno));
            return;
        }
        
        ///打印client发过来的信息
        printf("client:%s\n",buf);
        
        bzero(buf, sizeof(buf));
        ///回复client
        sprintf(buf, "I have recieved %ld bytes data!\n", count);
        printf("server:%s\n",buf);
        //发送信息给client，注意使用了clent_addr结构体指针
        sendto(fd, buf, BUFF_LEN, 0, (struct sockaddr*)&client, len);
    }
}

static int upd_server(int port) {
    ///AF_INET:IPV4;SOCK_DGRAM:UDP
    int fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (fd < 0) {
        printf("creating socket failed:[%s]", strerror(errno));
        return ANET_ERR;
    }
    
    struct sockaddr_in sa;
    bzero(&sa, sizeof(sa));
    sa.sin_family = AF_INET;
    ///IP地址，需要进行网络序转换，INADDR_ANY：本地地址
    sa.sin_addr.s_addr = htonl(INADDR_ANY);
    sa.sin_port = htons(port);
    
    int ret = bind(fd, (struct sockaddr *)&sa, sizeof(sa));
    if (ret < 0) {
        printf("bind failed:[%s]", strerror(errno));
        return ANET_ERR;
    }
    
    return fd;
}

void udp_server_start(int port) {
    int fd = upd_server(port);
    handle_udp_datagram(fd);
    close(fd);
}














