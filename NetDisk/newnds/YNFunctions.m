//
//  YNFunctions.m
//  NetDisk
//
//  Created by fengyongning on 13-5-8.
//
//

#import "YNFunctions.h"

@implementation YNFunctions
+(double)getDirectorySizeForPath:(NSString*)path
{
    NSFileManager*  fileManager = [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator* e = [fileManager enumeratorAtPath:path];
    
    NSString *file;
    
    double totalSize = 0;
    while ((file = [e nextObject]))
    {
        
        NSDictionary *attributes = [e fileAttributes];
        
        NSNumber *fileSize = [attributes objectForKey:NSFileSize];
        
        totalSize += [fileSize longLongValue];
    }
    [fileManager release];
    return totalSize;
}
+(NSString *)covertNumberToString:(NSDecimalNumber *)sourceNumber{
    
    NSDecimalNumber *dd = sourceNumber;
    long long dl = [dd longLongValue];
    NSString *fid = [NSString stringWithFormat:@"%llu",dl];
    return fid;
}

+(long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+(NSString *)fileType:(NSString *)fileName
{
    NSRange rang = [fileName rangeOfString:@"." options:NSBackwardsSearch];
    if (rang.location!=NSNotFound) {
        rang = NSMakeRange(rang.location+1, [fileName length]-rang.location-1);
        return [fileName substringWithRange:rang];
    }
    return nil;
}
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

+(NSString *)getProviewCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/ProviewCache/"];
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
    NSString *usr_name=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:usr_name];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getDBCachePath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/DBCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return theFMCachePath;
}
+(NSString *)getUserFavoriteDataPath
{
    NSString *theFMCachePath=nil;
    NSArray *pathes= NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    theFMCachePath=[pathes objectAtIndex:0];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/FavoritesData/"];
    NSString *usr_name=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:usr_name];
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:theFMCachePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:theFMCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    theFMCachePath=[theFMCachePath stringByAppendingPathComponent:@"/favoritesData.plist"];
    return theFMCachePath;
}
+(NSString *)getFileNameWithFID:(NSString *)f_id
{
    return [NSString stringWithFormat:@"%@.data",f_id];
}
#pragma mark --------获取图片存档文件名
+(NSString*)picFileNameFromURL:(NSString*)URL{
    if (URL==nil) {
        return nil;
    }
	NSRange rang ;
	NSString *url = [NSString stringWithString:URL];
	while (url!=nil) {
		rang = [url rangeOfString:@"/"];
		if( rang.location != NSNotFound )
			url = [url substringFromIndex:rang.location+1];
		else
			break;
	}
	return url;
}
#pragma mark --------换算文件容量大小
+ (NSString *)convertSize:(NSString *)sourceSize
{
    NSString *sSize = nil;
    float nSize = 0.0f;
    if (sourceSize==nil) {
        return sSize;
    }
    nSize = [sourceSize floatValue]/1024.0;
    sSize = [NSString stringWithFormat:@"%.2f KB",nSize];
    if (nSize<1) {
        sSize = [NSString stringWithFormat:@"%d B",[sourceSize intValue]];
        return sSize;
    }
    if (nSize>=1024) {
        nSize = nSize/1024.0;
        sSize = [NSString stringWithFormat:@"%.2f MB",nSize];
        if (nSize>=1024) {
            nSize = nSize/1024.0;
            sSize = [NSString stringWithFormat:@"%.2f GB",nSize];
            if (nSize>=1024) {
                nSize = nSize/1024.0;
                sSize = [NSString stringWithFormat:@"%.2f TB",nSize];
            }
        }
    }
    return sSize;
}
#pragma mark --------屏蔽某些新功能
+(BOOL)isUnlockFeature
{
    NSString *userName=[[NSUserDefaults standardUserDefaults] objectForKey:@"usr_name"];
    if ([userName isEqualToString:@"fengyn@16feng.com"]) {
        return NO;
    }
    return NO;
}
#pragma mark --------获取网络状态
+(NetworkStatus)networkStatus
{
    Reachability *hostReach = [Reachability reachabilityWithHostName:@"www.7cbox.cn"];
    return [hostReach currentReachabilityStatus];
}
#pragma mark --------获取是否仅Wifi上传下载
+(BOOL)isOnlyWifi
{
    NSString *value=[[NSUserDefaults standardUserDefaults] objectForKey:@"switch_flag"];
    if (value==nil) {
        return YES;
    }
    return [value boolValue];
}
+(void)setIsOnlyWifi:(BOOL)value
{
    NSString *strValue = [NSString stringWithFormat:@"%d",value];
    [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:@"switch_flag"];
}
#pragma mark --------获取是否打开自动上传照片
+(BOOL)isAutoUpload
{
    NSString *value=[[NSUserDefaults standardUserDefaults] objectForKey:@"isAutoUpload"];
    if (value==nil) {
        return NO;
    }
    return [value boolValue];
}
+(void)setIsAutoUpload:(BOOL)value
{
    NSString *strValue = [NSString stringWithFormat:@"%d",value];
    [[NSUserDefaults standardUserDefaults] setObject:strValue forKey:@"isAutoUpload"];
}
@end
