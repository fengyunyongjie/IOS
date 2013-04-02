//
//  Function.m
//  NetDisk
//
//  Created by jiangwei on 12-12-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Function.h"

@implementation Function
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

+ (NSString *)getImgCachePath
{
    NSString *theCachesPath = nil;
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theCachesPath = [cachesPaths objectAtIndex:0]; 
    return [theCachesPath stringByAppendingPathComponent:@"/ImageCache/"];
}

+ (NSString *)getTempCachePath
{
    NSString *theCachesPath = nil;
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theCachesPath = [cachesPaths objectAtIndex:0]; 
    return [theCachesPath stringByAppendingPathComponent:@"/TempCache/"];
}
+ (NSString *)getUploadTempPath
{
    NSString *theCachesPath = nil;
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theCachesPath = [cachesPaths objectAtIndex:0]; 
    return [theCachesPath stringByAppendingPathComponent:@"/UploadTemp/"];
}
+ (NSString *)getKeepCachePath
{
    NSString *theCachesPath = nil;
    NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theCachesPath = [cachesPaths objectAtIndex:0]; 
    return [theCachesPath stringByAppendingPathComponent:@"/KeepCache/"];
}
+(NSString *)getThumbCachePath
{
    NSString *theCachesPath=nil;
    NSArray *cachesPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    theCachesPath=[cachesPaths objectAtIndex:0];
    return [theCachesPath stringByAppendingPathComponent:@"/ThumbCache/"];
}
- (NSMutableArray *)parseTimeLine:(NSString *)timeStr
{
    //NSLog(@"fasfasdfasf");
    NSString *perfix= [NSString stringWithString:@"[20"];
    NSString *suffix= [NSString stringWithString:@"]]"];
    
    NSMutableArray *timeList = [NSMutableArray arrayWithCapacity:0];
    NSMutableString *sourceStr = [NSMutableString stringWithString:timeStr];
    
    while (1) {
        NSRange perRang = [sourceStr rangeOfString:perfix];
        if (perRang.location==NSNotFound) {
            break;
        }
        NSRange sufRang = [sourceStr rangeOfString:suffix];
        NSString *temp = [sourceStr substringWithRange:NSMakeRange(perRang.location, sufRang.location+sufRang.length)];
        NSMutableString *subSourceStr = [NSMutableString stringWithString:temp];
        NSString *year = [subSourceStr substringWithRange:NSMakeRange(perRang.location+1, 4)];
        subSourceStr = [NSMutableString stringWithString:[subSourceStr substringFromIndex:6]];
        while (1) {
            NSString *subPerfix = @"[";
            NSRange subPerRang = [subSourceStr rangeOfString:subPerfix];
            if (subPerRang.location==NSNotFound) {
                break;
            }
            NSString *month = [subSourceStr substringWithRange:NSMakeRange(subPerRang.location+1, 2)];
            [timeList addObject:[NSString stringWithFormat:@"%@-%@",year,month]];
            subSourceStr = [NSMutableString stringWithString:[subSourceStr substringFromIndex:3]];
        }
        if ([sourceStr length]>11) {
            sourceStr = [NSMutableString stringWithString:[sourceStr substringFromIndex:sufRang.location+3]];
        }
        else
        {
            break;
        }
        
    }
    return timeList;
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
        sSize = [NSString stringWithString:@"0 K"];
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
