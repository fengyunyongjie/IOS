//
//  CheckConnectionKind.h
//  NewsRain
//
//  Created by  jiangwei on 12-7-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ifaddrs.h>
#include <arpa/inet.h>
#import "Reachability.h"

@interface CheckConnectionKind : NSObject

+(BOOL)IsWIFIConnection;
+(NSString*) GetCurrntNet;
+(BOOL) IsEnableWIFI;
+ (BOOL) IsEnable3G;
@end
