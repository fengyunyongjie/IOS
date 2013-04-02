//
//  CheckConnectionKind.m
//  NewsRain
//
//  Created by  jiangwei on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CheckConnectionKind.h"

@implementation CheckConnectionKind

+(BOOL)IsWIFIConnection
{
    BOOL ret = YES;
    struct ifaddrs * first_ifaddr, * current_ifaddr;
    NSMutableArray* activeInterfaceNames = [[NSMutableArray alloc] init];
    getifaddrs( &first_ifaddr );
    current_ifaddr = first_ifaddr;
    while( current_ifaddr!=NULL )
    {
        if( current_ifaddr->ifa_addr->sa_family==0x02 )
        {
            [activeInterfaceNames addObject:[NSString stringWithFormat:@"%s", current_ifaddr->ifa_name]];
        }
        current_ifaddr = current_ifaddr->ifa_next;
    }
    ret = [activeInterfaceNames containsObject:@"en0"] || [activeInterfaceNames containsObject:@"en1"];
    [activeInterfaceNames release];
    return ret;
}

+(NSString*) GetCurrntNet
{
    return @"wifi";
    NSString* result=nil;
    Reachability *r = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([r currentReachabilityStatus]) {
        caseNotReachable:     // 没有网络连接
            result=nil;
            break;
        caseReachableViaWWAN: // 使用3G网络
            result=@"3g";
            break;
        caseReachableViaWiFi: // 使用WiFi网络
            result=@"wifi";
            break;
    }
    return result;
}
//以上代码在虚拟机中的模拟器上测试，有异常，难道测试网络联通不能使用模拟器？

//另外，不管是不是插着网线，模拟器的WIFI始终是连着的，不管电脑本身的网络是否断开（同样是在虚拟机中）
+(BOOL) IsEnableWIFI { //始终返回YES
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}
//而3G/GPRS始终是断开的
+ (BOOL) IsEnable3G {  //一直返回NO
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}
@end
