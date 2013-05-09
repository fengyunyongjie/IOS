//
//  YNFunctions.h
//  NetDisk
//
//  Created by fengyongning on 13-5-8.
//
//

#import <Foundation/Foundation.h>

@interface YNFunctions : NSObject
+(NSString *)getFMCachePath;    //文件缓存目录
+(NSString *)getIconCachePath;  //图标缓存
+(NSString *)getKeepCachePath;  //收藏目录
+(NSString *)getTempCachePath;  //临时缓存目录
+(NSString *)getDataCachePath;  //数据缓存目录
+(NSString *)getFileNameWithFID:(NSString *)f_id;   //根据目录ID，获取数据缓存文件名称
@end
