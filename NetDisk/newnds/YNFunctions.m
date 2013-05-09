//
//  YNFunctions.m
//  NetDisk
//
//  Created by fengyongning on 13-5-8.
//
//

#import "YNFunctions.h"

@implementation YNFunctions
+(NSString *)getFMCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/FMCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getIconCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/IconCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getKeepCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/KeepCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getTempCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/TempCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getDataCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/DataCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getFileNameWithFID:(NSString *)f_id
{
    return [NSString stringWithFormat:@"%@.data",f_id];
}
@end
