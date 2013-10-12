//
//  NSString+Format.m
//  NetDisk
//
//  Created by Yangsl on 13-9-22.
//
//

#import "NSString+Format.h"

@implementation NSString (Format)

+(NSString *)formatNSStringForChar:(const char *)temp
{
    NSString *string;
    if(temp!=NULL)
    {
        string = [NSString stringWithUTF8String:temp];
    }
    else
    {
        string = @"";
    }
    return string;
}

+(NSString *)formatNSStringForOjbect:(NSObject *)object
{
    NSString *string = [NSString stringWithFormat:@"%@",object];
    return string;
}

@end
