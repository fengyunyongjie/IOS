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
    sSize = [NSString stringWithFormat:@"%.2f K",nSize];
    if (nSize<1) {
        sSize = @"0 K";
        return sSize;
    }
    if (nSize>=1024) {
        nSize = nSize/1024.0;
        sSize = [NSString stringWithFormat:@"%.2f M",nSize];
        if (nSize>=1024) {
            nSize = nSize/1024.0;
            sSize = [NSString stringWithFormat:@"%.2f G",nSize];
            if (nSize>=1024) {
                nSize = nSize/1024.0;
                sSize = [NSString stringWithFormat:@"%.2f T",nSize];
            }
        }
    }
    return sSize;
}
@end
