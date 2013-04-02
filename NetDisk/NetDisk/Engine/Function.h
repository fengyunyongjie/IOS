//
//  Function.h
//  NetDisk
//
//  Created by jiangwei on 12-12-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Function : NSObject

+(double)getDirectorySizeForPath:(NSString*)path;
+(NSString *)covertNumberToString:(NSNumber *)sourceNumber;
+(long long) fileSizeAtPath:(NSString*) filePath;
+(NSString *)fileType:(NSString *)fileName;
+ (NSString *)getImgCachePath;
+ (NSString *)getTempCachePath;
+ (NSString *)getUploadTempPath;
+ (NSString *)getKeepCachePath;
+(NSString *)getThumbCachePath;
- (NSMutableArray *)parseTimeLine:(NSString *)timeStr;
#pragma mark --------获取图片存档文件名
+(NSString*)picFileNameFromURL:(NSString*)URL;
#pragma mark --------换算文件容量大小
+ (NSString *)convertSize:(NSString *)sourceSize;
@end
