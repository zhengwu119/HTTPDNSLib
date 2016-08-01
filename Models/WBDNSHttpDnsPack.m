//
//  HttpDnsPack.m
//  DNSCache
//
//  Created by Robert Yang on 15/7/28.
//  Copyright (c) 2015年 Weibo. All rights reserved.
//

#import "WBDNSHttpDnsPack.h"
#import "WBDNSModel.h"
#import "WBDNSCache.h"
#import "WBDNSNetworkManager.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
@implementation WBDNSHttpDnsPack

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

+ (WBDNSHttpDnsPack *)generateInstanceFromresponseString:(NSString *)responseString andDomain:(NSString *)domain is114:(BOOL)is114 {
    if (responseString == nil) {
        return nil;
    }
    WBDNSHttpDnsPack* dnsPack = [[WBDNSHttpDnsPack alloc]init];
    dnsPack.domain = domain;
    dnsPack.device_ip = [dnsPack getIPAddress];
    dnsPack.device_sp = [WBDNSNetworkManager sharedInstance].currentSpTypeString;
    
    NSArray *array = [responseString componentsSeparatedByString:@","];
    if (array.count == 2 && !is114) {
        NSString *ipStrings = [array firstObject];
        NSString *ttl = [array lastObject];
        NSArray* dns = [ipStrings componentsSeparatedByString:@";"];
        if (dns && [dns isKindOfClass:[NSArray class]]) {
            dnsPack.dns = [NSMutableArray array];
        }
        for (NSString * tempIP in dns) {
            WBDNSIP* ip = [[WBDNSIP alloc]init];
            ip.ip = tempIP;
            ip.ttl = ttl;
            ip.priority = @"";
            [dnsPack.dns addObject:ip];
        }
        return dnsPack;
    }
    
    //For 114 DNS
    NSArray *arr2 = [responseString componentsSeparatedByString:@";"];
    if  (arr2.count > 0 && is114){
        dnsPack.dns = [NSMutableArray array];
        for (NSString *tp in arr2) {
            NSArray *_dns = [tp componentsSeparatedByString:@","];
            if (_dns.count == 2) {
                WBDNSIP* ip = [[WBDNSIP alloc] init];
                ip.ip = [_dns firstObject];
                ip.ttl = [_dns lastObject];
                ip.priority = @"";
                [dnsPack.dns addObject:ip];
            }
        }
        return dnsPack;
    }

    return dnsPack;
}

- (NSString *)description {
    NSMutableString* string = [NSMutableString stringWithFormat:@"域名 ＝ %@, 最终请求IP ＝ %@, 服务器识别运营商 ＝ %@, 本地识别运营商或SSID ＝ %@", _domain, _device_ip, _device_sp, _localhostSp];
    return string;
}

- (NSDictionary *)toDictionary {
    NSMutableArray* dnsIpJasonArray = [NSMutableArray array];
    for(int i = 0; i< self.dns.count; i++)
    {
        [dnsIpJasonArray addObject:[self.dns[i] toDictionary]];
    }
    
    NSDictionary* dic = @{@"domain":_domain,
                          @"device_ip":_device_ip,
                          @"device_sp":_device_sp,
                          @"dns":dnsIpJasonArray,
                          };
    return dic;
}
- (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}
@end
